# STANDARD

How my repos are laid out, so that a human — or a fresh Claude session — can gain context
fast and start working without re-deriving anything.

This is the human-readable source of truth. It is *held* here and *executed* by the toolkit
in `../bin/` (`init` stamps it into a repo, `verify` checks a repo against it, `sync` keeps
the shared parts current). `../conventions-transfer-prompt.md` is the paste-into-a-fresh-Claude
fallback for when the toolkit isn't at hand — keep it in step with this document.

Each spine element below is given as **What** (the rule), **Why** (the reason it earns its
place), and **Tooling** (how `init`/`verify`/`sync` support it). If a rule has no *why* you
still believe, delete the rule — don't keep it out of habit.

---

## Two archetypes

Every repo is exactly one of two kinds. The **spine** (below) is identical for both; a few
**slots** appear only for the vendor-derived kind. The archetype is chosen at `init` time and
recorded in `.repo-standard-version`.

- **Authored solution** — the code *is* the deliverable. Docs describe code that exists.
  *Example: a tool or service whose source is the product — purpose-built code developed as a
  solution.*
- **Vendor-derived integration** — external docs are the input; code is generated to satisfy
  them, and a traceability layer records where you diverged.
  *Example: a system installed from a vendor's deployment guides — vendor documentation used to
  generate setup/implementation code.*

Naming the archetype up front sets expectations: a reader of an authored repo looks for the
solution in the code; a reader of a vendor-derived repo looks for the source-of-truth in
`docs/reference/`, the divergences in `docs/official/DEVIATIONS.md`, and what is still to be
asked of the vendor in `docs/official/VENDOR-QUESTIONS.md`.

### One repo, several small projects

A repo may hold several small projects that share one tree because none of them warrants a
repo of its own: a folder per project, each with its own scripts and its own README, and
sessions that work on one folder at a time. That is still an **authored** repo, not a third
archetype: the archetype says where the source of truth is, and this shape changes only how
many projects share it. What it strains is the context layer, so four conventions carry it,
all memo and no mechanism (`verify` checks none of them):

- The README's map has one line per folder: what it is, where it stands, where its own README
  is. A folder's README stays beside its scripts; `docs/official/` is a home, not a mandate.
- `STATUS.md` items and tracker row names start with the folder name (the item's form is in
  section 10), so the maintainer's queue and the tracker's page read as a per-folder board
  without a column for it.
- One dated handoff stream at the root, never a HANDOFF file in a folder; each handoff's first
  line names the folder it worked in. The hooks and the rollover need nothing more.
- A folder leaves for a repo of its own when it stops being play: when something else depends
  on it, or someone else uses it. Until then it stays, and the move is a relocation like any
  other.

Decided 2026-11-03 on the first such repo. The alternative, one project per folder with its
own homes and hooks, was rejected as ceremony: the Stop hook can scope itself to a project
inside a larger repo (B111), but several front doors and several trackers in one scratch repo
is more structure than the work has.

---

## The spine (every repo)

### 1. Root README — the front door

**What.** Above the fold, in ~30 seconds, the README answers three questions:

- *what is this*
- *what state is it in / where do I resume*
- *where do I go next* (a map of the repo)

**Name.** The file is `README.md` — exactly that spelling, case-sensitive. Every tool here
reads only that name, so a front door kept as `README`, `readme.md` or `README.txt` is
invisible to them: fold it into `README.md` rather than keeping it alongside.

**Why.** The README is the one file every human and every fresh session opens first. If it
can't orient you in half a minute, the context cost has already been paid in confusion.

**Tooling.**

- `init` stamps `README.skel.md` with the three sections pre-labelled — and refuses, before
  writing anything, to add it beside a front door spelled any other way (B137).
- `verify` fails if `README.md` is missing (naming any other spelling it found instead).
- `verify` warns if a second spelling sits beside it (two front doors, B138).
- `verify` warns if it still contains unfilled skeleton placeholders, naming each one and its line.
- `verify` warns if no heading names the *state / where do I resume* section (matching
  `status`, `state` or `resume`). That heading check exists because `init` never overwrites an
  existing `README.md`, so a repo can adopt the standard, verify clean, and still have a front
  door that never says where to pick up — which is the one section that actually restores
  context. It tests for a **labelled section, not for good prose**: whether the words
  underneath are any use stays a human call, and the check stays a `WARN` because an unwritten
  front door is a todo, not a broken repo.

### 2. `docs/` homes (fixed names)

**What.** Five fixed homes, each with one job:

- `docs/official/` — end-user documentation *you authored*. A home, not a mandate: a
  deliverable that already lives at the root and is mapped from the README is conformant;
  move it only when the root is crowded (and see **Relocations** below). A draft belongs here
  too: what marks it unfinished is a notice at its top plus a tracker row, never its folder,
  so nothing moves when it is done. <!-- (D45) -->
- `docs/AI/` — Claude's durable output: session handoffs, audits, notes, design docs.
- `docs/tracking/` — where work stands: `STATUS.md` (section 10) and the work tracker
  (section 5), which is `tracker.md`, its page `tracker.html` and the `tracker-hwm` sidecar.
  `bin/track` keeps the tracker. The session keeps `STATUS.md` true, and its queue is the
  maintainer's. <!-- (F21) -->
- `docs/dev-notes/` — the maintainer's own working notes, created on first use. **A session
  does not write here unless it is asked to**: the notes belong to the human.
  <!-- (F21, D53) -->
- `docs/assets/` — images and binaries, created on first use.

**Why.** Fixed names mean you never hunt for "where do the handoffs go" or "where's the real
vendor spec." The split keeps what was authored, what was generated, what tracks the work and
what is one person's own from silently overwriting each other.

Until 0.9.0 the tracker and `STATUS` lived in `docs/dev-notes/`, under the rule that Claude
does not overwrite the maintainer's notes. By then that rule described neither file: a tool
kept the tracker, and sessions edited `STATUS` on the maintainer's go. So the two got a home
of their own, and `docs/dev-notes/` holds the maintainer's notes and nothing else.

