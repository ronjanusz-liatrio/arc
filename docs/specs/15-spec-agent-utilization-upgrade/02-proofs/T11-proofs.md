# T11 Proof Summary — T02.1: Author references/frontmatter-fields.md

**Task:** T02.1 — Create `references/frontmatter-fields.md` defining the shape of the four
new frontmatter fields, and cross-link it from `references/README.md`.

**Status:** PASS

## Proof Artifacts

| File | Type | Status |
|------|------|--------|
| `T11-01-file.txt` | file existence check | PASS |
| `T11-02-file.txt` | cross-link verification | PASS |

## What Was Implemented

### `references/frontmatter-fields.md` (new file, 345 lines)

Defines the four structured frontmatter fields (`requires`, `produces`, `consumes`,
`triggers`) added to every `skills/arc-*/SKILL.md`. Contents:

1. **Why These Fields Exist** — motivation section explaining the gap filled by these fields.
2. **Field Reference** — one section per field:
   - `requires`: sub-fields `files`, `artifacts`, `state`; includes predicate vocabulary
     table (idea.status, shaped_count, spec_ready_count, wave_active, validation_status).
   - `produces`: sub-fields `files`, `artifacts`, `state-transition`.
   - `consumes`: sub-field `from` (list of `{skill, artifact}` pairs); rules for when to
     omit.
   - `triggers`: sub-fields `condition` and `alternates`.
3. **Worked Examples** — 3 realistic examples:
   - arc-capture: always-valid, no state prerequisites, no upstream dependencies.
   - arc-wave: state-gated on `shaped_count >= 1 AND wave_active = false`, consumes from
     `/arc-shape`.
   - arc-ship: double-gated on `idea.status = 'spec-ready' AND validation_status = 'PASS'`,
     consumes from both `/arc-wave` and `/cw-validate`.
4. **Interaction with Existing Fields** — documents that the new fields are additive and
   that the pre-existing fields (`name`, `description`, `user-invocable`, `allowed-tools`)
   are unchanged.
5. **Cross-References** — links to `idea-lifecycle.md`, `skill-orchestration.md`, and
   `references/README.md`.

### `references/README.md` (modified)

- Added `frontmatter-fields.md` row to the References table.
- Added "In All Arc Skills (frontmatter contract)" section to "How They Are Used".

## Acceptance Criteria Verified

From `frontmatter-contract-layer.feature` Scenario 4:
- [x] Document describes the expected shape of `requires` (files, artifacts, state) — PASS
- [x] Document describes `produces` (files, artifacts, state-transition) — PASS
- [x] Document describes `consumes` (from list of skill/artifact pairs) — PASS
- [x] Document describes `triggers` (condition, alternates) — PASS
- [x] Each field section includes at least one populated example drawn from an existing
  arc skill — PASS (arc-capture, arc-wave, arc-ship used as examples throughout)
