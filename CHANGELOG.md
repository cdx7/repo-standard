# Changelog

Releases before 0.5.0 were made privately; their notes are not published.

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