**Relocations.** Moving existing material into a home is a relocation: relative links inside
the moved files, and every script, config or doc naming the old path, break — and `verify`
cannot see it. Grep the tree for the old path until it returns nothing, and check the moved
files' `../` links; the rollover procedure's repoint step (section 4) is the same rule for
handoffs.

**Status lines.** Every text document in `docs/official/` opens with a status line: **Draft**
or **Current**, and the date that status was set. Never a last-edited date: git already
records that, and a copy goes stale on the next edit. A draft's status line is its notice
(the draft rule above), pointing at its tracker row; when the draft is finished, the line
changes to Current with that day's date. <!-- (D46) -->

**Tooling.**

- `init` creates the three required homes: `docs/official/`, `docs/AI/` and `docs/tracking/`.
- `verify` checks that those three exist. `docs/dev-notes/` and `docs/assets/` are
  deliberately unchecked: each is created on first use, and its absence is conformant.
  <!-- (D13, F21) -->
- No tool reads both layouts. A repo that still keeps a tracking file in `docs/dev-notes/`
  is told so by `init`, `verify` and `sync`, and by `bin/track` when the tracker itself is
  still there. None of them changes it. See the three below, and section 5 for `bin/track`.
  <!-- (F21) -->

### 3. `.claude/` hooks and `CLAUDE.md`

**What.** `.claude/settings.json` wires two hooks:

- a **Stop** hook that nudges for a session handoff;
- a **SessionStart** hook that checks for month-rollover of the handoff archive.

The hook scripts live in `.claude/hooks/` and must be executable.

**Why.** The hooks automate the two things humans forget: writing down where they left off, and
filing last month's handoffs. They are self-contained (no `jq`, they auto-discover their own
paths) so the same script drops into any repo unchanged.

**Tooling.**

- `init` stamps them (executable).
- `sync` re-copies them when the canonical versions change.
- `verify` checks they're present and executable, and unchanged from the installed release
  (see `verify`'s managed-file check below).

**Shared vs personal.** `settings.json` is **tracked** (shared machinery, `sync` owns it).
`settings.local.json` is **personal and never committed**.

**`CLAUDE.md`.** Every adopted repo has a root `CLAUDE.md`, the file Claude Code loads in full
at the start of every session. It holds standing instructions only (what belongs there:
section 4). The smallest one is the two paragraphs `init` stamps, both described below: the
first, on where work stands and who writes what; and the pointer to `CLAUDE.local.md`,
which may say that every other Claude directive for the repo is there. Without the first,
nothing a session loads at its start leads to the notice. `CLAUDE.local.md` is personal,
like `settings.local.json`: Claude Code loads it after `CLAUDE.md` in every session, and it
is **never committed**. Subfolders may carry their own `CLAUDE.md` under the same rule:
standing instructions only. <!-- (D34, F16; the smallest form: F22, 0.9.0) -->

- `init` stamps a minimal `CLAUDE.md` when the repo has none, and never overwrites one that
  exists. The stamp says personal directives, if any, go in `CLAUDE.local.md`; it does not
  claim that file exists, because a repo new to the standard seldom has one. <!-- (B149) -->
- The stamp's first paragraph says where work stands (`docs/tracking/STATUS.md` and the
  handoffs), tells the session to keep STATUS true (section 10), and points at
  `REPO-STANDARD.md` for who writes what, to be read before the first change. The rules
  themselves sit in the notice because `sync` replaces it; `init` writes `CLAUDE.md` once and
  `sync` never touches it. So a `CLAUDE.md` that was there before the standard, or that was
  stamped before 0.9.0, has that paragraph only when it is written in by hand. <!-- (F22) -->
- `verify` warns when an adopted repo has no root `CLAUDE.md` — a todo that blocks the
  `--strict` sign-off, like the front door's state section. It checks that the file is
  there, never what it says: the two paragraphs are a memo, not a mechanism.

**`REPO-STANDARD.md`.** Every adopted repo also has the standard's notice at its root: the same
text in every repo, saying that the repo follows repo-standard, which files the standard
manages (do not edit, move or delete them), which names the hooks and tools find by name, what
is generated, what is the repo's own, and how to check and update. Without it, the standard's
files are fingerprints nobody can read: `bin/` looks deletable and the `docs/` tree
restructurable, and either breaks the tooling quietly. <!-- (0.5.0) -->

Since 0.9.0 it also says **who writes what**, and how `STATUS.md` is kept. This document
does not travel: what an adopted repo gets is the notice, the `CLAUDE.md` stamp, the
skeletons' comments and the hooks' messages. So the rules a session must know before it
changes anything are gathered in the notice. `docs/dev-notes/` is the maintainer's
(section 2). The session keeps `STATUS.md` true, and the rest of it is the maintainer's
(section 10). A commit or a push waits for a go, with what changed shown first (section 8).
And there are the logoff rule and the handoff that says nothing about its own commit
(section 4). <!-- (D53, F22) -->

- `init` installs it and `sync` keeps it current, like the hooks: a local edit is replaced.
  Line 2 of every managed script points to it, and the README skeleton's map opens with it.
- `verify` warns when it is missing, or when it differs from the installed release.
- The standard's own source tree carries none: its notice is `template/REPO-STANDARD.md`.

**The `.gitignore` slot.** The rules that keep the two personal files out must live in the
repo's own `.gitignore` — not in a machine-global ignore, which protects only the machine that
has it and leaves every other clone one `git add -A` from committing your permissions or your
personal directives.

- The settings rule is the glob `.claude/settings.local.json*`: Claude Code rewrites the file
  atomically through temp siblings (`settings.local.json.tmp.<pid>.<hex>`) that an exact-name
  rule leaves as untracked noise — and one vanishing mid-`git add -A` aborts the whole add.
- The directives rule is the unanchored `CLAUDE.local.md` (or `**/CLAUDE.local.md`): Claude
  Code also reads a `CLAUDE.local.md` in any subdirectory, so a root-anchored
  `/CLAUDE.local.md` leaves those exposed and does not count as covered.
- `init` creates the `.gitignore` when absent and otherwise appends only the missing rule or
  rules, never rewriting ignores you authored (for the settings, the exact name plus a `.tmp.*`
  or `.*` sibling rule also counts as covered).
