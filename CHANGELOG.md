# Changelog

Releases before 0.5.0 were made privately; their notes are not published.

## 0.9.0 — 2026-11-13
The tracker and STATUS get a home of their own, `docs/tracking/`, and `docs/dev-notes/` holds
the maintainer's own notes and nothing else. STATUS gets a decided shape, and the rules on who
writes what in an adopted repo now travel with the repo, in its notice. Three managed files
change: the tracker tool, the Stop hook and the `REPO-STANDARD.md` notice. **An adopted repo is
moved by hand before it syncs:** `sync` stops on a repo that has not moved (Upgrading, below).

- **Changed (F21): the tracker's three files and STATUS live in `docs/tracking/`.**
  `tracker.md`, `tracker.html` and `tracker-hwm` keep their names, and `STATUS` becomes
  `STATUS.md`. They sat in `docs/dev-notes/`, under the rule that the folder is the
  maintainer's own notes and Claude does not overwrite them. That rule described neither
  file any more: a tool keeps the tracker, and sessions edit STATUS on the maintainer's go.
  `docs/tracking/` is now the third required home. `docs/dev-notes/` is created on first use
  and no longer checked, like `docs/assets/`.
- **No tool reads both layouts.** A repo still keeps the old one when a tracking file sits at
  its old path, a link counting as a file, with nothing at its new path. On such a repo:
  - `sync` stops before it writes anything, exit 2, naming each file and where it goes.
    `sync --check` reports the repo as out of date, one `MOVE` line per file, exit 1.
  - `init` refuses before it writes anything, whatever the flags.
  - `verify` says so in one line, in place of its checks of `docs/tracking/`, `STATUS.md` and
    the tracker: a note under a stamp older than 0.9.0, a warning from 0.9.0 on.
  - `bin/track` stops before any command runs, when the tracker itself is still there. It
    does not go on to another repo's tracker or to `./tracker.md`. `TRACKER_FILE` still names
    a tracker anywhere.
- **`init` writes the new layout:** `docs/tracking/STATUS.md`, the tracker and its page, and
  no `docs/dev-notes/`. The two skeletons moved to `template/docs/tracking/`.
- **The Stop hook** leaves `docs/tracking/STATUS.md` out of its test for changed files, and
  no longer `docs/dev-notes/STATUS`: a note of that name now counts like any other file.
- **Added (F22): STATUS has a shape, and a rule for keeping it true.**
  - Three sections: `## NOW`, `## NEXT` and `## EVENTUALLY`. 20 to 30 lines of pointers.
  - An item reads `<folder>: <ID>, <ID> · <status> · <words>`, with the status in the
    tracker's own word.
  - A pointer to a handoff ends an item only when the newest handoff does not cover it, and
    is written as the stamp from the file's name.
  - The session keeps STATUS true. Whenever it writes a handoff or changes a tracker row's
    status, it checks STATUS, changes only what is no longer true, and puts that in the same
    commit. Everything else in STATUS is the maintainer's.
  - STANDARD.md has a new section 10 for all of it, and the STATUS skeleton carries the rules
    in a comment at its bottom.
- **Three reminders reach a session where it works** (F22):
  - a paragraph in the `CLAUDE.md` that `init` stamps;
  - two sentences in the Stop hook's message: a handoff says nothing about its own commit;
    and, where `docs/tracking/STATUS.md` exists, check it and change only what is no longer
    true;
  - one line from `track set-status`, on standard error, when `STATUS.md` beside the tracker
    names the row it has just changed. The line gives the file and each line that names the
    row. It judges nothing and never stops the command.
- **Added (D53): the notice says who writes what.** `REPO-STANDARD.md` gains two sections,
  "Who writes what" and "STATUS". STANDARD.md does not travel into an adopted repo, and the
  notice does. The rules: `docs/dev-notes/` is the maintainers' own; the session keeps STATUS
  true, and the rest of it is the maintainers'; a commit or a push waits for a go, with what
  changed shown first; before a maintainer leaves, the session writes a handoff if anything
  changed; a handoff says nothing about its own commit. STANDARD.md states them in its
  sections 2, 4, 8 and 10. The logoff rule had been in the transfer prompt only.
