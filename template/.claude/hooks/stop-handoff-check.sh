#!/usr/bin/env bash
# Managed by repo-standard: read REPO-STANDARD.md at the repo root before editing, moving or
# deleting this file. sync replaces it from the standard.
# stop-handoff-check.sh — Claude Code *Stop* hook. Nudges the model to write a
# session handoff before stopping when one is DUE; otherwise exits 0 (silent).
# DUE: (1) <=30min since latest handoff -> NOT due (anti-nag grace; none for a handoff
# whose NAME is dated ahead of the clock, B144); (2) else any
# UNCOMMITTED path (per git status) modified more recently than the latest handoff
# (excluding dev-notes/STATUS + the handoffs; plain mtime walk in a non-git tree)
# -> DUE; (3) else <=12h old -> NOT due; (4) else / no handoff -> DUE.
# Portable, no jq, loop-safe.
set -uo pipefail
input="$(cat 2>/dev/null || true)"
if printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi
root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || true)}"
[ -n "$root" ] && [ -d "$root" ] || exit 0
cd "$root" 2>/dev/null || exit 0
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
now="$(date +%s)"; GRACE=1800; MAXAGE=43200
# "YYYY-MM-DD HH:MM" -> epoch, portable across userlands (B53): GNU `date -d`, then BSD
# `date -j -f`, then the file's mtime via GNU `stat -c` then BSD `stat -f`. The old
# GNU-only chain collapsed to epoch 0 on BSD/macOS, which made the newest handoff
# permanently "more than 12h old" and marked a handoff DUE on every single stop.
to_epoch(){  # $1 = "YYYY-MM-DD HH:MM"; $2 = file whose mtime is the fallback
  date -d "$1" +%s 2>/dev/null \
    || date -j -f '%Y-%m-%d %H:%M' "$1" +%s 2>/dev/null \
    || stat -c %Y "$2" 2>/dev/null \
    || stat -f %m "$2" 2>/dev/null \
    || echo 0
}
newest=""
if [ -n "$hdir" ]; then
  # Newest by FILENAME (the names sort chronologically), across the top level AND the
  # YYYYMM/ archive buckets (B28): right after a month rollover the top level is
  # legitimately empty, and "no session handoff exists yet" was flatly wrong there.
  # Only DATE-SHAPED names compete: a stray session-handoff-notes.md would otherwise
  # sort after every dated name and hijack "newest" forever.
  newest="$(ls -1 "$hdir"/session-handoff-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*.md \
                  "$hdir"/[0-9][0-9][0-9][0-9][0-9][0-9]/session-handoff-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*.md 2>/dev/null \
            | awk -F/ '{ print $NF "\t" $0 }' | sort | tail -n1 | cut -f2-)"
fi
due=0; reason=""; fix=""; future=0
if [ -z "$newest" ]; then
  due=1; reason="no session handoff exists yet"
