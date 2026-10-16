# Spec — `track` (minimal tracker CLI)

*The must-have from the design proposal §4/§10.3: keep `tracker.md`'s ID + Created +
Status Changed maintained automatically, with the least machinery that works.*

- **Scope:** four subcommands (`add`, `set-status`, `render`, `history`) over one markdown
  file. Name/description are hand-edited; no git writes (you gate commits; `history` only
  reads git). `render` is included so the per-category state model is defined **once** and
  shared with `set-status` validation.
- **Reference size:** the data logic (`add` / `set-status`) is ~110 lines of portable bash (>= 4),
  ~140 with the B47 ID-reuse helpers; `render` adds a self-contained HTML template (essentially
  prototype A, wired to the real data). Keep the *logic* tiny even though the embedded template
  makes the file longer.
- **Dependencies:** bash (>= 4 — the state model rides associative arrays; guarded at the
  door with a clean error on 3.2, B86) + coreutils + `awk`/`sed` + `date`, plus `git` for
  `history` only. No `jq`, matching the hooks.

---

## 1. The file it owns — `docs/dev-notes/tracker.md`

Human-readable, GitHub-renders-as-tables, and machine-appendable. Also ships as
`template/…/tracker.skel.md` (empty tables, and an empty Details section with a comment on
its form).

```markdown
# tracker — <repo>

<!-- IDs, statuses, and dates are maintained by `track`. Edit Name/Description and the
     Details section by hand; use `track add` / `track set-status` for everything else. -->

## Legend
| Symbol | Status      | Meaning                                   |
| :----: | :---------- | :---------------------------------------- |
| 📥 | submitted   | entered, not yet triaged                  |
| 🔍 | researching | evaluating feasibility / reproducing      |
| ⬜ | open        | accepted, not started                     |
| 🔄 | in-progress | actively being worked                     |
| ⛔ | blocked     | waiting on a dependency or decision        |
| 🧪 | testing     | implemented, awaiting validation          |
| ✅ | done        | complete and verified                     |
| 🤷 | cnr         | can not reproduce                         |
| 🗑️ | dropped     | decided not to pursue                     |
| ⏸️ | parked      | intentionally postponed                   |

## Bugs
| ID  | Status         | Created    | Status Changed | Name     | Description |
| :-- | :------------- | :--------- | :------------- | :------- | :---------- |
| B01 | 📥 submitted   | 2026-05-29 | 2026-05-29     | test bug | placeholder |

## Features
| ID  | Status  | Created    | Status Changed | Name           | Description |
| :-- | :------ | :--------- | :------------- | :------------- | :---------- |
| F01 | ⬜ open | 2026-05-29 | 2026-05-29     | error checking |             |

## Documentation
| ID  | Status | Created | Status Changed | Name | Description |
| :-- | :----- | :------ | :------------- | :--- | :---------- |

## Testing
| ID  | Status | Created | Status Changed | Name | Description |
| :-- | :----- | :------ | :------------- | :--- | :---------- |

## Details

### B01 — test bug

Free text: paragraphs, lists, fenced code. The row's Description stays a one-line summary.
```

**Load-bearing conventions** (the script relies on these; a human can still read/edit):
- Four fixed section headings: `## Bugs`, `## Features`, `## Documentation`, `## Testing`.
  A new row is appended to its section's table, before the next `## ` heading or EOF.
- Six fixed columns in that order. The **Status** cell is `<emoji> <word>`; the *word*
  is canonical, the emoji is derived from the Legend map.
- Dates are `YYYY-MM-DD`, local (`date +%F`) — same local-time rule as handoffs.
- **Detail sections** (optional): an item that needs more than a one-line Description gets a
  section under one `## Details` heading after the four tables. Its heading is
  `### <ID> — <Name>`: an existing row's ID (a child's too, `### B02.1 — …`; the ` — `
  separator because IDs contain dots) and that row's Name exactly, compared with spaces
  trimmed and the table's `\|` read as `|`. Its text is free Markdown up to the next item
  heading, the next `## ` heading or the end of the file: `####` and lower are sub-headings
  inside it, a fenced block belongs to it (a quoted `### B05` starts nothing), and text before
  the first item heading belongs to no item. Sections come in any order. The row's
  Description is then a one-line summary: a convention, not checked. Every other parser stops
  at the `## Details` heading, so `add`, `set-status`, the ID scans and the sidecar never
  read the section, and a `|` line inside a detail is never a row.

---

## 2. Field rules