- The same append carries `bin/track`'s four temp-file rules (`tracker.md.tmp.*`,
  `tracker.html.tmp.*`, `tracker.md.data.*`, `tracker-hwm.tmp.*`) when the file lacks any of
  them (B148), so a repo that arrives with its own `.gitignore` gets the same net as one built
  from the skeleton.
- In a vendor-derived repo it also carries `bin/register`'s two (`DEVIATIONS.md.tmp.*`,
  `DEVIATIONS.html.tmp.*`), judged as `bin/register` itself is: from the flag in `init`, from
  the stamp in `sync` (B152). An authored repo gets neither.
- `verify` resolves *which file* supplies each rule — for `settings.local.json` and a temp
  sibling, for `CLAUDE.local.md` at the root and in a subdirectory — and warns unless it is a
  committed `.gitignore` inside the working tree: asking git whether the path is ignored is not
  enough, since it answers yes on a machine whose global ignore covers it while the repo stays
  unprotected. It also warns when either personal file is already committed.
- A **symlinked** `.gitignore` can never satisfy the slot: git 2.32+ refuses to read
  `.gitignore` (or `.gitattributes`) through a symlink at all, so a stow-style link protects
  nothing no matter what it carries — `sync` refuses it outright, `init` skips it, and `verify`
  names the symlink as the cause; replace the link with a regular file.

**The `.gitattributes` slot.** The machinery scripts must also stay **LF on every platform** —
a `core.autocrlf=true` clone otherwise checks them out with CRLF and every hook dies on the
`\r`'d shebang.

- `init` therefore maintains a `.gitattributes` slot under the same contract as the
  `.gitignore` slot: it creates a targeted block pinning only the machinery (`.claude/hooks/*`,
  `.githooks/*`, `.githooks/pre-commit.d/*`, `bin/track`, `bin/register` → `text eol=lf`) when
  the file is absent, appends that block when one exists but nothing covers the machinery, and
  never rewrites attributes you authored.
- `sync` does not manage this file, so a vendor-derived repo adopted before 0.4.0 adds the
  `bin/register` line by hand, and a repo adopted before 0.8.0 adds
  `.githooks/pre-commit.d/* text eol=lf` when it adds its first check (`verify` warns until
  it does; `.githooks/*` does not reach into the subfolder).
- The repo's own line-ending policy for everything else stays yours.

### 4. Session handoffs

**What.**

- `docs/AI/session-handoffs/session-handoff-YYYY-MM-DD-HHMM.md` — local time from
  `date +%Y-%m-%d-%H%M` when the file is written, never typed ahead (the Stop hook dates the
  newest handoff from this name). H1: `# Session handoff — YYYY-MM-DD HH:MM TZ`.
- A repo may add a label after the time, `session-handoff-YYYY-MM-DD-HHMM-<label>.md` (the
  checkout it was written in, say: `-main`); a label is letters, digits, `.`, `_` and `-`.
  Only these names, and a rollover's day files, count as handoffs to the Stop hook: another
  note kept in the folder, such as a kickoff brief named
  `session-handoff-YYYY-MM-DD-kickoff-<name>.md`, is never taken as the latest handoff.
- The current month's handoffs sit at the top level of that directory; past months are archived
  into `YYYYMM/` subdirectories.

**Why.** A handoff captures only what *isn't* already in git or the READMEs — the reasoning,
the dead ends, the "next concrete step." Monthly bucketing keeps the directory scannable
instead of accreting into an undated pile.

**A handoff says nothing about its own commit.** It is written before that commit. A line
that lists what is uncommitted, or that says the commit waits for a go, is out of date the
moment the commit lands, and the next session reads it as the current state. `git status`
shows what is uncommitted. A handoff keeps what git cannot show: decisions, a question that
waits for an answer, traps. The commits that did happen stay in its account of what changed.
<!-- (F22) -->

**The logoff rule.** Before the maintainer leaves, the session makes sure its work is in a
handoff. A session that changed nothing says so and writes none. Otherwise, first match
wins:

- any file changed since the newest handoff, a change to `docs/tracking/STATUS.md` alone
  excepted: write a new handoff now;
- otherwise, a handoff from the last 12 hours is enough;
- otherwise (an older one, or none): write one now.

During a session the Stop hook asks on a looser schedule, because it runs at the end of
every reply and cannot see a logoff coming. It does not ask within two hours of the newest
handoff, unless that handoff is named ahead of the clock. After that it asks when an
uncommitted file has changed since the handoff, and otherwise once the handoff is 12 hours
old. With no handoff at all, it asks. <!-- (D53) -->

**What goes in `CLAUDE.md`.** Standing instructions only (every adopted repo has one: section
3); anything that reads like "where I left off" belongs in `STATUS.md` or a handoff. A root
`CLAUDE.md` loads in full every session, and neither the hooks nor `verify` read it for where to
resume.

**Tooling.**

- The Stop hook asks for a handoff when one is due. Its message carries the two rules a
  session needs at that moment: the handoff says nothing about its own commit; and, where
  `docs/tracking/STATUS.md` exists, STATUS is checked and only what is no longer true is
  changed, in the same commit (section 10). <!-- (F22) -->
- The SessionStart hook nudges when top-level handoffs belong to a past month.
- `verify` reports the same drift as a warning.

**The rollover procedure** (this document is the reference; the SessionStart hook carries the
same steps inline so they travel with stamped repos). Per stale month `YYYY-MM`, bucket `YYYYMM`:

1. **Archive.** `mkdir -p YYYYMM`, then `git mv` the month's `session-handoff-YYYY-MM-*.md`
   into it — `git mv`, not a bare `mv`, so both sides of each move are staged in one step
   (history follows by content either way). `git mv` fails as a unit if any matched handoff is
   untracked (the normal state when a handoff was written but its commit is still gated):
   `git add` the untracked ones first, then move.
