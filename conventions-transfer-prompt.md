# Conventions transfer prompt

**Purpose:** A paste-ready prompt for handing this standard's conventions to another Claude
instance working in a *different* repository, for when the toolkit isn't at hand. It is the
**fallback**, not the primary path: if you can reach the `repo-standard` checkout at all,
`bin/init` + `bin/sync` + `bin/verify` do this mechanically, completely, and idempotently —
use them instead.

**Kept in step with [`standard/STANDARD.md`](standard/STANDARD.md) BY HAND** (there is no
generator — see the standard's non-goals). It drifted badly once (audit finding M28/D05: it
still described the pre-tracker, pre-guard standard and embedded stale hook scripts) and was
realigned 2026-08-13 — and again 2026-09-10 (D36: the README filename rule, the symlinked
`.gitignore` rule, never-delete tracker rows, `bin/track` in the copy list, and the two unenforced
spine rules it had never carried), and again 2026-09-14 (D41, from the fleet rehearsal: filling
versus appending to STATUS, relocations, the reason for `git mv`, the fold header and `git rm -f`,
the ID width, the single-handoff-day rename, one root `z-deprecated/`, and `docs/official/`
as a home rather than a mandate), and again 2026-10-01 (F17, 0.4.0: the register's checkable
form, `bin/register`, and the guard's second check), and again 2026-10-02 (0.5.0: the
`REPO-STANDARD.md` notice in every repo).
The hook scripts are deliberately **no longer embedded**:
two copies already drifted apart; a third copy pasted into prompts drifts worst of all. The
prompt now describes each hook's contract and says where the canonical script lives.

**How to use:** Copy everything inside the fenced block below and paste it as your first
message to the other Claude instance.

---

````text
Adopt the following documentation and version-control conventions for this repository. Treat
them as standing rules for our work together, and save them to your persistent memory so they
survive across sessions. These conventions come from a mechanized standard (the maintainer's
`repo-standard` repo); if that repo is reachable, say so and prefer running its tooling
(`bin/init <this-repo> --authored|--vendor-derived`, then `bin/sync`, then `bin/verify`) over
doing any of this by hand — the tooling is idempotent, never overwrites authored content, and
installs canonical hooks this prompt only describes.

────────────────────────────────────────
1) ARCHETYPE — SAY WHICH KIND OF REPO THIS IS
────────────────────────────────────────
Every repo is exactly one of two kinds; name it up front (the standard records it in a
`.repo-standard-version` stamp at the root):
- AUTHORED — the code IS the deliverable; docs describe code that exists.
- VENDOR-DERIVED — external docs are the input; code is generated to satisfy them. Two extra
  homes exist only here: `docs/reference/` (received, authoritative vendor material you did
  NOT author) and `docs/official/DEVIATIONS.md`, the register: where the implementation
  diverges from the reference, and why — the single most valuable artifact in such a repo.
  You authored it, so it lives with the end-user docs and opens with that home's status line.
  The register has a checkable form, kept by the standard's `bin/register` tool:
  - a `## Types` table and a `## Sources` table (key, document, version, date, and a path
    relative to the register), kept by hand;
  - one `## N. Title` heading per entry, numbered from 1, each with ONE header line under it
    — `*Type:* … · *Status:* active|moot|closed · *Original:* YYYY-MM-DD · *Updated:* dates
    or — · *Source:* <key> <location>; … or none` — then a blank line and the reasoning;
  - a summary table between `<!-- register:begin -->` and `<!-- register:end -->`, plus a
    `DEVIATIONS.html` beside it, both generated (`bin/register render`), never hand-edited.
  Cite an entry as `register N`; a closed entry keeps its number. Without the tool, keep the
  tables, headings and header lines by hand and leave the generated parts out.
An authored repo has neither home, and that absence is itself a signal.

────────────────────────────────────────
2) ROOT README — THE FRONT DOOR
────────────────────────────────────────
Above the fold, in ~30 seconds, the README answers three questions: WHAT is this, WHAT STATE
is it in / where do I resume, and WHERE do I go next (a map). The state/resume section is the
one that actually restores context — keep it a labelled heading (containing "status", "state"
or "resume") so it is findable. Content quality stays a human call.
The file is `README.md` — exactly that spelling, case-sensitive; the standard's tools read only
that name. If the repo already has a front door under another spelling (`README`, `readme.md`,
`README.txt`), rename or fold it into `README.md` — never keep two.

────────────────────────────────────────
3) DOCS STRUCTURE
────────────────────────────────────────
Under the docs root (create `docs/` at the repo root if none exists), four fixed homes:

- `docs/official/`  — end-user documentation YOU (the humans) authored. A home, not a
                      mandate: a deliverable already at the root and mapped from the
                      README conforms; move it only when the root is crowded. A draft
                      belongs here too: what marks it unfinished is a notice at its top
                      plus a tracker row (section 5), never its folder, so nothing moves
                      when it is done.