else
  base="$(basename "$newest")"; ts="${base#session-handoff-}"; ts="${ts%.md}"
  case "$ts" in
    *-[0-9][0-9][0-9][0-9])
      # Timestamped file: session-handoff-YYYY-MM-DD-HHMM.md
      datepart="${ts%-*}"; timepart="${ts##*-}"; hh="${timepart:0:2}"; mm="${timepart:2:2}"
      handoff_epoch="$(to_epoch "$datepart $hh:$mm" "$newest")"
      ;;
    *)
      # Aggregated day file: session-handoff-YYYY-MM-DD.md (the rollover drops -HHMM).
      # Its work ended some time that day; noon is the least-wrong fixed point, and it
      # beats the old behavior — a failed parse silently aging by fs mtime, which on a
      # fresh clone is checkout time, i.e. "brand new" (B28).
      handoff_epoch="$(to_epoch "$ts 12:00" "$newest")"
      ;;
  esac
  age=$(( now - handoff_epoch ))
  # A name dated AHEAD of the clock (B144) is a stamp typed early, not a fresh handoff —
  # every first handoff of the 2026-09-11 rehearsal was 3 to 49 minutes ahead. The old
  # clamp read it as age 0, inside the grace window, so later work never marked a handoff
  # DUE. Skipping the grace alone would not help: the change test below compares against
  # the NAMED time, and no edit is newer than a time that has not happened yet. So a future
  # name gets no grace, the change test compares against the handoff file's own mtime (its
  # real write time), and the message asks for the rename. Grace itself still never reads
  # an mtime (B28: a fresh clone's checkout mtime must not make an old handoff look new).
  # SKEW tolerates a second machine's clock running slightly behind the first's.
  SKEW=120
  if [ "$age" -lt "-$SKEW" ]; then
    future=1
    cmp_epoch="$(stat -c %Y "$newest" 2>/dev/null || stat -f %m "$newest" 2>/dev/null || echo 0)"
  else
    cmp_epoch="$handoff_epoch"
  fi
  [ "$age" -lt 0 ] && age=0
  if [ "$future" = 0 ] && [ "$age" -le "$GRACE" ]; then
    due=0
  else
    changed=""
    if git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      # Ask GIT what is modified, not the filesystem (B65): a bare mtime walk calls
      # every file of a fresh clone "changed" — checkout mtimes are always newer than
      # any handoff — and so blocked every stop on a second machine. The signal that
      # work happened without a handoff is an UNCOMMITTED path (staged, unstaged or
      # untracked; ignored files never appear in porcelain) touched since the handoff.
      # -z: NUL-delimited entries carry each name RAW — no C-quoting, no ` -> ` rename
      # arrow, no escapes — so names holding quotes, backslashes, newlines or a
      # literal ' -> ' all parse exactly (the whole B98/B104 class the old line-wise
      # arrow-splitting fought one exotic case at a time). A rename/copy entry is two
      # NUL fields, TARGET first; the ORIGIN field gets its own deletion check in
      # the case arm below (re-attack on B103).
      # An uncommitted DELETION has no path to stat, so the old loop read m=0 and
      # silently skipped it — a deletion-only session never marked a handoff DUE
      # inside the 30min–12h window (B103). Proxy: walk up to the nearest SURVIVING
      # ancestor and use ITS mtime — POSIX guarantees unlink updates the parent
      # dir's mtime, so a fresh deletion reads newer-than-handoff while a stale one
      # in a quiet tree stays silent. Accepted over-sensitivity: unrelated churn in
      # the deleted file's directory can cost one extra, dischargeable nag; every
      # written handoff resets the comparison point, so there is no perpetual nag.
      # Porcelain paths are repo-TOPLEVEL-relative (B111): when the project is a
      # SUBDIRECTORY of a larger repo, stat'ing "$root/$f" missed every file (the
      # signal silently died) or hit an unrelated same-named file, and the handoffs-dir
      # exclusion never matched. Stat against the toplevel — and scope to the project's
      # own subtree, because another package's churn is not THIS project's
      # work-without-a-handoff.
      top="$(git -C "$root" rev-parse --show-toplevel 2>/dev/null)"; [ -n "$top" ] || top="$root"
      prefix="$(git -C "$root" rev-parse --show-prefix 2>/dev/null || true)"
      while IFS= read -r -d '' entry; do
        [ -n "$entry" ] || continue
        st="${entry:0:2}"; f="${entry:3}"; rt=0
        case "$st" in
          R*|C*|*R|*C)
            rt=1
            IFS= read -r -d '' _origin || true
            # A rename is an uncommitted DELETION of its origin, and rename(2)
            # preserves the target's mtime — so a pure git-mv session read entirely
            # pre-handoff and never marked a handoff DUE (re-attack on B103). Check
            # the origin HERE, self-contained: the target-side exclusions below must
            # not skip it (a target renamed INTO the handoffs dir still deleted an
            # in-scope origin). Renames are file entries, so the collapsed-directory
            # ancestor branch does not apply; for a C entry the origin still exists
            # and the walk degenerates to a stat of its unchanged mtime — harmless.
            okeep=0 orel=""
            case "$_origin" in "$prefix"*) okeep=1; orel="${_origin#"$prefix"}" ;; esac
            [ -n "$_origin" ] || okeep=0
            case "$orel" in dev-notes/STATUS|*/dev-notes/STATUS) okeep=0 ;; esac
            case "$top/$_origin" in "$hdir"/*) okeep=0 ;; esac
            if [ "$okeep" = 1 ]; then
              p="$top/$_origin"
              while [ ! -e "$p" ] && [ ! -h "$p" ] && [ "${#p}" -gt "${#top}" ]; do p="${p%/*}"; done
              m="$(stat -c %Y "$p" 2>/dev/null || stat -f %m "$p" 2>/dev/null || echo 0)"
              if [ "$m" -gt "$cmp_epoch" ]; then changed="$orel"; break; fi
            fi
            ;;
        esac
        # Scope to the project: entries under the prefix count (their project-
        # relative remainder drives the exclusions). A DIRECTORY entry that is an
        # ANCESTOR of the prefix counts too — git collapses untracked dirs at the
        # HIGHEST untracked level, so a brand-new project subtree arrives as the
        # parent's entry ('?? p/' for a project at p/q/) and skipping it would
        # silently kill the DUE signal (re-attack on B111).
        keep=0 rel=""
        case "$f" in
          "$prefix"*) keep=1; rel="${f#"$prefix"}" ;;
          */) case "$prefix" in "$f"*) keep=1; rel="$f" ;; esac ;;
        esac
        [ "$keep" = 1 ] || continue
        case "$rel" in dev-notes/STATUS|*/dev-notes/STATUS) continue ;; esac
        case "$top/$f" in "$hdir"/*) continue ;; esac
        # Deleted path: fall back to the nearest surviving ancestor's mtime (B103).
        # [ ! -h ] keeps a present-but-DANGLING symlink out of the walk: -e follows
        # links, so a broken link would inherit its parent dir's churn (ignored
        # files invisible to porcelain) instead of its own correct, older lstat
        # mtime — stat without -L already reads the link itself.
        p="$top/$f"
        while [ ! -e "$p" ] && [ ! -h "$p" ] && [ "${#p}" -gt "${#top}" ]; do p="${p%/*}"; done
        # A path that IS a directory — above all a COLLAPSED untracked one ('?? dir/':
        # git reports only the highest fully-untracked level) — is judged by the
        # newest mtime FOUND BENEATH it, never by its own alone (convergence K8): a
        # directory's mtime moves only when a direct entry is added or removed, so an
        # edit (or a new file one level down) left the stat stale and the DUE signal
        # silently died — and a freshly-stamped project before its first commit is
        # exactly such a collapsed tree. The start dir's OWN mtime is stat'd first
        # (the pre-K8 trigger), and the descent runs -mindepth 1 (convergence L8):
        # find's prune expression tests the START point too, so a dir named vendor /
        # node_modules / .venv — an untracked `go mod vendor` tree, say — was pruned
        # outright, printed nothing, and the DUE signal silently died again. Same
        # prune list as the non-git walk below for DESCENDANTS only. GNU find takes
        # the exact handoff epoch; a userland whose find lacks -newermt(@epoch) errs
        # there and falls back to -newer against the handoff file itself — the
        # non-git branch's comparison.
        # The descent carries the per-entry loop's OWN exclusions too (convergence
        # M6): the newest handoff's mtime lands seconds after its minute-truncated
        # filename stamp, so whenever $hdir sits BENEATH a scanned dir — a fresh
        # pre-first-commit project is exactly a collapsed '?? docs/' over it — the
        # handoff itself was the guaranteed hit, and the demanded new handoff
        # recreated the state: a perpetual nag, the exact thing the epoch-reset
        # comment above promises away. dev-notes/STATUS likewise. -path pattern-
        # matches, so glob chars in $hdir are the newline residue's class.
        if [ -d "$p" ] && [ ! -h "$p" ]; then
          m="$(stat -c %Y "$p" 2>/dev/null || stat -f %m "$p" 2>/dev/null || echo 0)"
          if [ "$m" -gt "$cmp_epoch" ]; then changed="${rel:-$f}"; break; fi
          hit="$(find "$p" -mindepth 1 \( -path '*/.git' -o -name node_modules -o -name .venv -o -name vendor \
                     -o -path "$hdir" -o -path '*/dev-notes/STATUS' \) -prune \
                   -o -newermt "@$cmp_epoch" -print -quit 2>/dev/null)" \
            || hit="$(find "$p" -mindepth 1 \( -path '*/.git' -o -name node_modules -o -name .venv -o -name vendor \
                          -o -path "$hdir" -o -path '*/dev-notes/STATUS' \) -prune \
                        -o -newer "$newest" -print -quit 2>/dev/null)"
          if [ -n "$hit" ]; then changed="${rel:-$f}"; break; fi
          continue
        fi
        m="$(stat -c %Y "$p" 2>/dev/null || stat -f %m "$p" 2>/dev/null || echo 0)"
        # A fully-untracked project dir arrives COLLAPSED ('?? pkg/'), making rel
        # empty — fall back to the porcelain path so the DUE signal survives.
        if [ "$m" -gt "$cmp_epoch" ]; then changed="${rel:-$f}"; break; fi
        # A rename/copy TARGET carries its ORIGIN's mtime (rename(2) preserves it;
        # cp -p recreates it), so a file renamed INTO the project from outside the
        # prefix read entirely pre-handoff and the session's only change never
        # marked a handoff DUE (B130) — the origin arm above is scope-gated by
        # design (B111) and never fired. The arrival's witness is the destination
        # DIRECTORY's mtime — POSIX guarantees rename updates it — the same proxy,
        # same accepted over-sensitivity, as B103's deletion side: unrelated churn
        # beside the target can cost one extra, dischargeable nag. Renames are
        # file entries, so the collapsed-directory branch above never swallows
        # this; a target inside $hdir or dev-notes/STATUS was already excluded.
        if [ "$rt" = 1 ]; then
          pp="${p%/*}"; [ "${#pp}" -ge "${#top}" ] || pp="$top"
          m="$(stat -c %Y "$pp" 2>/dev/null || stat -f %m "$pp" 2>/dev/null || echo 0)"
          if [ "$m" -gt "$cmp_epoch" ]; then changed="${rel:-$f}"; break; fi
        fi
      done < <(git -C "$root" status --porcelain -z 2>/dev/null)
    else
      # Non-git tree: the mtime walk is all there is. -mindepth 1 (B131, same class
      # as the descent's L8 above): -name vendor matched a START dir so named, the
      # prune killed the whole walk at depth 0, and the DUE signal silently died in
      # exactly the trees that have no git status to fall back on.
      while IFS= read -r f; do
        [ -n "$f" ] || continue
        case "$f" in */dev-notes/STATUS) continue ;; "$hdir"/*) continue ;; esac
        changed="$f"; break
      done < <(find "$root" -mindepth 1 \
                 \( -path '*/.git' -o -name node_modules -o -name .venv -o -name vendor \) -prune \
                 -o -type f -newer "$newest" -print 2>/dev/null)
    fi
    if [ -n "$changed" ]; then
      due=1; reason="files changed since the last handoff (e.g. ${changed#"$root"/})"
      [ "$future" = 0 ] || fix=" First rename $base to the time it was really written: its name is later than the clock, which hides every later change from this check."
    elif [ "$age" -le "$MAXAGE" ]; then
      due=0
    else
      due=1; reason="the latest handoff is more than 12h old"
    fi
  fi
