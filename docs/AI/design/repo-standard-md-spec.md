# Spec — `REPO-STANDARD.md` (the standard's notice in every adopted repo)

*Draft, 2026-10-01; its five questions decided 2026-10-02 (§ 5). No tracker row yet: filing
one is the maintainer's call. Built so far (2026-10-02, 0.5.0 slice 2): the file installed by
`init` and `sync`, the pointer lines and the README line; slice 3: `verify`'s managed-files
section; slice 4: the docs (STANDARD.md, the transfer prompt, the README, the CHANGELOG). Not
yet: the 0.5.0 release.*

- **The problem** (the maintainer, 2026-10-01): an adopted repo shows the standard's
  fingerprints everywhere (`bin/`, `.githooks/`, `.claude/hooks/`, the fixed `docs/` homes,
  comment lines in `.gitattributes`), but nothing in it says what the standard is. A reader
  cannot tell machinery from authored content without the git log, so `bin/` is easy to
  delete and the `docs/` tree easy to restructure, and either breaks the tooling silently.
- **Decided** (the maintainer, 2026-10-01): one plain file at the repo root,
  `REPO-STANDARD.md`, with the same text in every adopted repo. `init` installs it and `sync`
  keeps it current, like the other machinery.
- **What stands today:** the only explicit trace is the stamp, `.repo-standard-version`, plus
  comment lines in `.gitattributes` and, in a vendor-derived repo, the register skeleton's
  status line and `bin/register`'s header. The README, `CLAUDE.md`, `STATUS` and tracker
  skeletons never name the standard.

---

## 1. Why a separate file, and why machinery

- **Not the README.** `init` never overwrites an existing README, and every adopted repo kept
  its own. A section there would reach new repos only, and could not be updated afterwards.
- **Not a comment in each file.** Comments explain one file at a time. Nobody reads them before
  deciding to delete a folder.
- **Machinery, not authored.** The text holds nothing repo-specific, so `sync` can own it:
  every repo gets corrections and new rules on its next sync, and a hand edit is reverted (as
  for the hooks). Anything repo-specific stays in the stamp, the README and `CLAUDE.md`.
- **At the root.** It is where someone deciding whether `bin/` matters will look. The name
  says what it is about; `ls` lists it beside `README.md`.

## 2. What the file says

Plain sections, short enough to read in a minute. The draft text is a separate step, for the
maintainer's review.

- **What this is:** the repo follows repo-standard, a layout and small toolkit that keep a repo
  easy to pick up for whoever works in it next. Its tools placed the files below; the version
  and archetype are in `.repo-standard-version`.
- **Where the standard lives:** the public repository's name and URL, and what it holds (the
  rules, the tools, their release notes). Everything a reader needs in order not to break
  this repo is in this file.
- **Managed files: do not edit, move or delete.** `bin/track` (and `bin/register` in a
  vendor-derived repo), `.githooks/pre-commit`, the two scripts in `.claude/hooks/`, and this
  file. `sync` replaces them; a local edit is lost, and a deletion disarms a check without a
  word.
- **`.claude/settings.json`, the one shared file you may extend:** your own keys are kept by
  `sync`, but its hooks block must stay, or the two hooks never run.
- **What each managed file does,** one line each.
- **Fixed names: do not rename or restructure.** `docs/official/`, `docs/AI/`,
  `docs/AI/session-handoffs/`, `docs/dev-notes/` (`STATUS`, `tracker.md`, `tracker.html`),
  `docs/reference/` and `docs/official/DEVIATIONS.md` in a vendor-derived repo (and, from
  0.7.0, `docs/official/VENDOR-QUESTIONS.md`), and `bin/` at the root. The hooks and tools find
  them by these names.
- **Yours to write:** the README, `CLAUDE.md`, `STATUS`, the tracker's rows (through
  `bin/track`), the register's entries, everything in `docs/`. The lines the standard needs in
  `.gitignore` and `.gitattributes` stay; the rest of those files is yours.
- **Generated, never hand-edited:** `tracker.html`, and in a vendor-derived repo
  `DEVIATIONS.html` and the register's summary block.
- **Two settings each clone needs:** `git config core.hooksPath .githooks` and
  `git config tag.sort version:refname`.
- **Checking and updating:** with a checkout of the standard, `bin/verify <repo>` and
  `bin/sync <repo>`.

## 3. How the standard carries it