2. **Aggregate** same-day files into one file per day, named `session-handoff-YYYY-MM-DD.md` —
   the `-HHMM` suffix is dropped for a day file, and a day with a single handoff is renamed the
   same way. This is a **merge, not a delete**: read every same-day file before folding, because
   a later handoff often summarises the day while dropping specifics (traps, open questions,
   decisions) only the earlier one records. Note in the merged file that it is an aggregated day
   file. A verbatim fold — each original in order under its own heading, beneath a header line
   that says this is an aggregated day file and names every absorbed filename — satisfies this
   step (git credits the day file to at most one origin, so the header is what keeps the other
   names findable). Then `git rm -f` the absorbed originals: a plain `git rm` refuses files the
   `git mv` just staged.
3. **Repoint** inbound references: living docs cite handoffs by path, so grep for
   `session-handoff-YYYY-MM-` outside the handoffs dir and update each hit to the `YYYYMM/`
   path (and the day-file name where step 2 renamed it). Review the hits; never blind-sed.
4. **Re-verify** — the handoff-bucketing check should return to a pass.

### 5. Work tracker

**What.** One file, `docs/tracking/tracker.md`, with four categories — **Bugs / Features /
Documentation / Testing**.

- Every row carries a status, a stable ID (`B`/`F`/`D`/`T` prefix, zero-padded to at least two
  digits — `B01`, `F15`, `B142` — with unpadded nesting like `F12.2.1`; cite IDs as `track add`
  prints them), a Created date, and a Status Changed date.
- States are restricted per category and the per-category flow is displayed above each table.
- IDs and dates are **never hand-assigned** — they're maintained by `track`.
- Rows are **never deleted**: work that will not happen is retired in place with `dropped` /
  `cnr`, so every ID ever issued keeps resolving.