- `docs/AI/`        — Claude's durable output: session handoffs, audits, notes, design docs.
                      NOT for routine/ephemeral runs. Create subdirs on first use.
- `docs/dev-notes/` — the USER'S working notes: a `STATUS` file (their personal "where am
                      I?") plus the work tracker (section 5). Do NOT overwrite or
                      restructure these unless explicitly asked. One exception: an
                      empty STATUS skeleton the tooling just created may be filled
                      once, from the repo's own record. A STATUS the user wrote is
                      append-only (a dated pointer to your handoff); any judgment
                      about their queue goes in that handoff, not in STATUS.
- `docs/assets/`    — images/binaries that docs embed, created on first use.

Moving existing material into a home is a RELOCATION: relative links inside the moved files,
and every script, config or doc naming the old path, break — and no check sees it. Grep for
the old path until nothing is left, and check the moved files' `../` links.

STATUS LINES: every text document in `docs/official/` opens with a status line — Draft or
Current — and the date that status was set, never a last-edited date (git records that, and
a copy goes stale). A draft's status line is its notice, pointing at its tracker row
(section 5); when the draft is finished, the line changes to Current with that day's date.

────────────────────────────────────────
4) HANDOFFS + MONTH BUCKETING
────────────────────────────────────────
Session handoffs (your continuity notes for the next session) go in
`docs/AI/session-handoffs/`.
- Filename: `session-handoff-YYYY-MM-DD-HHMM.md`, LOCAL time, taken from `date` — never
  guessed. H1: `# Session handoff — YYYY-MM-DD HH:MM TZ`.
- A handoff captures ONLY what is not already in git or the READMEs: focus, what changed,
  decisions and their why, results/verdicts, next concrete steps, traps. Write it to be
  resumed from.
- The CURRENT month's handoffs sit at the top level; PAST months are archived into `YYYYMM/`
  subdirectories. At the first session of a new month, roll the prior month over:
  1. mkdir the `YYYYMM/` bucket and `git mv` that month's files in (git mv, not a bare mv,
     so both sides of each move are staged in one step — history follows by content either
     way; git mv fails as a unit if any handoff is untracked — `git add` those first, then
     move).
  2. Aggregate same-day files into ONE file per day named `session-handoff-YYYY-MM-DD.md`
     (the `-HHMM` suffix drops, also for a day with a single handoff). This is a MERGE, not a
     delete — a later handoff often summarises the day while dropping specifics only an
     earlier one records; read them all. A verbatim fold (each original in order under its own
     heading, beneath a header line naming every absorbed filename) satisfies this; then
     `git rm -f` the absorbed originals — a plain git rm refuses files the git mv just staged.
  3. Repoint inbound references (living docs cite handoffs by path); review each hit, never
     blind-sed.

────────────────────────────────────────
5) WORK TRACKER
────────────────────────────────────────
One file, `docs/dev-notes/tracker.md`, four categories — Bugs / Features / Documentation /
Testing. Every row: a status, a stable ID (B/F/D/T prefix, zero-padded to at least two digits
— B01, F15, B142 — with unpadded nesting like F12.2.1; cite IDs as the tool prints them), a
Created date, a Status-Changed date. The standard maintains this with a `track` CLI (`add`,
`set-status`, `render` → an interactive `tracker.html` view; `history` → an item's history
from git) plus a pre-commit guard that blocks any commit whose rendered view is stale against
the staged tracker.md. If you cannot get the tooling: keep the same single file and table
shape by hand, maintain IDs and dates scrupulously (they are only trustworthy when a tool sets
them — say in the file that it is hand-maintained), and skip the generated view rather than
hand-writing one.
An item that needs more than a one-line Description gets a section of its own, under one
`## Details` heading after the four tables: `### <ID> — <Name>` (the row's Name exactly), then
free text, written by hand; the Description stays a one-line summary.
Rows are NEVER deleted: work that will not happen is retired in place (`dropped`, or `cnr` for a
bug that cannot be reproduced) so every ID ever issued keeps resolving.

────────────────────────────────────────
6) VERSION-CONTROL DEFAULT — AND THE COMMIT GATE
────────────────────────────────────────
Everything durable is version-controlled — code, official docs, AND the docs/AI/ artifacts.
A durable file that isn't committed is effectively lost to the next session. But this is NOT
standing permission to commit: get an explicit go-ahead from the user immediately before the
actual `git commit` / `git push`, every time.

Two repo-local protections travel with the repo, not the machine:
- `.gitignore` must carry `.claude/settings.local.json*` (personal Claude permissions and the
  harness's `settings.local.json.tmp.*` write siblings) and `CLAUDE.local.md` (personal Claude
  directives; unanchored, so a copy in any subdirectory stays out too) — a machine-global ignore
  protects only that machine; any other clone is one `git add -A` from committing them. It must
  be a regular file: git 2.32+ never reads a symlinked `.gitignore` (or `.gitattributes`), so a
  stow-style link protects nothing whatever it carries.