- **Changed: the smallest `CLAUDE.md`.** It was the statement that all Claude directives for
  the repo are in `CLAUDE.local.md`. It is now the two paragraphs `init` stamps: the first, on
  where work stands and who writes what, and the pointer to `CLAUDE.local.md`. Without the
  first, nothing a session loads at its start leads to the notice. `verify` checks that the
  file is there and never what it says; its warning for a missing one names the two
  paragraphs.
- **Changed (D50): the allow-committed sidecar** also serves a file that could carry the
  marker line but must stay byte for byte as it was received: a captured key, a vendor's
  file. `verify` already accepted the sidecar beside any file; STANDARD.md now says so.
- **Smaller:** `sync --help` and `init --help` print their whole header. Each had cut it at a
  fixed line.
- **Docs:** STANDARD.md (sections 2, 3, 4, 5, 8 and the new 10, the toolkit, the secret
  check), the `REPO-STANDARD.md` notice, the README and `CLAUDE.md` skeletons, the transfer
  prompt, and the specs of the tracker tool and of the notice.
- **Tests,** private like the other suites. `tests/tracking-layout.sh` is new: 502 cases at
  this version, for `sync`, `verify`, `init`, the tracker tool, a repo's move and the words a
  repo receives. `tests/stop-hook.sh` grows from 12 cases to 32, and `tests/publish.sh` from
  63 to 73. Six more suites follow the move. All thirteen suites: 1140 cases.
- **Upgrading:** an adopted repo is moved before it syncs. Until it is, `verify` run from
  this checkout names the move in one line and reports that 0.9.0 is available. From a clean
  tree:
  1. `mkdir -p docs/tracking`, then `git mv` each file that exists: `tracker.md`,
     `tracker.html` and `tracker-hwm` from `docs/dev-notes/` to `docs/tracking/` under the
     same names, and `docs/dev-notes/STATUS` to `docs/tracking/STATUS.md`. `git mv` keeps each
     file's history, and `track history` follows a row across the move. Remove
     `docs/dev-notes/` if that leaves it empty.
  2. `bin/sync <repo>` from a 0.9.0 checkout. It brings the tracker tool, the Stop hook, the
     notice and the stamp.
  3. Search the repo for `docs/dev-notes`, scripts before documents, and repoint each living
     mention. The README and `CLAUDE.md` name STATUS and the tracker. Dated records, such as
     handoffs, stay as they are.
  4. Bring `STATUS.md` into the shape. The notice's STATUS section says how, and each
     item's status word comes from the repo's own tracker.
  5. Write the stamp's first paragraph into `CLAUDE.md` by hand; `template/CLAUDE.skel.md`
     has it. `sync` never touches that file.
  6. `bin/verify <repo> --strict`, then one commit.

The README State section says 0.9.0.

## 0.8.0 — 2026-11-06
A repo can now add pre-commit checks of its own. Two managed files change, the commit guard
and the `REPO-STANDARD.md` notice; `init` and `verify` learn the new folder. Every adopted repo
syncs; nothing changes for a repo until it adds a check.

- **Added (F19): `.githooks/pre-commit.d/`, the repo's own pre-commit checks.** The guard
  (`.githooks/pre-commit`) is a managed file, replaced on every update, so a repo had nowhere
  to put a check of its own. Now, after the standard's checks, the guard runs every executable
  file in that folder whose name is only letters, digits, `_` and `-`, in C name order (taken
  under `LC_ALL=C`, so the locale never reorders them), from the repo root, on every commit.
  Any that exits nonzero blocks the commit and is named; all of them run, so one attempt shows
  every refusal. Other names (`*.sample`, `foo~`, `README.md`) are not run; a run-able name
  without the exec bit is reported and not run. `init` and `sync` never write into the folder.
  The guard used to exit at once when no tracker or register file was staged; that exit now
  skips only the standard's checks.
- **`verify`** lists the repo's checks in run order and warns on one that cannot run: no exec
  bit, committed without it, or not pinned to LF.