- An item that needs more than a one-line Description gets a section of its own, under one
  `## Details` heading after the four tables: `### <ID> — <Name>` (the row's Name exactly),
  then free text, written by hand. The Description stays a one-line summary. `track render`
  shows the section under its row and refuses one it cannot match to exactly one row.
- Backing that up, `track add` maintains a `docs/tracking/tracker-hwm` sidecar recording the
  highest ID ever issued per prefix, so once it exists a hand-pruned top-level row cannot cause
  its number to be reissued. The sidecar is **self-installing**: it is first written by the
  first *top-level* `track add` after this feature (a `--parent` add never writes it), seeded
  from the rows that survive at that moment — so a tracker that predates it has one unprotected
  window, and a row pruned *before* that first add is not remembered (child indices rely on
  surviving descendants either way — retire, don't delete). Hand-edits to the tracker must
  leave the sidecar alone. <!-- (B47; exact seeding/reseed semantics: ../docs/AI/design/track-script-spec.md) -->
- The interactive, sortable/filterable view is `tracker.html`, produced by `track render`.

**Why.** A single categorized file is enough structure to not lose work, and little enough to
not become a second job. Auto-maintained IDs and dates are what keep the record trustworthy —
"Status Changed" is only honest if a tool sets it. Sorting in the view was non-negotiable
because a static table stops being useful the moment it has more than a screen of rows.

**Tooling.**

- `track add` / `track set-status` mutate the file and auto-render the view.
- After a status change, `track set-status` prints one more line, on standard error, when
  `STATUS.md` beside the tracker names the row: the file, each line that names it, and the
  reminder to change only what is no longer true there, in the same commit (section 10).
  The line says that STATUS names the row, never whether STATUS is right, and it never stops
  the command. <!-- (F22) -->
- `track` looks for `docs/tracking/tracker.md`. In a repo that still keeps its tracker in
  `docs/dev-notes/`, the layout before 0.9.0, it stops before any command runs and says so.
  It does not go on to another repo's tracker or to `./tracker.md`; `TRACKER_FILE` still
  names a tracker anywhere. <!-- (F21) -->
- `track render --check` detects a stale view.
- `track history <ID>` prints an item's history from git: each version of its row and detail
  section, the commits that name it, and the files that cite it. Nothing is recorded; git
  already holds the record.
- The `pre-commit` guard blocks a commit whose view is out of date.
- Full behavior: `../docs/AI/design/track-script-spec.md`.

### 6. Commit guard

**What.** `.githooks/pre-commit` refuses a commit whose `tracker.html` is stale relative to
`tracker.md`, and, in a vendor-derived repo, one whose register summary or `DEVIATIONS.html`
is stale relative to `docs/official/DEVIATIONS.md` (see **The register** below). It judges
each pair as staged, not as in the worktree. Enabled per clone with
`git config core.hooksPath .githooks`.

**The repo's own checks** go in `.githooks/pre-commit.d/`, never in `pre-commit` itself (a
managed file, replaced by `sync`):

- After the standard's checks, the guard runs every executable file in that folder whose name
  is only letters, digits, `_` and `-`, in name order (C collation, so `10-lint` before
  `20-test`), from the repo root, on every commit. Each sees the commit's index as git set it
  up (`git diff --cached` lists what is being committed).
- Any check that exits nonzero blocks the commit, and the guard names it. All of them run, so
  one attempt shows every refusal.
- Other names (`*.sample`, `foo~`, `README.md`) are not run, so a folder can hold notes and
  switched-off examples. A file with a run-able name but no exec bit is reported and not run.
- The folder is the repo's own: `init` and `sync` never write into it, and `verify` lists the
  checks in run order and warns on one that cannot run (no exec bit in the worktree or in the
  index, or not pinned to LF).

**Why.** Auto-render on mutation covers the CLI path; the pre-commit covers the hand-edit path,
so the committed view can never silently drift from its source. A hook that isn't executable is
silently ignored by git — a disarmed guard is worse than none, because it looks safe.

**Tooling.**

- `init` stamps it executable.
- `sync` restores the exec bit if it's ever lost.
- `verify` warns if the hook is non-executable or `core.hooksPath` isn't wired, and on a check
  in `.githooks/pre-commit.d/` that cannot run.

### 7. Numbered-prefix ordering

**What.** Where a real sequence exists (setup stages, ordered runbooks), prefix directories/files
`00-…` … `99-…` so run order is legible from `ls` alone.

**Why.** Order that lives only in a human's head is context that's lost on the next session.
Encode it in the names. (Don't number things that aren't actually a sequence — that's false
structure.)

### 8. Version control

**What.** Everything durable is version-controlled. But get an explicit go-ahead from the
maintainer immediately before the actual `git commit` / `git push`, every time, and show what
changed first: `STATUS.md`'s diff above all, because a session edits that file itself
(section 10). <!-- (D53) -->

**Why.** Durability is the default; surprise commits are not. The gate keeps an agent from
committing on the human's behalf before the human has looked.

**Tags sort as versions.** Each clone sets `git config tag.sort version:refname`, so `git tag`
lists `v0.3.10` after `v0.3.9` — plain git sorts tags as strings and files it between `v0.3.1`
and `v0.3.2`. Per-clone config never travels with the repo, so it is set by hand, like the
commit guard's `core.hooksPath`. After any fresh clone, run the standard's `bin/verify` on it
and paste the two commands it names.

**Tooling.**

- `init` prints the command in its Next: block (it never sets per-clone config itself).
- `verify` warns when the setting is missing or differs. The commit gate itself stays unchecked
  — whether a commit was consented to is a judgment call.

### 9. Deprecated content

**What.** Retained-but-superseded material goes in one `z-deprecated/` directory at the repo
root (the `z-` sorts it to the bottom).

**Why.** Deleting loses history; leaving it inline creates false current-state. One convention,
out of the way but recoverable.

### 10. `STATUS.md` — where work stands

*(Section 10 since 0.9.0. It stands last so that sections 1 to 9 keep their numbers.)*

**What.** `docs/tracking/STATUS.md` is orientation, not history: 20 to 30 lines of pointers,
in three sections under the H1 `# WHERE AM I?`. The count is of what stands above the
skeleton's closing comment.

- `## NOW` holds only what is current, blocked work included. Finished work leaves for the
  handoffs.
- `## NEXT` holds tracker rows, in order, at most five. Work that has no row can queue there
  too, under a short name.
- `## EVENTUALLY` holds ideas that have no row yet. When one gets a row, it leaves.

A section with nothing in it keeps its heading, so a reader finds the same three in every
repo.

**The item line.** `<folder>: <ID>, <ID> · <status> · <words>`

- **The folder** and its colon are there only in a repo that holds several small projects
  ("One repo, several small projects", above).
- **The row or rows,** by ID. Rows that share an item share a status. Work with no row
  carries a short name in the rows' place.
- **The status** is the row's own, in the tracker's word (`open`, `in-progress` and the
  rest), on every item. A blocked item says `BLOCKED on <whom or what>`. Blocked is a
  status, not a section: it shows wherever the item sits.
- **What follows is free words:** what it is, and what picks it back up.

**Pointers to handoffs.** STATUS never points at the newest handoff, because every new
handoff would leave that pointer one behind. An item ends with a pointer only when the newest
handoff does not cover it, written as the stamp from the file's name,
`handoff YYYY-MM-DD-HHMM`, never as a path. The rollover's repoint step (section 4) searches
for paths, so a stamp never forces an edit of STATUS; and after a rollover the stamp's date
still leads to the handoff, in that day's file. When such an item moves: the handoff is
written, then STATUS is repointed, and both go into one commit.

**Who writes it.** The session keeps STATUS true. Whenever it writes a handoff, or changes a
tracker row's status, it checks STATUS, changes only what is no longer true, and puts that in
the same commit, where the maintainer sees it at the commit gate (section 8). Everything else
in STATUS is the maintainer's: what is in the queue, and in what order. A session asks first.

**Why.** STATUS says in half a minute what is being worked on and what comes next: it is
where the README skeleton's state section points (section 1). The handoffs hold the
history, and the tracker holds every row. It is short because a long one is not read.

- **The status word.** In the four repos that tried this shape, 12 items were blocked by
  their tracker row or by their line, and only 3 said so in both. With the tracker's word on
  every line, a finished row still under NOW, or a line that disagrees with its row, shows
  at a glance.
- **Kept true by the session.** STATUS is checked at two moments a session cannot miss: when
  it writes a handoff, and when it changes a row's status. A fact that changes with neither
  waits for the next handoff. A session that noticed a stale line, asked, and waited left it
  stale for hours; a session that changes the line shows the change at the commit gate, and
  the maintainer still decides.
- **Written where a session reads.** In one of those repos, finished work stayed under NOW
  with its commit hashes: no session there had ever seen the rules. They were written in a
  design note, and this document does not travel.

**Tooling.**

- `init` writes the skeleton: the H1, the three headings, and a comment that carries these
  rules in brief. The comment is at the bottom, where a session still reads it and a rendered
  page hides it.
- Three reminders reach a session where it works: the paragraph in `CLAUDE.md` (section 3:
  `init` stamps it into a new one, and it is written by hand into one that was there
  before), two sentences in the Stop hook's message (section 4), and the line
  `track set-status` prints (section 5). The rules in full are in the notice,
  `REPO-STANDARD.md`.
- The Stop hook leaves `docs/tracking/STATUS.md` out of its test for changed files: the file
  is kept true at every handoff, so an edit to it alone is not work without a handoff.
- `verify` warns when an adopted repo has no `STATUS.md`, or when it is not a regular file,
  and never reads it. `track set-status` looks in it for a row's ID and for nothing else. No
  tool reads the headings or the form of an item. A check for a STATUS that names a finished
  row is held back, a memo until drift says otherwise. <!-- (F22) -->

---

## Archetype slots (vendor-derived only)

- **`docs/reference/`** — received, authoritative source material you did *not* author (vendor
  PDFs, API specs, hardware manuals). Distinct from `docs/official/`, which is what *you* wrote.
  Keeping them separate means "what the vendor said" is never confused with "what we documented."
- **`docs/official/DEVIATIONS.md`** — the traceability bridge, or register: where the
  implementation diverges from `docs/reference/`, and why. This is the single most valuable
  artifact in a vendor-derived repo, because it's the part no amount of reading the code will
  tell you. It is documentation *you* authored about the vendor's material, so it lives in
  `docs/official/` under that home's rules, status line included; a pointer may sit wherever a
  build or a reader expects the register, never a second copy. <!-- (D47) -->
- **`docs/official/VENDOR-QUESTIONS.md`** — the questions for the vendor: what this repo needs
  to ask about `docs/reference/`, what was sent, and what came back (below). Authored like the
  register and kept beside it, under the same home's rules. <!-- (F18) -->
- **`bin/register`** — the register's tool (below). It is machinery, like `bin/track`, but
  only this archetype gets it.

An **authored** repo has none of them — and that absence is itself a signal. `verify` warns if
an authored repo has these slots (archetype mismatch) or if a vendor-derived repo is missing
them.

### The register

**What.** `DEVIATIONS.md` is written in a form a tool can check:

- a `## Types` table and a `## Sources` table (key, document, version, date, and a path
  relative to the register), both kept by hand;
- one `## N. Title` heading per entry, numbered from 1 in ascending order. Under each, one
  header line, then a blank line and the entry's reasoning:
  `*Type:* … · *Status:* active | moot | closed · *Original:* YYYY-MM-DD · *Updated:* dates or — · *Source:* <key> <location>; … or none`;
- a summary table between `<!-- register:begin -->` and `<!-- register:end -->`, generated
  and never edited by hand, and `DEVIATIONS.html` beside the register: a page like
  `tracker.html`, which also lists the files that cite each entry.

Code and docs cite an entry as `register N`. A closed entry stays in the file and keeps its
number, as the tracker keeps done rows.

**A new drop.** When the vendor sends a new version of its documents, every entry is re-read
against it: the Sources table takes the new versions, an entry that stands names its new
anchor (with a dated "Re-read …" note where something moved), and one the new documents
settle is amended or closed. The questions for the vendor are re-read in the same pass
(below). <!-- (F18) -->

**Why.** A register grows long (the first one adopted: 37 entries, 1,630 lines), its hand-kept
summary table drifted from the entries, and its citations took five forms. The tool keeps the
mechanical parts honest — the structure, the summary, where each entry is cited — and the
reasoning stays hand-written.

**Tooling.**

- `bin/register check` validates the form and reports `STALE` when a render is due;
  `bin/register render` regenerates the summary block and the page.
- `bin/register map` lists where each entry is cited, in the files that describe the build as
  it is now (`--all` for every tracked file). A citation of a missing entry is an error, of a
  closed one a warning.
- `bin/register history N` prints an entry's history from git: each version of its section,
  the commits that name it, and the files that cite it (as `map --entry N --all`).
- The commit guard checks the staged register (section 6), and `verify` runs `check` and
  `map --check`.
- A register without the marker pair is *not yet migrated*: `check` passes it, `render` and
  `map` refuse, and `verify` warns.
- Full behavior: `../docs/AI/design/register-script-spec.md`.

### Questions for the vendor

**What.** `VENDOR-QUESTIONS.md` holds one entry per question: a `## VQ07. Title` heading (IDs
from `VQ01`, zero-padded to two digits, never reused), one header line, then its text:
`*Status:* open | sent YYYY-MM-DD | answered YYYY-MM-DD | settled YYYY-MM-DD | withdrawn YYYY-MM-DD · *Source:* <key> <version> <location>; … · *Concerns:* register N, … or none · *Interim:* where it is recorded, or none`.

- **Status:** *open* until sent. *Settled* means our own evidence or a newer document answered
  it, with nothing to send or no reply needed.
- **Source** carries the document's version: the register's Sources table holds only each
  document's current version, so a bare key would move on with the next drop.
- **Concerns** names the register entries the answer would change; an entry that waits on the
  vendor cites the question.
- **Interim** is what the repo does until the answer, given as where that is recorded
  (`register N`, a script, a tracker row), or `none`. A register entry that holds an interim
  says so in its text, citing the question ("an interim, until VQ07 is answered"), so the
  register shows which of its divergences are provisional.
- **An answer** is recorded under its question, dated, with where it was applied, and is
  applied in the same piece of work: each entry it concerns is amended (its Updated gains the
  date) or closed, and the interim is kept as the outcome, changed or removed.
- **Batches.** What is sent together is a batch, listed in the file (its IDs, the drop it was
  asked against, the date sent, its tracker row) and tracked by one Documentation row:
  `open` until sent, `blocked` while the vendor answers, `done` when every question in it
  has an outcome. Questions written after a batch is sent go into the next.
- **A new drop:** every question not yet answered is re-read against it, as the register's
  entries are; one the new documents settle becomes *settled*, with the document and page.

Cite a question by its ID, `VQ07`, in prose, code comments and commit messages: one token,
which no line break can split, and no other numbering shares it.

**Why.** A vendor-derived repo collects questions for its vendor as it goes: contradictions
between documents, steps that do not work as printed, choices the documents leave open.
Without one home they scatter. In the first vendor-derived repo they grew in the register,
an audit's list and the handoffs, under three numbering schemes, one number naming two
different questions; none was sent and nothing tracked sending them, and an answer had no
path back to the entry waiting on it. A workaround that nothing marks as provisional quietly
becomes permanent.

**Tooling.**

- `init --vendor-derived` writes the file's skeleton, with this workflow in its intro, only
  when absent.
- `verify` warns when a vendor-derived repo has none, and counts the file as a vendor slot in
  an authored repo. Nothing reads its form or its citations: a memo, not a mechanism, until
  drift says otherwise. <!-- (F18) -->

---

## The toolkit (`../bin/`)

### `init <dir> --authored | --vendor-derived [--name N]`

Stamps `template/` into a repo, idempotently content-wise (never overwrites; reports add/skip).

- A git-repo target must be **clean** — a dirty tree, init's own uncommitted scaffold included,
  is refused unless `--allow-dirty` is passed (F10, the migration baseline).
- The target directory must already exist — a mistyped path errors instead of scaffolding a
  fresh tree at the typo.
- A repo that still keeps a tracking file in `docs/dev-notes/`, the layout before 0.9.0, is
  refused before anything is written, whatever the flags. The test, which `verify` and `sync`
  share: one of `tracker.md`, `tracker.html`, `tracker-hwm` or `STATUS` there, a link
  counting as a file, with nothing at its path in `docs/tracking/`. (`bin/track` makes the
  same test for the tracker alone.) `init` would otherwise write an empty tracker and STATUS
  beside the real ones. The files move first. <!-- (F21) -->
- Renders the initial tracker view **only when no `tracker.html` exists** (refreshing an
  existing page is `track render`'s job) and marks the hooks executable, so a fresh repo passes
  `verify` immediately.
- It installs `REPO-STANDARD.md`, the standard's notice (section 3), in every repo.
- In a vendor-derived repo it also installs `bin/register`, writes the register skeleton in its
  entry form (empty Types and Sources tables, the marker pair, no entries) and the skeleton of
  `VENDOR-QUESTIONS.md`, and renders `DEVIATIONS.html` on the same only-when-absent terms. Run
  on an adopted repo, it adds only what is missing: the way to add the questions file to a
  repo adopted before 0.7.0 that keeps none.
- The one exception to never-overwrites: an existing `.repo-standard-version` whose archetype
  disagrees with the flag you passed (or reads `(unknown)`) is **corrected** — the explicit
  flag is the record of truth, and only `init` knows it.

### `verify [dir] [--authored|--vendor-derived] [--strict]`

Read-only conformance lint over the *mechanical* rules above — the ones a script can decide.

- Three spine rules have **no check by design**: numbered-prefix ordering (7), the commit gate
  (8 — its tag-sort setting is checked; the gate itself cannot be), and `z-deprecated` (9) are
  judgment calls — whether a sequence is real, whether a commit was consented to, whether
  material is truly superseded — and `verify` judges structure, not quality (see Non-goals). <!-- unchecked-by-design named explicitly (D13) -->
- For what it does check: `FAIL` on real problems (missing front door, committed secrets, a
  stale tracker or register), `WARN` on drift, exit 1 on any `FAIL` (or any `WARN` under
  `--strict`).
- Read-only is literal: the tracker staleness check runs on a copy in a temp directory outside
  the audited tree, and the register's checks render into one.
- **A repo that has not moved.** Where a tracking file is still in `docs/dev-notes/` (the
  test is `init`'s, above), one line among the docs homes says so, in place of the checks on
  `docs/tracking/`, `STATUS.md` and the tracker, which wait for the move. Under a stamp older
  than 0.9.0 the line is a note and counts as nothing: the repo is laid out as its own
  version of the standard asks. Where no version can be read it is a note as well. Under a
  stamp of 0.9.0 or later it is a warning. <!-- (F21) -->
- In a vendor-derived repo it checks `bin/register` and runs `register check` and
  `register map --check`. A stale summary or `DEVIATIONS.html` is a `FAIL`, as a stale
  `tracker.html` is; everything else they find is a `WARN`, a register not yet migrated
  included. It warns when `docs/official/VENDOR-QUESTIONS.md` is missing, and never reads it.
- **Managed files.** The repo's stamp is compared with the `VERSION` of the standard checkout
  running `verify`: an older stamp warns that a newer version is available (run `sync`), a
  newer one that the checkout is behind (`git pull` it). Every managed file but
  `settings.json` is then compared with its copy **at the stamped version**, read from that
  version's tag in the standard checkout (`git show`, read-only). A difference warns, naming
  each file: it was edited here, or installed from an unreleased checkout. A checkout without
  that tag says it cannot check content, and the standard's own tree is not checked. Comparing
  with the release, not the current template, keeps a repo untouched since its last sync from
  reading as edited while unreleased changes sit in the standard.
- Judgments about *committed* state read the index, including the exec bit — a machinery file
  committed mode `100644` warns, because every clone receives it disarmed regardless of how the
  local copy looks.

**The secret check** matches on **filename and path, never on content**, so it cannot
distinguish a real leak from a file that is committed *on purpose* — a config profile whose
secret field is a placeholder, say. It never reads history or content either: a secret inside
a PDF, a screenshot, a ledger, a transcript or a copy of another repo's records is invisible to
it, so a green secret section is a verdict on structure, not on hygiene.

- The scan also skips tracked dependency trees (`node_modules/`, `.venv/`, `vendor/`) **by
  design** — a fixture shipped inside a vendored dependency is that project's artifact, not
  this repo's secret. <!-- (B24) -->

A deliberately committed secret-shaped file declares itself by carrying the marker

    repo-standard: allow-committed — <why, in one line>

in a comment within its **first 40 lines**; `verify` then reports it as a declared exception
instead of failing. The exception deliberately lives *next to the thing it excepts*, so it is
visible in every diff of that file and cannot rot in a central list.

- The marker is judged from the **committed blob** (`git show :file`), never the worktree — a
  marker you added but have not committed excuses nothing yet, exactly the mid-remediation
  state that used to read green.
- A file that cannot carry a text line (a binary keystore, say) declares itself instead through
  a **committed sidecar** `<file>.allow-committed` containing the same marker. So may a file
  that could carry the line but must stay byte for byte as it was received, a captured key or
  a vendor's file: `verify` accepts the sidecar beside any file, and which of the two a file
  uses is the repo's choice. <!-- (D50) -->
- The marker is the *mechanism* only — record the reasoning in `docs/official/DEVIATIONS.md`
  (vendor-derived)
  or the README (authored). Nothing else is waivable: an undeclared secret-shaped **file** that
  git tracks is always a `FAIL`.

### `sync [dir] [--check] [--force] [--downgrade]`

Re-copies the shared *machinery* (**six files**: the two Claude hooks, `.claude/settings.json`,
`.githooks/pre-commit`, `bin/track` and `REPO-STANDARD.md`; **seven** in a vendor-derived
repo, with `bin/register`, judged from the stamp) when it drifts from the standard,
with a diff per change and exec-bit repair — both the worktree bit and the **committed index
mode** (`100644` → `100755` via `git update-index --chmod=+x`; this stages a mode change, and
you still gate the commit); refreshes the version stamp.

- It also repairs the `.gitignore` slot for both personal files and the tools' temp files
  (`bin/register`'s in a vendor-derived repo only) under `init`'s exact contract (create from
  the skeleton when absent, append only the missing rules when uncovered, never rewrite
  authored rules; a symlinked `.gitignore` is refused outright — see the slot paragraph
  above). The slot, all its rules together, shares `sync`'s summary counter, so a healthy
  run reads `7 unchanged`, not 6 (`8 unchanged` in a vendor-derived repo).
- It re-renders an existing `tracker.html` when `bin/track` itself was updated — a renderer
  change stales the page with no `tracker.md` edit, which is the one drift the commit guard
  never fires on.
- It does **not** re-render the register: the summary block lives inside the authored
  `DEVIATIONS.md`. When an updated `bin/register` would change the generated parts, `sync`
  prints a note with the command (`bin/register render`) and counts no drift.
- Never touches authored content, never writes through a symlink — whether the link is the
  destination itself or any parent directory on the way there — or onto a non-regular file (the
  destination is replaced, or the write is refused loudly).
- A target that still keeps a tracking file in `docs/dev-notes/` (the test is `init`'s, above)
  stops it before anything is written: exit 2, naming each file and where it goes. `--check`
  reports such a repo as out of date, one `MOVE` line per file, and exits 1. Moving an
  authored file is not `sync`'s job, so the files move first and `sync` runs after. The
  standard's own tree is held to the same test. <!-- (F21) -->
- A symlinked machinery destination is refused **even while its content matches the canon** (a
  stow-style consumer can never be green): sync can never manage that file, so it fails early,
  not on the day the template first changes.
- A target stamped by a **newer** standard than this checkout refuses to sync (version order,
  not string comparison) — a stale clone must not roll machinery backwards; `--downgrade` (its
  own flag, so a deliberate rollback cannot silently also clobber a customized `settings.json`
  the way overloading `--force` would) stands for a deliberate downgrade.
- `settings.json` is the one machinery file a repo may legitimately customize, so it is never
  auto-overwritten: a target copy that differs but still wires the standard's hooks is **kept**
  (local keys preserved); one that differs and does not wire them is a **conflict** to merge by
  hand (`--force` takes the canonical file).
- `--check` reports drift and exits 1.
- In the standard's own source tree, `sync --force .` is **dogfood mode**: it propagates
  `template/` into the repo's live copies (previously a hand step) and writes no version stamp
  and no `REPO-STANDARD.md` — the source is not its own consumer.

### `fleet [entry …] [--scope FILE] [--write [FILE]] [--check [FILE]] [--offline] [--jobs N]`

The adoption registry — maintainer-side, never shipped to consumers. Asks git, not the disk,
so any host serves (GitHub, GitLab, Gitea, SourceForge, cgit, gitweb, a local path). The scope
is a file, `docs/dev-notes/fleet-scope` by default, one entry per line: `github.com/OWNER`,
every repository of that GitHub user or organization the `gh` token can see, forks and
archived ones left out (the one host-specific line, and the only thing that needs `gh`); a
clone URL (`https://`, `ssh://`, `git://`, `git@host:path`, or a local path), one repository
on any host, always included; `-host/path`, left out; `#` comments. Entries on the command
line add to it in a print-only run. Prints one table: repo as `host/path`, status, adoption
date, version adopted, current version, last synced, archetype, clone URL.

- Each repository is mirrored bare and blobless under `$XDG_CACHE_HOME/repo-standard/fleet`
  (default `~/.cache/…`) and fetched on every run, N at a time (default 4; the first run
  clones). A host without partial-clone support gets a full mirror, which is only slower.
  Credentials are git's own — the `gh` credential helper for GitHub over https, ssh keys, or
  whatever the host uses; a repository that asks for a password is an error, never a prompt.
- Everything is read from the **default branch as pushed to the host**, so a migration in
  progress, a stamp not yet committed or a branch that is not the default never shows: a row
  changes when a push lands. The adoption date and version come from **git** — the first
  commit that added `.repo-standard-version` and that commit's copy of the stamp — because
  `sync` rewrites the stamp's date on every refresh; the stamp's own date is reported as
  "last synced".
- Statuses: `adopted`; `not adopted`; `empty` (no commit on the default branch); `source`
  (holds `standard/STANDARD.md` and `VERSION`; current = `VERSION`).
- `--write` refreshes the block between `<!-- fleet:begin -->` and `<!-- fleet:end -->` at the
  top of `docs/dev-notes/adoption.md` (or FILE), creating it after the H1 when absent — the way
  `track render` owns `tracker.html`; the prose around it stays hand-authored. `--check` exits
  1 when that block is missing or stale. Both take the scope file alone, so the committed
  table is reproducible from it, and both fetch: `--offline`, which reads the mirrors as they
  are, is for a print-only run.
- An entry that cannot be listed or fetched is reported on stderr: the table is printed
  without it and the exit is 1; `--write` and `--check` then write nothing and exit 2.

The split is deliberate: the toolkit executes the **mechanical spine** (deterministic
scaffolding, checking, copying) and leaves the **judgment** (what to write, when to roll a
tracker item forward) to the human and the agent.

---

## Principles (why the standard is shaped this way)

- **Sync-from, not depend-on.** A consumer repo vendors its own copies of the machinery and stays
  fully self-contained. The standard is upstream, never a runtime dependency — `sync` pulls updates
  in on request; nothing breaks if the standard repo is absent.
- **Execute the mechanical, describe the rest.** Anything deterministic (structure, checks, copies)
  is a script. Anything requiring judgment stays prose in this document. Don't automate judgment.
- **Mechanism vs memo.** Before adding a rule, ask whether it needs to be *enforced* (a mechanism —
  a hook, a `verify` check) or merely *remembered* (a memo — a line here). Prefer the memo until the
  drift actually bites; only then promote it to a mechanism.
- **Lean for an audience of one, guarded against context loss.** The maintainer is currently the
  only user, so there's no governance, config surface, or ceremony. But "just me" forgets things —
  hence the handoffs, the tracker, and the front door. The standard fights context loss, not
  hypothetical scale.

---

## Non-goals (revisit only on a real, felt need)

- **No enforced state-machine transitions** in the tracker — a restricted state *set* plus a
  *displayed* flow is enough; policing every transition is ceremony.
- **No tracker backend or live-editing web app** — the view is read-only; all edits go through
  `track`, which is what keeps the auto-fields honest.
- **No semver tooling, config files, or governance** while the audience is one person.
- **No auto-generation of the transfer prompt** from this file — it's kept in step by hand; a
  generator is more machinery than the drift justifies.
- **`verify` judges structure, not quality** — it checks that the front door exists, not that it's
  well-written. Taste stays human.