fi
[ "$due" -eq 1 ] || exit 0
stamp="$(date '+%Y-%m-%d-%H%M')"; h1="$(date '+%Y-%m-%d %H:%M %Z')"
# When no handoffs dir exists yet, name the real CANONICAL path — the old literal
# '<docs-root>' placeholder sent the model to create a directory of that name (B37).
dest="${hdir:-$root/docs/AI/session-handoffs}/session-handoff-${stamp}.md"
# The message carries its instructions INLINE and cites no external doc: this hook is
# stamped into repos that receive none of the standard's documentation, so a citation
# ("the project's exit-handoff rule", "the handoff format") dangles the moment the
# hook travels (D10, B07's class).
msg="A session handoff is DUE before you stop (${reason}).${fix} Write it now at ${dest} with H1 'Session handoff — ${h1}', then you may stop. Cover, briefly: focus (what this session set out to do), what changed (files, decisions, commits), results/verdicts, next steps for the session that resumes, and traps (anything that cost time or would mislead a reader). The handoff is the next session's only context — write it to be resumed. (If the user explicitly asked you not to, or this session changed nothing, say so and stop.)"
# JSON-escape rather than strip (B54): a backslash or double-quote in a path must
# survive into valid JSON, not vanish from the message. ALL control chars become
# spaces — enumerating just \n\r\t left the other 26 C0 bytes to break the JSON.
jesc(){ local s=$1; s=${s//\\/\\\\}; s=${s//\"/\\\"}; printf '%s' "$s" | tr '\000-\037' ' '; }
printf '{"decision":"block","reason":"%s"}\n' "$(jesc "$msg")"
exit 0