| Field | Rule |
| :-- | :-- |
| **ID** | Per-category prefix: bug→`B`, feature→`F`, doc→`D`, testing→`T`. Top-level = prefix + zero-padded-2 of `max(descendant-aware scan, tracker-hwm high-water mark) + 1` (`B01`, `F15`; rolls to 3 digits naturally at 100). The scan is **descendant-aware** (B47): a surviving `B94.2` keeps `94` reserved even with the `B94` row deleted, and the `tracker-hwm` sidecar (§4) keeps a whole deleted family from being re-minted. Nested (with `--parent P`) = `P.(max existing child index of P + 1)` — unpadded, e.g. `F12.2` → `F12.2.3`; the child scan is descendant-aware too (a surviving grandchild `P.N.x` reserves segment `N`). Never hand-typed. |
| **Status** | Restricted to the item's **category's** allowed set (§2a). Canonical token is the word; emoji looked up from Legend. |
| **Created** | Stamped = today on `add`. Never changes afterward. |
| **Status Changed** | Stamped = today on `add` (equals Created), and re-stamped = today on every `set-status` that actually changes the value. |
| **Name / Description** | Free text, hand-edited in the markdown. The script never touches them after `add`; nor an item's detail section (§ 1), which is written by hand. |
| **Default status on add** | bug → `submitted`; feature / doc / testing → `open`. Override with `--status`. |

---

## 2a. Per-category state model (single source of truth)

Each category has its own state set + happy-path flow. Defined **once** in the `track`
script and shared by `set-status` (validation) and `render` (flow diagram + restricted
display) — no second copy to drift, no separate config file.

| Category | Allowed states (happy-path first, then side) | Flow shown above the table | Default |
| :-- | :-- | :-- | :-- |
| **Bugs** | submitted · researching · open · in-progress · testing · done · + blocked · parked · dropped · cnr | submitted → researching → open → in-progress → testing → done | submitted |
| **Features** | submitted · researching · open · in-progress · testing · done · + blocked · parked · dropped | submitted → researching → open → in-progress → testing → done | open |
| **Documentation** | open · in-progress · done · + blocked · parked · dropped | open → in-progress → done | open |
| **Testing** | open · in-progress · done · + blocked · parked · dropped | open → in-progress → done | open |

Encoded rules: `cnr` is Bugs-only; `submitted`/`researching` are Bugs & Features only;
the `testing` *state* is excluded from the Testing *category*; Docs & Testing share a
6-state set. **Restricted, not enforced** — `set-status` accepts any state in the set;
the flow is *displayed* as guidance, never policed as a transition gate.

---

## 3. Commands

### `track add <category> "<name>" [--parent <ID>] [--status <s>] [--desc "<text>"]`
- `<category>` ∈ `bug | feature | doc | testing` (plural forms accepted).
- Computes the next **ID** (top-level, or child of `--parent`).
- Sets **Created** = **Status Changed** = today; **Status** = `--status` or the category default.
- Appends the row to that category's table.
- Prints the assigned ID (e.g. `added F15`). Exit 0.

**Guards:** unknown category / status → error, no write. `--parent` must exist *and* be
in the same category. Fail-closed: on any error, the file is left untouched.

### `track set-status <ID> <status>`
- Finds the row by exact ID across all sections; its ID prefix gives the category.
- Validates `<status>` is in that **category's allowed set** (§2a) — restricted, *not*
  transition-enforced (any state in the set is reachable; the flow is guidance, not a gate).
- If `<status>` equals the current status → **no-op** (`F05 already in-progress`), no re-stamp.
- Else rewrites the Status cell (`<emoji> <word>`) and sets **Status Changed** = today.
- Prints `F05: open → in-progress`. Exit 0.

**Guards:** unknown ID / status-not-valid-for-category → error, no write.

### `track render`
- Reads `tracker.md` + the §2a state model, writes `tracker.html` — the interactive view:
  column sort + filter, rows expand to detail, and **each category's state-flow above its
  table**, limited to that category's states. Read-only output; run it after edits (or wire
  it into a hook / `verify`).
- Lives in the same script so the state model is defined **once** and reused for both
  `set-status` validation and flow rendering — single source, no config file.
- **Detail sections** (§ 1): an item's section shows in its expanded row, after the
  Description, as escaped plain text with its line breaks kept (no Markdown interpretation);
  the search covers it. Render **refuses**, naming each problem's line and listing all of
  them, a `### ` line in the Details section that is not an item heading, an ID with no row,
  a second section for one ID, a heading name that differs from the row's Name, and a second
  `## Details` section: the page could not show them truthfully. After `add` / `set-status`
  the row change still lands and the auto-render stops with the error, as with the 0x1f
  refusal below.
