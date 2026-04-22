# Skill Orchestration Contract

This document is the canonical reference for autonomous dispatchers and human orchestrators. It defines the project state vector, skill validity conditions, ordering invariants, and the dispatcher precedence that `/arc-status` uses in its Step 7 recommendation logic. The document is **descriptive guidance, not enforcement** — validators may warn but do not refuse to run when invariants are violated.

## State Vector

The state vector captures the minimum project state a dispatcher needs to choose the correct skill. It is emitted as JSON by `scripts/state.sh`.

| Field | Type | Values | Description |
|-------|------|--------|-------------|
| `idea_status` | string (enum) | `"captured"` \| `"shaped"` \| `"spec-ready"` \| `"shipped"` | The lifecycle status of the most recently active idea (or the lowest-precedence unblocked status if multiple ideas are active). For multi-idea projects, interpret in conjunction with the count fields. |
| `shaped_count` | integer | ≥ 0 | Number of ideas in `docs/BACKLOG.md` with `Status: shaped`. |
| `spec_ready_count` | integer | ≥ 0 | Number of ideas in `docs/BACKLOG.md` with `Status: spec-ready`. |
| `wave_active` | boolean | `true` \| `false` | `true` when `docs/ROADMAP.md` contains at least one wave with `Status: Active` or `Status: Planned`. |
| `validation_status` | string (enum) | `"PASS"` \| `"PENDING"` \| `"FAIL"` \| `"N/A"` | The validation outcome for the most recent spec-pipeline run. `"N/A"` when no spec has been validated yet. |

### Full State Object

```json
{
  "idea_status": "captured | shaped | spec-ready | shipped",
  "shaped_count": 0,
  "spec_ready_count": 0,
  "wave_active": false,
  "validation_status": "N/A"
}
```

A dispatcher resolves the recommended next skill by evaluating this object against the Skill Validity Matrix and Dispatcher Precedence list below.

## Skill Validity Matrix

Each row names an Arc skill, the state condition under which it is valid to invoke, and the artifacts it requires to be present. All nine skills are listed.

| Skill | Valid When | Required Artifacts |
|-------|------------|-------------------|
| `/arc-capture` | Always — no prerequisites | `docs/BACKLOG.md` (created if absent) |
| `/arc-shape` | At least one idea with `idea_status = "captured"` exists in the backlog | `docs/BACKLOG.md` with ≥ 1 captured entry; `docs/CUSTOMER.md` (created from template if absent) |
| `/arc-wave` | `shaped_count >= 1 AND wave_active = false` | `docs/BACKLOG.md` with ≥ 1 shaped entry; `docs/VISION.md` (created if absent); `docs/ROADMAP.md` (created if absent) |
| `/arc-ship` | `spec_ready_count >= 1 AND validation_status = "PASS"` | `docs/BACKLOG.md` with ≥ 1 spec-ready entry; `docs/specs/NN-spec-*/NN-validation-*.md` with `**Overall**: PASS`; wave archive directory |
| `/arc-status` | Always — read-only; no prerequisites | `docs/BACKLOG.md` (required); all others optional with graceful fallback |
| `/arc-audit` | Always — produces a report with interactive fixes | `docs/BACKLOG.md` (required); `docs/ROADMAP.md`, `docs/VISION.md`, `docs/CUSTOMER.md` (optional) |
| `/arc-assess` | Always — but most useful at project inception or when adopting Arc into an existing project | Target project directory readable; `docs/BACKLOG.md`, `docs/VISION.md`, `docs/CUSTOMER.md` (created if confirmed) |
| `/arc-sync` | Always — scaffold mode when no `README.md` exists; update mode otherwise | `README.md` (created in scaffold mode); Arc artifact files for sync content |
| `/arc-help` | Always — no prerequisites, no side effects | None |

### Notes on "Always" Skills

Skills marked **Always** have no blocking prerequisite. They degrade gracefully when optional artifacts are absent: `/arc-status` emits fallback notices per missing section; `/arc-audit` reports what it cannot check; `/arc-sync` scaffolds from minimal context.

## Ordering Invariants

These invariants define the correct progression of the idea lifecycle. Violating an invariant does not block execution — it generates a warning. The invariants are reference points for validators and auditors, not guards.

### I1: Backlog Consistency

Every idea with `Status: shaped` in `docs/BACKLOG.md` must have all seven brief fields populated (Problem, Proposed Solution, Success Criteria, Constraints, Assumptions, Wave Assignment, Open Questions). An idea with `Status: shaped` that lacks any brief field is inconsistent — it may have been partially shaped or manually edited. `/arc-audit` detects this; `/arc-shape` prevents it by validating on exit.

### I2: Wave Closure

No idea may transition from `spec-ready` to `shipped` without a `cw-validate` report that contains `**Overall**: PASS`. The wave is considered closed only when all its assigned ideas have shipped via `/arc-ship`. `/arc-ship` enforces this; validators warn if a PASS report is absent but a ship transition is attempted.

### I3: Roadmap Closure

No wave entry in `docs/ROADMAP.md` may be marked `Completed` until all ideas assigned to that wave appear in the wave archive at `docs/skill/arc/waves/NN-{slug}.md`. Closing a wave prematurely creates a ROADMAP↔archive mismatch that `/arc-audit` detects under its cross-reference integrity check.

### I4: Temporal Monotonicity

For any single idea, the `Captured:` timestamp must precede the `Shaped:` timestamp, which must precede the `Shipped:` timestamp. Out-of-order timestamps indicate manual edits or clock skew and will cause `/arc-audit` to flag the affected idea. Arc skills write timestamps at transition time; hand-editing timestamps can violate this invariant.