- **`.gitattributes`:** the skeleton and the block `init` appends gain
  `.githooks/pre-commit.d/* text eol=lf`, since `.githooks/*` does not reach into a
  subfolder. `sync` does not manage `.gitattributes`, so a repo adopted earlier adds the line
  with its first check; `verify` warns until it does.
- **Docs:** STANDARD.md section 6 and its `.gitattributes` slot, the `REPO-STANDARD.md`
  notice, and the transfer prompt describe the folder.
- **`tests/pre-commit-checks.sh`** — 22 cases (one check passing and one refusing, several in
  C order under a dictionary-order `LC_ALL`, the names that are not run, a check without the
  exec bit, a check reading the index, a commit from a subfolder, the tracker check still
  blocking beside them, and `verify`'s listing and three warnings); 12 fail against 0.7.3's
  hook. Private, like the other suites.
- **Upgrading:** `bin/sync <repo>` in every adopted repo, which takes the guard, the notice
  and the stamp; `verify` run from this checkout reports 0.8.0 available until then.

The README State section says 0.8.0.

## 0.7.3 — 2026-11-05
One template file changes, the Stop hook, for two fixes; STANDARD.md section 4 gains a bullet
and the transfer prompt's exit rule is rewritten. Every adopted repo syncs.

- **Fixed (B154): the Stop hook could take the wrong file as the latest handoff, or date it
  wrongly.** It ranked every `session-handoff-YYYY-MM-DD*.md` name by sorting, and read a time
  only from a name ending `-HHMM`. An adopted repo that labels each handoff with its checkout,
  `session-handoff-YYYY-MM-DD-HHMM-main.md`, and keeps kickoff briefs in the same folder,
  `session-handoff-YYYY-MM-DD-kickoff-<name>.md`, met both halves: a kickoff brief sorted after
  every timestamped handoff of its day and was taken as the latest, dated by its own older
  mtime, so the hook asked for a handoff on every stop; and a labelled handoff was dated by its
  mtime, not its name. Now only handoff-shaped names compete (a day file, `-HHMM`,
  `-HHMM-<label>`), ranked by the date and time in the name, and the time is the four digits
  after the date, whatever label follows. One side effect: a day file ranks at noon of its day,
  as it was already dated, rather than after that day's timestamped handoffs by name; day files
  appear only after a rollover, where the two do not meet.
- **Changed (B155): the Stop hook waits two hours, not 30 minutes, before a change makes a
  handoff due.** The hook runs at the end of every reply, not only at logoff, so a 30-minute
  grace asked for a handoff after nearly every change in a working session. The logoff is
  where every change counts, and a hook cannot see it coming, so that check is the session's:
  the transfer prompt's exit rule (section 7) now reads any change since the last handoff,
  else one within 12 hours, else write one. Its 30-minute tier is gone, redundant once no
  change has happened. Section 8 describes the hook's two-hour grace.
- **STANDARD.md section 4:** a handoff may carry a label after its time,
  `session-handoff-YYYY-MM-DD-HHMM-<label>.md` (letters, digits, `.`, `_`, `-`); other notes
  kept in the folder are never taken as the latest handoff.
- **`tests/stop-hook.sh`** — the Stop hook's first suite: 12 cases (plain, labelled both ways,
  a same-day kickoff brief, a kickoff brief alone, a stray notes file, day files current and
  archived, the two-hour grace both ways), each a git repo with one uncommitted edit at a
  chosen age; 6 fail against 0.7.2's hook. Private, like the other suites.
- **Upgrading:** `bin/sync <repo>` in every adopted repo, which takes the hook and the stamp;
  `verify` run from this checkout reports 0.7.3 available until then.

The README State section says 0.7.3.

## 0.7.2 — 2026-11-04
One template file changes, one line of its text: the rollover nudge's step 3. Every adopted
repo syncs.