- `.gitattributes` must pin the shipped shell machinery to LF (`.claude/hooks/* text eol=lf`,
  `.githooks/* text eol=lf`, `bin/track text eol=lf`, and `bin/register text eol=lf` in a
  vendor-derived repo): a `core.autocrlf=true` clone otherwise materializes hooks whose `\r`'d
  shebang dies exit 127.

One setting does NOT travel and is set per clone, by hand: `git config tag.sort version:refname`,
so `git tag` lists versions in order — plain git sorts tag names as strings and files `v0.3.10`
between `v0.3.1` and `v0.3.2`. (The commit guard's `core.hooksPath`, section 8, is the other
per-clone setting.) The standard's `verify` warns when either is missing.

────────────────────────────────────────
7) EXIT HANDOFF CHECK
────────────────────────────────────────
Whenever the user signals they're exiting, ensure the session's work is captured in a handoff
(format per section 4) BEFORE they leave. In order:

STEP 0 — changed-files override: if ANY file changed since the most recent handoff (sole
exception: changes confined to `docs/dev-notes/STATUS`), write a new handoff now.
Otherwise fall through freshness tiers (first match wins):
  - handoff within the last 30 MINUTES -> already covered; let them exit
  - else within the last 12 HOURS      -> good enough; let them exit
  - else (older, or none)              -> write one now.

A handoff whose filename time is later than the clock was stamped ahead: it gets no 30-minute
grace, and it needs renaming to the time it was really written. And if this session changed
nothing, say so and let them exit rather than writing a handoff.

────────────────────────────────────────
8) THE TWO HOOKS (INSTALL FROM THE CANONICAL SOURCE — NOT FROM THIS PROMPT)
────────────────────────────────────────
The standard automates the two things humans forget, via Claude Code hooks wired in
`.claude/settings.json` (which is TRACKED, shared machinery; only settings.local.json is
personal):
- A Stop hook that nudges (never authors) when a handoff is DUE — 30-minute anti-nag grace
  (none for a handoff named later than the clock), then git-status-based changed-file
  detection (so fresh clones don't false-nag), then the 12h tier; its message lets a session
  that changed nothing say so and stop. Loop-safe, portable, archive-aware.
- A SessionStart hook that detects un-rolled prior months and injects the full rollover
  procedure as context — detect + nudge only; the model does the rollover.

Beside the hooks, every repo has a root `CLAUDE.md`, which Claude Code loads in full at the
start of every session: standing instructions only, never session state. It may be nothing but
the statement that all Claude directives for the repo are in `CLAUDE.local.md` (personal, loaded
after it, never committed). When none exists, the standard's `init` stamps a minimal one that
says personal directives, if any, go in `CLAUDE.local.md`, without claiming the file exists.
Subfolders may carry their own `CLAUDE.md` under the same rule: standing instructions only.

Earlier revisions of this prompt embedded both scripts inline; they drifted from the canon
and are gone. Get the canonical, current copies from the standard's repo —
`template/.claude/hooks/stop-handoff-check.sh`,
`template/.claude/hooks/session-start-rollover-check.sh`, `template/.githooks/pre-commit`,
`template/.claude/settings.json` and `template/bin/track` (the tracker CLI — the pre-commit
guard renders through it, so the four files without the fifth leave a guard that cannot run),
plus `template/bin/register` in a vendor-derived repo (the guard's second check, on the staged
register, runs through it), and `template/REPO-STANDARD.md` — by running its
`bin/init`/`bin/sync`, or by copying those files verbatim (then `chmod +x` the scripts and
`git config core.hooksPath .githooks`). `REPO-STANDARD.md` goes at the repo root: the
standard's notice, the same text in every repo, saying which files are managed and which names
must not change. Never edit it locally; an update replaces it. If the repo is truly
unreachable, implement the contracts described above from scratch rather than resurrecting any
older pasted copy you may find — the older copies contain known, fixed bugs.

────────────────────────────────────────
9) TWO LAYOUT CONVENTIONS — NUMBERED PREFIXES AND z-deprecated/
────────────────────────────────────────
- Where a REAL sequence exists (setup stages, ordered runbooks), prefix the directories or
  files `00-` … `99-` so run order is legible from `ls` alone. Order that lives only in a
  human's head is lost on the next session. Do not number things that are not a sequence —
  that is false structure.
- Retained-but-superseded material goes in one `z-deprecated/` directory at the repo root
  (the `z-` sorts it to the bottom). Deleting loses history; leaving it inline creates false
  current-state.
No tool checks either — they are judgment calls, and this prompt is their only carrier.

────────────────────────────────────────
Once you've read this, save these conventions to your persistent memory (one fact per memory
if your memory system works that way: archetype + front door, docs structure, handoff format
+ month rollover, tracker, VCS default + commit gate, exit handoff check, hooks-from-canon
+ CLAUDE.md, numbered prefixes + z-deprecated),
and confirm back to me which conventions you've recorded.
````