### I5: Brief Atomicity

A shaped brief's fields are all-or-nothing. Either all required brief fields are present and non-empty, or the idea status should be `captured` (not `shaped`). Partial briefs — where some fields are populated and others are empty — indicate an interrupted shaping session. The `/arc-shape` skill validates this on exit and sets status only after all fields are confirmed.

## Dispatcher Precedence

`/arc-status` is the **coordinator skill**. Its Step 7 implements the canonical next-step recommendation using a first-match-wins precedence list. This list is reproduced here for dispatcher reference. Evaluate from highest priority (P1) to lowest (P7) and recommend the first matching skill.

| Priority | Condition | Recommended Skill | Reason Template |
|----------|-----------|-------------------|-----------------|
| P1 | A Validation → Shipped gap exists (`spec_ready_count >= 1 AND validation_status = "PASS"`) | `/arc-ship` | "{Idea Title} has a validation PASS but is still spec-ready — ship it?" |
| P2 | A Plan → Validation gap exists (spec directory has plan evidence but no validation report) | `/cw-validate` | "{NN}-spec-{name} has plan evidence but no validation report — validate it?" |
| P3 | A Spec → Plan gap exists (spec directory exists but has no plan evidence) | `/cw-plan` | "{NN}-spec-{name} has a spec but no plan — plan it?" |
| P4 | A Shaped → Spec gap exists (`shaped_count >= 1` and no spec directory for the shaped idea) | `/cw-spec` | "{Idea Title} is shaped but has no spec — write a spec?" |
| P5 | A Captured → Shaped gap exists on a P0 or P1 idea | `/arc-shape` | "{Idea Title} is captured at {Priority} but unshaped — shape it?" |
| P6 | No gaps AND `wave_active = true` | `/arc-wave` or `/arc-audit` | "No gaps detected and {Wave Name} is in progress — check wave health?" |
| P7 | No gaps AND `wave_active = false` | `/arc-wave` | "No gaps and no active wave — plan the next delivery wave?" |

### How `/arc-status` Presents This

After emitting its five summary sections (Current Wave, Backlog Snapshot, In-Flight Specs, Recent Activity, Lifecycle Gaps), `/arc-status` evaluates this precedence list and presents the first-matching recommendation via `AskUserQuestion`. The prompt always includes at least three options: the recommended skill (labeled "(Recommended)"), one alternative skill, and "Done for now".

A dispatcher that wants to reproduce this logic programmatically can:
1. Run `scripts/state.sh` to get the state vector.
2. Check for lifecycle gaps by running the validate scripts or reading the gap output from `/arc-status`.
3. Walk the precedence table from P1 to P7 and invoke the first-matching skill.

### Downstream Skills (Outside Arc)

When a gap is in the SDD pipeline (P2–P4 above), the recommended skill is a `claude-workflow` skill (`/cw-validate`, `/cw-plan`, `/cw-spec`), not an Arc skill. Arc's role ends at wave planning; the SDD pipeline handles spec → plan → dispatch → validate. Arc resumes at `/arc-ship` after the SDD pipeline produces a PASS.

## Worked Example

The following examples show how the state vector maps to a recommended next skill under the precedence list.

### Example Table

| Scenario | `shaped_count` | `spec_ready_count` | `wave_active` | `validation_status` | Gaps Present | Recommended Skill |
|----------|---------------|--------------------|---------------|---------------------|-------------|-------------------|
| Fresh project, first idea captured | 0 | 0 | false | N/A | Captured → Shaped (P0 idea) | `/arc-shape` (P5) |
| Two ideas shaped, no wave started | 2 | 0 | false | N/A | Shaped → Spec | `/cw-spec` (P4) |
| Wave active, spec written, plan exists, no validation | 0 | 1 | true | PENDING | Plan → Validation | `/cw-validate` (P2) |
| Validation passed, idea not yet shipped | 0 | 1 | true | PASS | Validation → Shipped | `/arc-ship` (P1) |
| All ideas shipped, wave closeable | 0 | 0 | false | PASS | None | `/arc-wave` (P7, plan next wave) |

### Detailed Walkthrough: Row 3

**State vector:**
```json
{
  "idea_status": "spec-ready",
  "shaped_count": 0,
  "spec_ready_count": 1,
  "wave_active": true,
  "validation_status": "PENDING"
}
```

**Dispatcher evaluation:**
- P1: `spec_ready_count >= 1 AND validation_status = "PASS"` — No, `validation_status = "PENDING"`.
- P2: A Plan → Validation gap? Yes — spec directory `docs/specs/15-spec-example/` has plan-files but no `15-validation-*.md`. **Match.**

**Recommendation:** `/cw-validate` — "15-spec-example has plan evidence but no validation report — validate it?"

The recommended skill's validity condition from the matrix: `/cw-validate` is a `claude-workflow` skill invoked when there is an in-flight spec with plan evidence but no validation report. The state vector satisfies this condition (`wave_active = true`, plan evidence present).

## Cross-References

- [idea-lifecycle.md](idea-lifecycle.md) — Four-stage idea progression with state field definitions
- [wave-planning.md](wave-planning.md) — Wave sizing, precedence rules, and Temper phase compatibility
- [brief-format.md](brief-format.md) — Brief field definitions referenced in I1 and I5
- [cross-plugin-contract.md](cross-plugin-contract.md) — Read-only Temper artifact access and directionality
- `skills/arc-status/SKILL.md` Step 7 — The live implementation of the dispatcher precedence list
- `scripts/state.sh` — Emits the current state vector as JSON
