# Changelog

Releases before 0.5.0 were made privately; their notes are not published.

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

