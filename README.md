# repo-standard

> **Public copy.** This repository is made by export from a private upstream, one release at a
> time, and nothing is edited here directly. Issues and pull requests are welcome: an accepted
> change is carried into the upstream by hand and comes back in the next release.

A standard for how a repo is laid out, so that a person, or a fresh Claude Code session, can
pick it up fast without re-deriving anything, and a small toolkit that stamps the layout into a
repo, checks a repo against it, and keeps the shared parts current.

## What is this
- **[`standard/STANDARD.md`](standard/STANDARD.md)** — the standard: what every repo should
  look like, and why.
- **`template/`** — what is stamped into a repo: the Claude Code hooks, the commit guard, the
  README skeleton, the `docs/` homes, the `track` tracker tool, `register` for a vendor-derived
  repo's deviations register, and `REPO-STANDARD.md`, the notice every adopted repo carries.
- **`bin/`** — the toolkit: `init`, `verify`, `sync`, and `fleet` (an adoption registry).
- **[`conventions-transfer-prompt.md`](conventions-transfer-prompt.md)** — the conventions as a
  prompt, for when the toolkit is out of reach.

## State — v0.5.1
Built and in use. The release history, from the first public release on, is in
[`CHANGELOG.md`](CHANGELOG.md).

## Using it
From a checkout of this repository:

    bin/init <repo> --authored        # or --vendor-derived: stamp the standard into a repo
    bin/verify <repo> --strict        # check a repo against the standard
    bin/sync <repo>                   # bring a repo's managed files up to date

`init` and `sync` never overwrite what a repo authored, and nothing commits on its own. Every
adopted repo then carries `REPO-STANDARD.md`, saying what the standard placed there and what
not to break.

## Where to go next
- The standard: [`standard/STANDARD.md`](standard/STANDARD.md)
- The tracker tool and its design: [`template/bin/track`](template/bin/track) ·
  [`docs/AI/design/track-script-spec.md`](docs/AI/design/track-script-spec.md)
- The register tool and its design: [`template/bin/register`](template/bin/register) ·
  [`docs/AI/design/register-script-spec.md`](docs/AI/design/register-script-spec.md)
- The notice and its design: [`template/REPO-STANDARD.md`](template/REPO-STANDARD.md) ·
  [`docs/AI/design/repo-standard-md-spec.md`](docs/AI/design/repo-standard-md-spec.md)