- **Fixed (B153): the rollover nudge's step 3 filter dropped nothing under Claude Code's
  grep.** The nudge told the session to find the living docs that cite a prior-month handoff
  with `grep -rn … | grep -v ^./<handoffs dir>/`, a filter anchored on the `./` prefix that GNU
  `grep -r` prints. In Claude Code's shell, `grep` is a function that runs the Claude binary as
  ugrep, which prints no `./`, so the filter kept every hit, the handoffs' mentions of each
  other included, and the repoint list was wrong in every adopted repo (first seen at an
  adopted repo's October rollover, 2026-11-03). The unquoted form also broke on a handoffs
  path with a space. The filter now matches the path field with and without the prefix,
  `grep -v -e '^./<dir>/' -e '^<dir>/'`, single-quoted. It carries no backslash and no `-E`
  on purpose: the message is hand-built JSON, where `\.` is an invalid escape and the nudge
  would never arrive, and `-E` would let a `+` or `(` in the path disable the filter. Scripts
  never saw the bug: the function is not exported, so the hook and the tools run GNU grep.
- **`tests/rollover-hook.sh`** — the first suite for a hook: the nudge parses as JSON and is
  silent for the current month; its step 3 command finds the living docs and none of the
  handoffs under GNU grep and under ugrep (the Claude binary, run the way the shell function
  runs it), with the pre-fix filter as the control; a handoffs path with a space and
  parentheses too. Private, like the other suites.
- **Upgrading:** `bin/sync <repo>` in every adopted repo, which takes the hook and the stamp;
  `verify` run from this checkout reports 0.7.2 available until then.

The README State section says 0.7.2.

## 0.7.1 — 2026-11-03
The maintainer's decision while adopting a repo that holds several small projects in one tree:
such a repo is still authored, not a third archetype, and four conventions carry the shape.
Docs only: no tool behaviour and no template file changes, so no fleet sync is owed.

- **One repo, several small projects** — `standard/STANDARD.md` gains a subsection under the
  archetypes and the transfer prompt (section 1) the same rule: a folder per project, each with
  its own README beside its scripts; the README's map one line per folder; `STATUS` lines and
  tracker row names starting with the folder name; one dated handoff stream at the root, each
  handoff's first line naming its folder, never a HANDOFF file in a folder; a folder leaves for
  a repo of its own when it stops being play. All memo, no mechanism: `verify` checks none of
  it, and one project per folder with its own homes and hooks was rejected as ceremony.
- **The look behind it** — the first such repo came to adoption with three per-folder HANDOFF
  files, each a multi-session log outside the homes, and a two-line front door: the handoffs
  split into day files with a provenance line each, the tracker's rows and every STATUS line
  took the folder's name first, and the one folder that had grown into a real tool got its
  README. The archetype stayed authored throughout; nothing about the slots changed.
- **Upgrading:** nothing to sync but the stamp; until a repo syncs, `verify` run from this
  checkout reports that 0.7.1 is available.

The README State section says 0.7.1.

## 0.7.0 — 2026-10-16
A vendor-derived repo gets a home for its questions to the vendor, beside the register, and the
standard now says what to do when the vendor sends a new version of its documents.

- **`docs/official/VENDOR-QUESTIONS.md`:** a new slot of the vendor-derived archetype, authored
  like the register and kept beside it. One entry per question: a `## VQ07. Title` heading
  (IDs from `VQ01`, never reused), one header line (`*Status:*`, `*Source:*` with the
  document's version, `*Concerns:*`, `*Interim:*`), then its text. A question is cited by its
  ID, `VQ07`. Its status is *open*, then *sent*, *answered*, *settled* or *withdrawn*, each
  with its date. An answer is applied in the same piece of work to the register entries it
  concerns, and an entry that exists only as an interim workaround says so and cites the
  question. What is sent together is a batch, listed in the file and tracked by one
  Documentation row. No tool reads the file.
- **A new drop:** STANDARD.md now states the re-read for both: when the vendor sends a new
  version of its documents, every register entry and every unanswered question is re-read
  against it.
- **`init --vendor-derived`:** writes the file's skeleton, with the workflow in its intro, only
  when absent. Run on an already adopted repo, it adds only what is missing.
- **`verify`:** warns when a vendor-derived repo has no `docs/official/VENDOR-QUESTIONS.md`, and
  counts the file as a vendor slot when it finds one in an authored repo. It checks presence
  only.
- **Docs:** STANDARD.md (the archetype slots, The register, a new section, the toolkit),
  `REPO-STANDARD.md` (the file among the fixed names), the transfer prompt (section 1), and
  the notice's spec.
- **Upgrading:** `sync` brings the new `REPO-STANDARD.md` to every adopted repo, authored ones
  included; nothing else changes for an authored repo, and no page is re-rendered. In a
  vendor-derived repo `verify` then warns until the questions file exists: move a list of
  questions kept elsewhere to that path (with its IDs in the `VQ` form and its citations
  rewritten), or run `init` on the repo for the skeleton. Until the sync, `verify` reports
  that 0.7.0 is available.

Tested with a new suite, `tests/vendor-questions.sh` (40 checks, 23 of which fail on 0.6.1;
the others check for absence or a refusal), and the release's other suites (113, 35, 48, 97,
73, 68 and 58 checks), each passing.

The README's State section says 0.7.0.

## 0.6.1 — 2026-10-15
A fix for 0.6.0: one of `bin/register`'s own comments read as a citation.

- **`bin/register`:** a comment that 0.6.0 added for `register history` had the word
  "register" followed by a number, which `register map` counts as a citation. `bin/register`
  is one of a vendor-derived repo's live files, so every such repo showed a citation of entry
  20 that no one wrote: an error ("no such entry") in a register with fewer than 20 entries,
  and in a longer one a false citation that also left `DEVIATIONS.html`'s citations behind the
  files until the next render. The comment is reworded. No code changed.
- **Upgrading:** in a vendor-derived repo, `sync` brings the corrected `bin/register`; an
  authored repo already on 0.6.0 receives only the new stamp. A vendor-derived repo that
  rendered its register under 0.6.0 should run `bin/register render` after the sync, so its
  page drops the false citation. Until then `verify` reports that 0.6.1 is available.

Tested with the register map suite, which now scans each of the standard's managed files and
expects no citation in any (97 checks; on 0.6.0's `bin/register` the new case fails, on
0.5.3's it passes), and the release's other suites (113, 35, 48, 73, 68 and 58 checks), each
passing.

The README's State section says 0.6.1.

## 0.6.0 — 2026-10-15
A tracker item can now carry more than a one-line Description, and both tools can show an
item's history, read from git. The two features share one minor release because both change
`bin/track` and its spec.

- **Detail sections:** an optional `## Details` section after the tracker's four tables, with
  a `### <ID> — <Name>` heading (the row's Name exactly) for each item that needs more room,
  then free text written by hand. `track render` shows an item's text in its expanded row,
  after the Description, as plain text with its line breaks kept, and the page's search covers
  it. Render refuses, naming each line, what it cannot match to exactly one row: a malformed
  item heading, an ID with no row, a second section for one ID, a name that differs from the
  row's, and a second `## Details` section. `add` and `set-status` never touch the section,
  and a table row quoted inside it is never a row. The tracker skeleton ends with an empty
  `## Details` section, and its header comment names it.
- **`track history <ID>`:** prints the item's history from git, oldest first:
  - each committed version of its row and detail section, naming what changed (the status
    with its date, Created, the Name, the Description's length, the detail's lines);
  - a last `uncommitted` line when the working copy differs;
  - the commits whose messages name the ID;
  - the tracked files that cite it: live files by name, and records in `docs/AI/` and
    `z-deprecated/` counted per folder.

  Outside the standard's source repo, the standard's managed files are left out of the
  citations, since their comments cite the standard's own IDs. A row deleted by hand still
  shows, its versions ending in `row removed`. Read-only, and nothing is recorded.
- **`register history <N>`:** the same for a register entry:
  - each version of its section, naming what changed (the text, the title, each header field);
    the commit that numbered the register's entries is flagged, since the entry may be older;
  - the commits whose messages name it in any of five forms (`register N`,
    `register entry N`, `register entries N`, `DEVIATIONS § N`, `DEVIATIONS #N`), each message
    read with its lines joined;
  - the files that `register map --entry N --all` lists.
- **Docs:** `standard/STANDARD.md` (section 5 and The register), `REPO-STANDARD.md`, the
  transfer prompt (section 5), and the two tools' specs.
- **Upgrading:** `sync` brings the new `bin/track`, `bin/register` (in a vendor-derived repo)
  and `REPO-STANDARD.md`, and re-renders `tracker.html`, whose page changed. An existing
  tracker gets no Details section: add the heading by hand when an item first needs one. Until
  then `verify` reports that 0.6.0 is available.

Tested with two new suites, `tests/track-details.sh` (35 checks, 20 of which fail on 0.5.3) and
`tests/history.sh` (113 checks on fixture repositories, 78 of which fail on 0.5.3), and the
release's other suites (48, 91, 73, 68 and 58 checks), each passing. The page was checked in
headless Firefox. The history commands also ran on the standard's own tracker and, read-only,
on a vendor-derived repo's tracker and on every entry of its register (37 entries, 62
versions), where the commit counts equal a direct search of the repo's 318 commit messages.

The README's State section says 0.6.0.

## 0.5.3 — 2026-10-14
`bin/fleet` reads the fleet from its git hosts instead of the folders on one machine, and
`init` and `sync` give a vendor-derived repo's existing `.gitignore` the register's temp-file
rules, closing the gap 0.5.2 left (B152).

- **`bin/fleet`:** the scope is a file, `docs/dev-notes/fleet-scope`, one entry per line:
  `github.com/OWNER` (every repository of that GitHub user or organization the `gh` token can
  see, forks and archived ones left out; the one line that needs `gh`), a clone URL on any
  host (`https://`, `ssh://`, `git://`, `git@host:path`, or a local path; always included),
  `-host/path` (left out), and `#` comments. Each repository is mirrored bare and blobless
  under `$XDG_CACHE_HOME/repo-standard/fleet` and fetched on every run, four at a time
  (`--jobs N`), and everything is read from the default branch as pushed to the host, so a
  migration in progress or a branch that is not the default never shows. Rows are named
  `host/path`, and the URL column shows the clone URL. The adoption date and version still
  come from the first commit that added the stamp, so an existing row keeps its facts and
  changes only its name. New: the `empty` status, `--offline` (print only, from the mirrors)
  and `--scope FILE`; an entry that cannot be listed or fetched is reported on stderr, the
  table is printed without it with exit 1, and `--write` and `--check` then write nothing
  (exit 2). Gone: the directory arguments, the `stamp uncommitted` and `stamp removed in
  worktree` statuses, and the alignment colons in the separator row (the rule since 0.5.0).
  Needs git; `gh`, logged in, only for owner lines.
- **`init` and `sync`:** in a vendor-derived repo — the flag in `init`, the stamp in `sync`,
  as for `bin/register` itself — an existing `.gitignore` gains whichever of the register's
  two temp-file rules (`DEVIATIONS.md.tmp.*`, `DEVIATIONS.html.tmp.*`) it lacks, beside the
  tracker's four from 0.5.2; an authored repo gains neither (B152).
- **`standard/STANDARD.md`:** the `.gitignore` slot and `sync` name the register rules; the
  `fleet` section is rewritten.
- **Upgrading:** nothing in `template/` changed. `sync` refreshes the stamp and, in a
  vendor-derived repo, adds the two register rules. Until then `verify` reports that 0.5.3 is
  available. A `fleet` block written by 0.5.2 reads as stale under 0.5.3, since the rows are
  renamed: write the scope file, then `bin/fleet --write`.

Tested with the new `tests/fleet.sh` (68 checks, against bare repositories on disk and a stub
`gh`, no network), the `.gitignore` slot's suite (73 checks, 15 of which fail on 0.5.2) and the
release's other suites (58, 48 and 91 checks), each passing; and one live run of `fleet`, whose
existing rows matched the 0.5.2 table in every fact column.

The README's State section says 0.5.3.

## 0.5.2 — 2026-10-05
`init` and `sync` now give a repo that comes with its own `.gitignore` the same temp-file
rules as a repo whose `.gitignore` comes from the skeleton.

- **`init` and `sync`:** when a `.gitignore` already exists, they append whichever of
  `bin/track`'s four temp-file rules (`tracker.md.tmp.*`, `tracker.html.tmp.*`,
  `tracker.md.data.*`, `tracker-hwm.tmp.*`) it lacks, beside the two personal-file rules they
  already added. Before, only a repo with no `.gitignore` got them. A rule undone by a later
  `!` line counts as missing, the `**/` spelling counts as present, nothing is added twice,
  and `sync --check` reports the missing rules without writing.
- **`standard/STANDARD.md`:** the `.gitignore` slot names the four rules, and `sync`'s
  paragraph says it repairs them too.
- **Upgrading:** nothing in `template/` changed. `sync` refreshes the stamp and adds any of the
  four rules a repo's `.gitignore` lacks. Until then `verify` reports that 0.5.2 is available.

Tested with the `.gitignore` slot's suite (36 checks, 17 of which fail on 0.5.1) and the
register tool's suites (48 and 91 checks), each passing on the release.

The README's State section says 0.5.2.

## 0.5.1 — 2026-10-02
The first public release. The standard and the tools behave exactly as in 0.5.0; this release
prepares them for publication, so no file names a private repository any more.

- **Comments** in `bin/init`, `bin/verify` and `bin/track` that named the repository where a
  problem was found now describe the problem instead. No code changed.
- **`standard/STANDARD.md`:** the archetype examples and the register's size example describe
  the kind of repository instead of naming one. No rule changed.
- **`docs/AI/design/register-script-spec.md`:** its take-up section describes adopting the
  register tool in any repository with an existing register, and its examples use a made-up
  vendor.
- **Upgrading:** `sync` brings one changed comment in `bin/track`. Until then `verify` reports
  that 0.5.1 is available.

Tested with the 0.5.0 suites (48, 91, 64, 40 and 24 cases), each passing on the release.

The README's State section says 0.5.1.

## 0.5.0 — 2026-10-02
The first release prepared for a public copy of the standard. An adopted repo now says what
the standard placed in it and what not to break; `verify` checks that the standard's files
are the ones released; and the Markdown tables the standard writes draw their lines in more
viewers. This entry, like every one from here on, is written so it can be published.

- **`REPO-STANDARD.md`** — a notice at the root of every adopted repo, the same text in each:
  the repo follows repo-standard; which files the standard manages (do not edit, move or
  delete them); which names the hooks and tools find by name; what is generated; what is the
  repo's own; the two settings every clone needs; how to check and update. `init` installs it
  and `sync` keeps it current, replacing a local edit, so a healthy `sync` reads `7 unchanged`
  (`8` in a vendor-derived repo). Line 2 of every managed script points to it, and the README
  skeleton's map opens with it. The standard's own source tree carries none.
- **`verify` checks the managed files**, in a new section. The repo's stamp is compared with
  the `VERSION` of the standard checkout running `verify`: an older stamp warns that a newer
  version is available, a newer one that the checkout is behind. Every managed file except
  `.claude/settings.json` is compared with its copy at the stamped version, read from that
  version's tag. A difference warns, naming each file: an edit, or an install from an
  unreleased checkout. A checkout without that tag says it cannot check content.
- **Table lines in ReText** — the separator rows the standard writes carry no alignment colons
  any more: in the tracker skeleton, in the register skeleton `init` writes, and in the summary
  table `bin/register` generates. ReText's default preview drops a table's borders when its
  cells carry an alignment. Existing `tracker.md` files keep their own separators.
- **Docs** — `standard/STANDARD.md` (section 3, and `init`, `verify` and `sync`), the transfer
  prompt (section 8) and the README.
- **Upgrading:** every adopted repo receives the notice and the updated scripts on its next
  `sync`. Until then `verify` reports that 0.5.0 is available, a warning that fails
  `--strict`. In a vendor-derived repo whose register is in its checkable form, the next
  `bin/register render` writes the new separator row; `sync` says when that is due.

Tested with flip suites against the 0.4.0 tools: the notice through `init` and `sync` (40
cases), `verify`'s managed-file section (24 cases, with a control that fails 8 of them under
the compare-with-the-current-template rule first considered), and the table separators
(reproduced through Qt's rich-text engine with ReText's stylesheet, then fixed, with a
control), plus the 0.4.0 suites (48, 91 and 64 cases).

The README's State section says 0.5.0.