- **`template/REPO-STANDARD.md`** joins the machinery list in `init` and `sync` (every
  archetype, an `(unknown)` stamp included). A healthy `sync` then reads `7 unchanged` (`8` in
  a vendor-derived repo), and STANDARD.md says so. Dogfood mode (`sync --force .` in the
  standard's own source tree) leaves it out: the source is not a consumer, the reason it gets
  no stamp either, and its notice is `template/REPO-STANDARD.md` itself. `init` reports it as
  `[3] notice`.
- **`verify`** checks the content of every managed file, this one included (Q3): `bin/track`,
  `bin/register` in a vendor-derived repo, `.githooks/pre-commit`, the two Claude Code hooks
  and `REPO-STANDARD.md`; not `.claude/settings.json`, which a repo may extend and whose
  hooks wiring `verify` already checks.
- **Version:** the stamp against the `VERSION` of the standard checkout running `verify`. An
  older stamp warns that a newer version is available ("run sync"); a newer one warns that
  the checkout is behind ("git pull").
- **Content:** each managed file against its copy at the repo's stamped version, read from
  that version's tag in the standard checkout (`git show`, read-only). A difference warns,
  naming every such file: edited here, or installed from an unreleased checkout. A file that
  version did not have is skipped; a missing notice warns; with no such tag in the checkout,
  `verify` says it cannot check content instead of guessing.
- **`init`'s scaffold allowlist** gains it, so a re-run on its own uncommitted scaffold is
  recognised.
- **The scripts point to it:** a comment on line 2 of `bin/track`, `bin/register`, the
  pre-commit hook and the two Claude hooks, right after the `#!` line: "Managed by
  repo-standard: read REPO-STANDARD.md at the repo root before editing, moving or deleting this
  file. sync replaces it from the standard."
- **STANDARD.md:** a short paragraph in the spine (section 3, or a new one), and the transfer
  prompt's copy list.
- **The fleet:** every adopted repo receives the file on its next sync, each in its own commit
  on a go.

## 4. Tests

Flip suite in the session scratchpad, against the previous release's tools:

- `init` on both archetypes installs it; the old `init` does not.
- `sync` adds it to a repo adopted at 0.4.0, then reads 7 or 8 unchanged.
- A hand edit to it is reported and replaced by `sync`.
- `verify` warns when it is missing.
- `verify` checks each managed file against the stamped version's tag. It warns on a hand
  edit to each file in turn, and announces a newer version without calling untouched files
  edited. It warns when the stamp is newer than the checkout, says so when the checkout has
  no tags, and does not flag a customized `settings.json`.
- `init`'s re-run on its own scaffold is still recognised.
- Each pointer line is present in the synced scripts.
- The file renders through both Markdown engines, with every list flat.

## 5. Questions (all decided by 2026-10-02)

- **Q1. The text.** The draft is `template/REPO-STANDARD.md`, under review. Decided
  2026-10-02 (the maintainer: "go with the flat lists"): no tables. Okular draws no lines in
  any table, and ReText draws them only when the separator row has no alignment colons (an
  aligned cell carries an inline `style`, and Qt's rich-text engine then drops ReText's border
  rule). Flat lists read the same in every viewer and in a terminal.
- **Q2. The URL. Decided 2026-10-02** by the public split (`public-split-plan.md`): the notice
  names the public repository, `cdx7/repo-standard`, and its URL, with no private-repo
  sentence. Its wording no longer assumes a single maintainer: the opening, and
  `docs/dev-notes/` as "the working notes of the people who maintain this repo" (the
  maintainer: "go, the three changes read right").
- **Q3. `verify`: presence only, or content too? Decided 2026-10-02:** content, for every
  managed file but `settings.json` (§ 3). The maintainer: "it needs to check content as well,
  since it is part of the standard effectively", then "go, check content of all managed
  files except settings.json". Content is compared only when the repo's stamp matches the
  standard's version, so a new release does not flag every repo that has not yet synced; a
  mismatch is a warning, like every other managed-file problem. Until now `verify` checked
  machinery for presence only and left drift to `sync --check`; with this, `verify --strict`
  alone answers whether a repo runs the standard's code. Refined while building (the
  maintainer: "go, compare against the installed version's tag"): content is compared with
  the stamped version's tag, not the current template. Between releases, `main` carries
  unreleased changes under the same `VERSION`, and comparing against it called every
  untouched repo "edited". Checked at the time on a repo installed with the real 0.4.0
  tools, which matched `v0.4.0` exactly but differed from the current template in five
  files.
- **Q4. A pointer from the README. Decided 2026-10-02** (the maintainer: "go, add the README
  line with no verify check"): the README skeleton's map gains a first entry,
  "`REPO-STANDARD.md` — this repo follows repo-standard: read it before moving or deleting
  its tools or folders".
  No `verify` check: the notice sits at the root beside the README. Added in the build, when
  `init` starts installing the file, so the template never points to a file it does not
  install; existing READMEs get the line by hand, per repo.
- **Q5. The version. Settled 2026-10-02** by the public split's Q2 (`public-split-plan.md`):
  0.5.0, the first public release, which ships this file and B150's fixes. A new file that
  `sync` copies changes the healthy sync count, as `bin/register` did in 0.4.0.
  The first public release became 0.5.1 (the split plan's Q2, amended the same day); the
  notice shipped in 0.5.0.

## 6. Not doing

| Not doing | Why |
| :-- | :-- |
| Repo-specific text in the file | `sync` could not own it; that belongs in the README. |
| Blocking a deletion of `bin/` | A hook cannot stop `rm`. The file explains; `verify` and the pre-commit hook's fail-open messages report the damage. |
| A copy of STANDARD.md in each repo | Two copies drift; this file is a notice, not the standard. |