- **`--check`** renders to a temp and compares: exit 0 if `tracker.html` is current, exit 1
  if stale. Consumed by a pre-commit hook and by `verify`. (Render is deterministic — no
  timestamps, fixed key order — so the byte-compare is reliable.)
- **Refuses a raw `0x1f` (US) byte** in `tracker.md`, naming the first offending line
  (B85) — that byte is the render pipeline's own field separator, so a raw one in a cell
  would silently shift every later field. `add` already rejects control characters at the
  door; this closes the hand-edit/paste path, and auto-render, `--check`, `verify`, and
  the pre-commit hook all funnel through the same check.

### Staleness (the one open risk of Architecture A — closed)
- **Auto-render:** `add` / `set-status` regenerate `tracker.html` right after a change, so
  the view can't drift on the CLI path. `TRACK_NO_RENDER=1` skips it for bulk edits.
- **Hand-edits** to Name/Description don't go through the CLI, so a **pre-commit hook**
  runs `track render --check` and blocks a commit whose view is stale (respects the commit
  gate — it tells you to run `track render`, it doesn't rewrite the commit). `verify` runs
  the same check in CI.

### `track history <ID>`
- **Read-only:** prints one item's history from git, oldest first in each part. No write, no
  lock, no render. Nothing is recorded: git already holds the record, and a second copy could
  drift (decided 2026-10-15).
- **Versions of the row:** every commit that touched the tracker file, followed across
  renames, each read with render's fence- and section-aware parsing, so a quoted example row
  with the same ID is not the item. A version is listed only where the row or its detail
  section changed, and names each change: `added: <status>` with the Description's length,
  `status A → B (<Status Changed>)`, `Created A → B`, `Name → "…"`, `Description a → b chars`,
  `detail added (n lines)`, `detail a → b lines`, `detail removed`, `row removed`, `row back`.
  A row that only moved, or only changed its line endings, makes no version. The commit hash
  on each line leads to the full change (`git show <hash>`).
- **Uncommitted:** when the working copy differs from the last commit, a last line marked
  `uncommitted`, with no date.
- **Commits that name it:** messages in HEAD's history that name the ID whole. `F15` matches,
  and so does `F15.` ending a sentence; `F150`, `xF15` and the child `F15.1` do not, since each
  child has its own history.
- **Cited in:** the tracked files whose worktree text names the ID whole, leaving out the
  tracker's own three files (`tracker.md`, `tracker.html`, and `tracker-hwm`, which holds the
  highest ID ever issued). Outside the standard's source repo (recognized as `sync` recognizes
  it), the standard's managed files are left out too: their comments cite the standard's own
  IDs, which every repo's numbering repeats. Live files are listed by name; records
  (`docs/AI/` and `z-deprecated/`) are counted per folder.
