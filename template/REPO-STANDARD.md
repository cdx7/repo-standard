# This repo follows repo-standard

This repository follows **repo-standard**, a layout and small toolkit that keep a repo easy to
pick up for whoever works in it next. The standard's tools placed several files here. Some of
them are **managed**: they are replaced from the standard, and the hooks and tools depend on
them and on the folder names below. Read this before you edit, move, rename or delete anything
this file lists.

This file is itself managed: it is the same in every repo that follows the standard, and
updates replace it. Anything about this repo in particular is in `README.md` and `CLAUDE.md`.

## Where the standard lives

The standard is the public repository `cdx7/repo-standard`
(https://github.com/cdx7/repo-standard): its rules (`standard/STANDARD.md`), its tools, and
their release notes. You do not need it to work here safely; this file says what not to
break.

Which version this repo follows, and its kind, are on the first line of
`.repo-standard-version`. An **authored** repo's code is the deliverable; a
**vendor-derived** repo builds from documents a vendor supplied, kept in `docs/reference/`.

## Managed files: do not edit, move or delete

- `bin/track` — the tracker tool. `bin/track add`, `bin/track set-status` and
  `bin/track render` keep `docs/tracking/tracker.md` and generate `tracker.html`; it sets
  every ID and date. `bin/track history <ID>` shows an item's history from git.
- `bin/register` — vendor-derived repos only. The register tool: `bin/register check`,
  `render`, `map` and `history` for `docs/official/DEVIATIONS.md`.
- `.githooks/pre-commit` — refuses a commit whose generated page is out of date against its
  staged source: `tracker.html`, and in a vendor-derived repo the register's summary and
  `DEVIATIONS.html`. Then it runs this repo's own checks (below).
- `.claude/hooks/stop-handoff-check.sh` — Claude Code hook: when a session ends, asks for a
  session handoff if one is due.
- `.claude/hooks/session-start-rollover-check.sh` — Claude Code hook: when a session starts,
  asks for last month's handoffs to be archived.
- `REPO-STANDARD.md` — this file.

An update from the standard replaces these files, so a local edit is lost. Deleting one
disarms a check quietly: once `bin/track` is gone, for instance, the commit guard stops
checking the tracker, and says so only in passing.

**Your own pre-commit checks** go in `.githooks/pre-commit.d/`, a folder that is yours: an
update never writes into it. Each executable file there whose name is only letters, digits,
`_` and `-` runs on every commit, in name order (`10-lint` before `20-test`), from the repo
root; one that exits nonzero blocks the commit. Other names (`*.sample`, `README.md`) are not
run. Pin the folder to LF in `.gitattributes`: `.githooks/pre-commit.d/* text eol=lf`.

**`.claude/settings.json`** is the one shared file you may extend. Your own keys are kept
when it is updated, but its `hooks` block must stay, or the two hooks above never run.

## Fixed names: do not rename or restructure

The hooks and tools find these by name, from the repo root:

- `bin/` — the tools above.
- `.githooks/`, `.claude/` — the commit guard; the Claude Code hooks and settings.
- `docs/official/` — end-user documentation written for this repo.
- `docs/AI/` — Claude's durable output: design notes, audits.
- `docs/AI/session-handoffs/` — one handoff per session; past months in `YYYYMM/` folders.
- `docs/tracking/` — where work stands: `STATUS.md`, and the tracker (`tracker.md`,
  `tracker.html`, `tracker-hwm`).
- `docs/dev-notes/` — the working notes of the people who maintain this repo, made on first
  use.
- `docs/reference/` — vendor-derived repos only: the vendor's documents, as received.
- `docs/official/DEVIATIONS.md` — vendor-derived repos only: the register of where this repo
  departs from those documents, and why.
- `docs/official/VENDOR-QUESTIONS.md` — vendor-derived repos only: the questions for the
  vendor (`VQ01` onward), what was sent, and what came back.
- `.repo-standard-version` — which version of the standard this repo follows.

## Generated: never edit by hand

- `docs/tracking/tracker.html`, from `tracker.md` (`bin/track render`).
- `docs/tracking/tracker-hwm`, the highest tracker IDs ever issued, kept by `bin/track add`.
- In a vendor-derived repo: `docs/official/DEVIATIONS.html` and the summary table between
  the `register:begin` and `register:end` markers in `DEVIATIONS.md` (`bin/register render`).

## Yours to write

- `README.md`, the front door: what this is, what state it is in, where to go next.
- `CLAUDE.md`: standing instructions for Claude Code in this repo.
- Everything in the `docs/` folders above; the tracker's rows go through `bin/track`, and rows
  are never deleted (retire them as `dropped`).
- The rest of `.gitignore` and `.gitattributes`. The standard's lines in them stay: the
  ignore rules for the personal files `.claude/settings.local.json*` and `CLAUDE.local.md`
  (never committed) and for the tools' temp files, and the `text eol=lf` lines that keep the
  scripts runnable on every platform.

## Who writes what

A Claude session works here beside the people who maintain this repo. These rules say who
changes what.

- **`docs/dev-notes/` is the maintainers' own.** A session does not write there unless it is
  asked to.
- **`docs/tracking/STATUS.md` is kept true by the session.** When it writes a handoff, or
  changes a tracker row's status, it checks STATUS, changes what is no longer true, and puts
  that in the same commit.
- **Everything else in STATUS is the maintainers':** what is in the queue, and in what order.
  A session asks first.
- **A commit or a push waits for a maintainer's go,** every time. The session shows what
  changed first, and STATUS's diff above all.
- **Before a maintainer leaves, the session writes a handoff** if anything has changed since
  the last one. A change to STATUS alone does not count. If nothing changed, a handoff from
  the last 12 hours is enough.
- **A handoff says nothing about its own commit.** It is written before that commit, and
  `git status` shows what is uncommitted.

## STATUS

`docs/tracking/STATUS.md` is orientation, not history: 20 to 30 lines of pointers, in three
sections.

- **NOW** holds only what is current, blocked work included. Finished work leaves for the
  handoffs.
- **NEXT** holds tracker rows, in order, at most five.
- **EVENTUALLY** holds ideas that have no row yet. When one gets a row, it leaves.
- **An item** reads `<folder>: <ID>, <ID> · <status> · <words>`.
  - The folder is there only in a repo that holds several projects.
  - Rows that share an item share a status. Work with no row carries a short name in the
    rows' place.
  - The status is the row's own, in the tracker's word: `open`, `in-progress` and so on. A
    blocked item says `BLOCKED on <whom or what>`.
  - What follows is free words: what it is, and what picks it back up.
- **A pointer to a handoff** ends an item only when the newest handoff does not cover that
  item: `handoff YYYY-MM-DD-HHMM`, the stamp from the file's name, never a path. STATUS never
  points at the newest handoff, because every new handoff would leave that pointer behind.
- **A section with nothing in it keeps its heading.**

## Two settings each clone needs

These do not travel with the repo, so run them once in every fresh clone:

    git config core.hooksPath .githooks
    git config tag.sort version:refname

The first arms the commit guard; the second lists version tags in order.

## Checking and updating

With a checkout of the standard, from that checkout:

    bin/verify <path to this repo> --strict
    bin/sync <path to this repo>

`verify` reports what is out of line and changes nothing. `sync` replaces the managed files
with the current ones and adds the standard's `.gitignore` lines if any are missing; it never
rewrites what is yours. Review its changes, then commit them.

Before repo-standard 0.9.0 the tracker and `STATUS` were kept in `docs/dev-notes/`. `sync`
stops, before it writes anything, on a repo that still keeps one of those files there with
nothing at its new path, and names each file; `verify` says so in one line. Such a file moves
to `docs/tracking/` first (`STATUS` as `STATUS.md`), and `sync` runs after.
