#!/usr/bin/env bash
# Managed by repo-standard: read REPO-STANDARD.md at the repo root before editing, moving or
# deleting this file. sync replaces it from the standard.
# session-start-rollover-check.sh — Claude Code *SessionStart* hook. When a
# session begins with a PRIOR month's handoffs still sitting in the top-level
# session-handoffs/ dir (i.e. not yet archived into a YYYYMM/ subdir), inject a
# nudge to run the month rollover.
# Silent (exit 0, no output) when nothing is un-bucketed. Portable, no jq.
#
# The message carries the WHOLE procedure inline and cites no external doc. That
# is deliberate: this script is stamped into repos that receive none of the
# standard's own documentation (sync ships five machinery files and nothing
# else; STANDARD.md and conventions-transfer-prompt.md stay behind), so any
# citation here is a dangling reference the moment the hook travels. It once
# cited a session-handoffs/README.md that the stamped repos were never
# guaranteed to have (one fleet repo even carries its own, CONFLICTING copy —
# worse than absent), and its steps carried a previous repo's directory names —
# both went unnoticed precisely because the inline steps work.
set -uo pipefail

root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || true)}"
[ -n "$root" ] && [ -d "$root" ] || exit 0
# Pick the handoffs dir. Prefer the CANONICAL location outright; only search if it is
# absent. Searching first is wrong in any repo that ships a docs skeleton under another
# directory (a devcontainer template, an example app, a vendored sample): that mirror can
# sort ahead of the real dir and win deterministically. B01 fixed this by excluding
# `template/` by name, which did not generalise — `.devcontainer/`, `app-template/` and
# `assets/` all still lost. When falling back, take the SHALLOWEST match — and prune
# dependency trees first (B38): a session-handoffs/ nested in node_modules, .venv or
# vendor is someone else's fixture, and a shallow one could otherwise win. The prune
# list matches the standard's other tree walks — and the search runs -mindepth 1
# (B131, L8's class): find's prune expression tests the START point too, so a root
# literally named vendor / node_modules / .venv found no handoffs at all. The start
# dir itself can no longer match -name session-handoffs either — a root that IS the
# handoffs dir was never a layout the canonical check above accepts anyway.
if [ -d "$root/docs/AI/session-handoffs" ]; then
  hdir="$root/docs/AI/session-handoffs"
else
  hdir="$(find "$root" -mindepth 1 \( -name .git -o -name node_modules -o -name .venv -o -name vendor \) -prune \
            -o -type d -name session-handoffs -not -path '*/example-handoffs/*' -not -path "$root/template/*" -print 2>/dev/null \
          | awk '{ n=gsub(/\//,"/"); print n, $0 }' | sort -k1,1n -k2,2 | head -n1 | cut -d' ' -f2-)"
fi
[ -n "$hdir" ] && [ -d "$hdir" ] || exit 0

# Quote paths in the message from the dir actually PICKED, not the canonical guess:
# the fallback branch above can legitimately land somewhere else, and a nudge that
# names a directory the repo does not have sends the rollover to the wrong place.
# JSON-escape the interpolation (B54): a backslash or double-quote in the path must
# survive into valid JSON rather than break the emitted object; any control char in
# the path (a tab-bearing dir name) becomes a space, since raw C0 bytes are invalid
# inside a JSON string.
hrel="${hdir#"$root"/}"
hrel="${hrel//\\/\\\\}"; hrel="${hrel//\"/\\\"}"
hrel="$(printf '%s' "$hrel" | tr '\000-\037' ' ')"

this_ym="$(date +%Y-%m)"

# Top-level handoff files that do NOT belong to the current month = not yet
# archived. Catches multi-month gaps too (any stale month, not just last).
count=0; months=""
while IFS= read -r f; do
  [ -n "$f" ] || continue
  b="$(basename "$f")"
  # Only FULLY date-shaped names count (B120), mirroring the Stop hook's newest-glob
  # INCLUDING the day: a stray session-handoff-notes.md otherwise becomes stale month
  # "notes.m", and a day-less session-handoff-YYYY-MM.md either mints a git-mv glob
  # that matches nothing (prior month) or — worse — puts the CURRENT month into the
  # roll list, since find's exclusion below needs the trailing dash. Either way the
  # nudge is unfollowable and never self-clears.
  case "$b" in session-handoff-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*.md) ;; *) continue ;; esac
  ym="${b#session-handoff-}"; ym="${ym:0:7}"
  count=$((count + 1))
  case " $months " in *" $ym "*) ;; *) months="${months:+$months }$ym" ;; esac
done < <(find "$hdir" -maxdepth 1 -type f -name 'session-handoff-*.md' \
           ! -name "session-handoff-${this_ym}-*.md" 2>/dev/null)
[ "$count" -gt 0 ] || exit 0

# Render "YYYY-MM -> YYYYMM" for each stale month.
buckets=""
for ym in $months; do
  buckets="${buckets:+$buckets, }$ym -> ${ym//-/}"
done

# Single-line message using literal \n for line breaks; deliberately free of "
# and stray \ so it drops straight into the JSON below without extra escaping
# (hrel is escaped above — the only interpolation that can carry such bytes).
msg="[rollover check] ${count} prior-month handoff file(s) still sit in the top-level ${hrel}/ dir (current month ${this_ym}). Convention: the first session of a new month archives the prior month into a YYYYMM/ subdir, so the top level holds only the current month plus the YYYYMM/ archives. Months to roll: ${buckets}.\n\nBefore this session's substantive work, offer the user the month rollover, then run it. Steps per month (YYYY-MM -> bucket YYYYMM):\n  1. ARCHIVE. mkdir -p ${hrel}/YYYYMM, then git mv ${hrel}/session-handoff-YYYY-MM-*.md into it. Use git mv, not a bare mv, so both sides of each move are staged in one step (history follows by content either way). NOTE: git mv fails AS A UNIT if any matched handoff is untracked — the normal state when a handoff was written but the commit is still gated. git add the untracked handoffs first (they belong in history anyway), then git mv; nothing moves until the command succeeds.\n  2. AGGREGATE same-day files into ONE file per day, named session-handoff-YYYY-MM-DD.md — the -HHMM suffix is dropped for a day file, and a day with a single handoff is renamed the same way. This is a MERGE, not a delete: read every same-day file before folding them, because a later handoff often summarises the day while dropping specifics (traps, open questions, decisions) that only the earlier one records. Note in the merged file that it is an aggregated day file. A verbatim fold — each original in order under its own heading, beneath a header line that says this is an aggregated day file and names every absorbed filename — satisfies this step (git credits the day file to at most one origin, so the header is what keeps the other names findable). Then git rm -f the absorbed originals: a plain git rm refuses files the git mv just staged.\n  3. REPOINT inbound references. Living docs cite handoffs by path. Find them with: grep -rn 'session-handoff-YYYY-MM-' --exclude-dir=.git . | grep -v ^./${hrel}/  — the exclusion is anchored to the FILE-PATH field so it drops only hits from files INSIDE the handoffs dir; an unanchored filter would also drop every path-style citation in the living docs, which are exactly the hits this step exists to find. Update each hit to the YYYYMM/ path, and to the new name for any file step 2 renamed. Review the hits; do not blind-sed the tree.\n  4. RE-RUN the standard's verify if the repo has one — its handoff-bucketing check should return to a pass.\nPrompt before committing (repo commit rule). If the files are intentionally left un-bucketed, say so and continue."

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$msg"
exit 0