- **Exit:** 0 when the ID has any history, a row deleted by hand included (headed "no longer
  in the tracker: last seen in <hash>, <date>", its versions ending in `row removed`). 1 for
  an ID never in the file, a malformed ID, or a tracker outside a git work tree. A shallow
  clone prints the history it has and says it is incomplete.

```
$ track history F15
F15  wallpaper randomizer   (feature, done)

Versions of the row (3)
  2026-06-01  3f2a9c1  added: open · Description 40 chars
  2026-06-03  8b7d210  status open → in-progress (2026-06-03)
  2026-06-09  c41e5aa  status in-progress → done (2026-06-09) · detail added (6 lines)

Commits that name F15 (2)
  2026-06-03  8b7d210  feat: wallpaper randomizer, first cut (F15)
  2026-06-09  c41e5aa  feat: F15 done — per-monitor support

Cited in 3 files
  live (1):     src/wallpaper.sh
  records (2):  docs/AI/session-handoffs/ 2
```

### (optional, later) `track list [--status s] [--cat c] [--grep text]`
A convenience read (filter/print rows). Not required — the file is already readable.
Add only if scanning the raw markdown starts to annoy; otherwise leave it out.

---

## 4. Behavior / guardrails

- **File discovery** (order updated 2026-08-13, B19/B62): `$TRACKER_FILE` if set; else the
  repo the INVOKED copy lives in (`$0/../docs/dev-notes/tracker.md` — so
  `<target>/bin/track add …` tracks `<target>` no matter where you stand; `$0` deliberately
  unresolved, since the standard's own `bin/track` is a symlink into `template/`); else
  `docs/dev-notes/tracker.md` under `$CLAUDE_PROJECT_DIR` or `git rev-parse
  --show-toplevel`; else `./tracker.md` as a last resort, ANNOUNCED on stderr. Whichever file
  resolves must carry at least one of the four category headings (`## Bugs`, `## Features`,
  `## Documentation`, `## Testing`) outside a fenced block, or every command refuses before
  reading further or writing anything (B147).
- **Atomic writes:** write to a temp file, then `mv` over the original — never a partial
  file. A `tracker.md.lock` directory (mkdir-atomic) serializes concurrent mutators (B46);
  temp files and the lock are cleaned on any exit.
- **Fence-blind no more (B84):** all parsers skip ``` / ~~~ fenced blocks — a quoted example
  row neither mints IDs, nor takes an insertion, nor answers `set-status`.
- **IDs never come back (B47):** two layers keep a deleted row's number from being
  re-minted (a recycled ID silently inherits every stale cross-reference to the dead
  one). Layer 1 — the mint scans are descendant-aware: a dotted survivor reserves its
  leading number at each level. Layer 2 — a `tracker-hwm` sidecar **next to the tracker
  file** records the highest ID ever minted per prefix, exactly two lines: a
  ``# highest IDs ever minted by `track` …`` comment, then `B<n> F<n> D<n> T<n>` (bare
  prefixed numbers, single spaces). `track add` rewrites it after every successful
  top-level add, healing each prefix *upward* from the current scan, never downward; a
  missing or unparseable sidecar is reseeded silently from the scans (self-installing —
  no init/sync/skeleton step). Top-level numbers are bounded at **9 digits end-to-end**
  (convergence K7): the mint scans err loudly on a wider — hand-mangled — table row
  instead of letting 64-bit arithmetic wrap into duplicate IDs at exit 0, and `add`
  refuses to mint a number the sidecar reader would not read back (the reader's own
  bound is what keeps a hand-garbled sidecar on the reseed path instead of wrapping).
  Child IDs are deliberately **not** tracked in the
  sidecar: layer 1 covers a deleted parent with survivors, and a child family deleted
  whole re-minting its index is the accepted residual — retire rows instead of deleting
  them (§5).
- **No commits.** The script edits the working tree only; committing stays your call
  (repo commit gate).
- **Idempotent where it matters:** `set-status` to the current value changes nothing.
- **Portable & tiny:** bash (>= 4, guarded at the door — B86) + `awk` + coreutils;
  no `jq`, no config file, no network.

---

## 5. Non-goals (keep it minimal — revisit only if a real need shows up)

| Not doing | Why | Revisit when |
| :-- | :-- | :-- |
| Enforced state *transitions* | Restricted-set + displayed-flow was chosen over a guarded state machine | you need to prevent illegal state jumps |
| Editing Name/Description or a detail section | Hand-edit is fine and simpler; a multi-paragraph text has no good command-line form | Never, probably |
| Deleting rows | **Never** — retire with `dropped` / `cnr` instead; deletion is exactly the hazard the `tracker-hwm` sidecar defends against (B47) | Never |
| Reorder / reparent rows | Rare; hand-edit the table | It becomes frequent |
| `git` commit / any config surface | Commit gate; conventions are hard-coded | It stops being just you |

---

## 6. Buildability notes (for when we write it)

Only one operation is structurally sensitive — *appending to the right table*. Everything
else is line scanning.

- **Next top-level ID:** scan surviving rows for `<PREFIX>NN` *and* `<PREFIX>NN.…`
  (descendants reserve their leading number — B47), take the max `NN`, compare it
  against the `tracker-hwm` high-water mark for that prefix, `max + 1`, pad-2.
- **Next child ID:** scan rows matching `^<PARENT>\.N$` *and* `^<PARENT>\.N.…`
  (grandchildren reserve segment `N` — B47), max `N`, `+1`.
- **Append:** with `awk`, find the `## <Section>` line, walk to the last table row before
  the next `## ` (or EOF), insert the new row after it.
- **`set-status`:** `awk`/`sed` match the line beginning `| <ID> |`, rewrite fields 2 (Status)
  and 4 (Status Changed) by column position.

Worked example:
```
$ track add feature "wallpaper randomizer"          # → added F15  (open, dated today)
$ track add feature "per-monitor wallpaper" --parent F15   # → added F15.1
$ track set-status F15 in-progress                  # → F15: open → in-progress  (Status Changed = today)
```
