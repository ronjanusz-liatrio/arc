# 16-spec-arc-status-wave-precedence

## Introduction/Overview

Fix `/arc-status`'s next-step recommendation so an active delivery wave is
treated as "in motion" and takes priority over static backlog refinement. The
current Step 7 precedence evaluates lifecycle gaps before wave state, so a
project with an active wave plus any unshaped P0/P1 idea (or any other gap on a
non-wave idea) is told to `/arc-shape` the stray idea instead of driving the
wave. This spec rewrites the precedence to scope gap-based recommendations to
wave-linked ideas when a wave exists, and surfaces wave-level actions
(`/arc-wave`, `/arc-audit`) when wave-linked work is clean.

## Goals

1. When an active wave exists, scope next-step recommendations to wave-linked
   ideas — gaps on ideas outside the wave do not drive the recommendation.
2. Differentiate recommendations for `planned` vs. `active` wave status so the
   user is guided to activate a planned wave or audit an active one.
3. Flag empty active waves (zero linked ideas) as an incomplete state that
   needs `/arc-wave` to assign ideas before the wave can progress.
4. Preserve visibility of non-wave gaps by displaying them in the Lifecycle
   Gaps table with a scope marker, even when they are suppressed from the
   recommendation.
5. Preserve current behavior when no wave exists — the existing gap-first
   precedence continues to apply for projects with an empty or fully-completed
   roadmap.

## User Stories

- As a product owner mid-wave, I want `/arc-status` to tell me what the next
  step is **for my wave**, not to detour into refining captured ideas I
  deliberately deferred outside the wave.
- As a tech lead with a freshly planned wave, I want `/arc-status` to nudge me
  to activate the wave rather than send me down the SDD pipeline on a
  backlog-only idea.
- As a developer running `/arc-status` on an empty active wave, I want to be
  told to assign ideas to the wave rather than be shown an unrelated gap.
- As a reader scanning the Lifecycle Gaps table, I want to see which gaps are
  part of the current wave and which are backlog-only, so I understand why a
  gap is (or is not) driving the recommendation.

## Demoable Units of Work

### Unit 1: Wave-Linkage Detection and Gap Scoping

**Purpose:** Resolve the active wave, compute the set of wave-linked ideas,
tag each detected lifecycle gap with a scope label (wave-linked vs.
backlog-only), and display a Scope column in the Lifecycle Gaps table when
a wave is active.

**Functional Requirements:**

- The system shall extract the **active wave name** from `docs/ROADMAP.md`
  during Step 2 — the verbatim string in the Wave column of the first row
  whose Status is not `Completed`. If no such row exists (no ROADMAP, empty
  table, or all rows Completed), the active wave name is null.
- The system shall extract the **active wave status** from the same row
  (values: `planned` or `active`; legacy value `Completed` is excluded by the
  existing row filter). If wave name is null, wave status is null.
- The system shall compute the **wave-linked idea set** by scanning the
  `docs/BACKLOG.md` summary table and collecting every idea title whose `Wave`
  column equals the active wave name by **exact case-sensitive string match**
  (after trimming surrounding whitespace from both values). If active wave
  name is null, the wave-linked set is empty.
- The system shall tag each lifecycle gap detected in Step 6 with a scope
  field:
  - `wave-linked` — the gap's subject idea is in the wave-linked idea set,
    OR (for spec-scoped gaps LG-3/LG-4) the spec's linked backlog idea
    (via `Spec:` field match) is in the wave-linked set.
  - `backlog-only` — the gap's subject is not in the wave-linked set.
  - When no active wave exists, scope is always `backlog-only` (functionally
    unused — the display and recommendation both ignore the scope field in
    that case).
- The system shall render the Lifecycle Gaps table with an additional
  `Scope` column **only when an active wave exists**. Column values:
  - For `wave-linked`: the string `Wave: {Wave Name}` (verbatim wave name).
  - For `backlog-only`: the string `Backlog (outside wave)`.
- When no active wave exists, the system shall render the Lifecycle Gaps
  table in its existing three-column format (`Gap | Item | Remediation`) with
  no Scope column.
- Skipped checks shall continue to render as `| (skipped — reason) | -- |`
  with the Scope column populated as `--` when it is present.
- The existing `No lifecycle gaps detected.` message shall remain unchanged.

**Proof Artifacts:**

- File: `skills/arc-status/SKILL.md` Step 2 updated to extract the active
  wave status value (in addition to wave name and count) and make both values
  available to downstream steps.
- File: `skills/arc-status/SKILL.md` Step 6 updated to compute the
  wave-linked idea set and tag each gap with its scope field before emitting
  the table.
- File: `skills/arc-status/references/status-dimensions.md` documents the
  wave-linkage algorithm (exact match rule, whitespace trim, case
  sensitivity, spec-to-idea linkage via `Spec:` field for LG-3/LG-4) in a new
  `Wave Linkage Detection` section.
- CLI: `/arc-status` run on a project with an active wave named `Wave 4 —
  Foo` and a mix of wave-linked and non-wave gaps emits a Lifecycle Gaps
  table containing a `Scope` column with `Wave: Wave 4 — Foo` rows and
  `Backlog (outside wave)` rows as appropriate.
- CLI: `/arc-status` run on a project with no active wave emits the Lifecycle
  Gaps table in the original three-column format without a Scope column.

### Unit 2: Wave-Priority Next-Step Precedence

**Purpose:** Replace the current flat 7-priority precedence with a
wave-state-aware precedence table that recommends wave-level actions
(`/arc-wave`, `/arc-audit`) when a wave is in motion and suppresses
recommendations driven by gaps on non-wave ideas.

**Functional Requirements:**

- The system shall replace the existing Step 7 precedence with the following
  table, evaluated first-match-wins from Priority 1 downward:

  | Priority | Condition | Recommended Skill | Reason Template |
  |----------|-----------|-------------------|-----------------|
  | 1 | Active wave exists AND wave-linked idea set is empty | `/arc-wave` | "Wave {Name} is {status} but has no ideas assigned — assign backlog ideas?" |
  | 2 | Wave-linked LG-5 (Validation → Shipped) gap exists | `/arc-ship` | "{Idea Title} (in Wave {Name}) has a validation PASS but is still spec-ready — ship it?" |
  | 3 | Wave-linked LG-4 (Plan → Validation) gap exists | `/cw-validate` | "{NN}-spec-{name} (in Wave {Name}) has plan evidence but no validation report — validate it?" |
  | 4 | Wave-linked LG-3 (Spec → Plan) gap exists | `/cw-plan` | "{NN}-spec-{name} (in Wave {Name}) has a spec but no plan — plan it?" |
  | 5 | Wave-linked LG-2 (Shaped → Spec) gap exists | `/cw-spec` | "{Idea Title} (in Wave {Name}) is shaped but has no spec — write a spec?" |
  | 6 | Wave-linked LG-1 (Captured → Shaped) gap on a P0 or P1 idea | `/arc-shape` | "{Idea Title} (in Wave {Name}) is captured at {Priority} but unshaped — shape it?" |
  | 7 | Active wave status is `planned` AND no wave-linked gaps remain | `/arc-wave` | "Wave {Name} is planned with no open gaps on assigned ideas — activate it?" |
  | 8 | Active wave status is `active` AND no wave-linked gaps remain | `/arc-audit` | "Wave {Name} is active and wave-linked work is clean — audit wave health?" |
  | 9 | No active wave AND an LG-5 gap exists | `/arc-ship` | (existing reason template) |
  | 10 | No active wave AND an LG-4 gap exists | `/cw-validate` | (existing) |
  | 11 | No active wave AND an LG-3 gap exists | `/cw-plan` | (existing) |
  | 12 | No active wave AND an LG-2 gap exists | `/cw-spec` | (existing) |
  | 13 | No active wave AND an LG-1 gap on a P0 or P1 idea exists | `/arc-shape` | (existing) |
  | 14 | No active wave AND no gaps | `/arc-wave` | "No gaps and no active wave — plan the next delivery wave?" |

- The system shall select the **alternative skill** for the
  `AskUserQuestion` prompt as follows:
  - For Priorities 2–6 (wave-linked gap): offer the next-lower-priority
    wave-linked gap that also matched. If none, offer `/arc-audit`.
  - For Priority 1 (empty wave): offer `/arc-audit`.
  - For Priorities 7 and 8 (clean wave): offer the other of `/arc-wave` or
    `/arc-audit`.
  - For Priorities 9–13 (no-wave gaps): offer the next-lower-priority
    matching gap skill; otherwise `/arc-audit`.
  - For Priority 14 (no wave, no gaps): offer `/arc-audit`.
- The system shall never recommend a skill driven by a backlog-only gap when
  an active wave exists. Backlog-only gaps do not satisfy Priorities 2–6 and
  are not considered by Priorities 7 and 8.
- The `AskUserQuestion` prompt format shall continue to require at least
  three options: the recommended skill labeled `(Recommended)`, one
  alternative, and `Done for now`.
- The Priority 6 P0/P1 filter shall read the `Priority:` field from the
  idea's metadata block in `docs/BACKLOG.md`, matching the existing
  Priority-5 filter behavior in the pre-change skill.
- When the active wave name contains characters that need escaping inside an
  `AskUserQuestion` label or question string, the system shall pass the wave
  name verbatim — no escaping transformations beyond standard JSON string
  encoding.

**Proof Artifacts:**

- File: `skills/arc-status/SKILL.md` Step 7 updated to document the new
  14-row precedence table, the alternative-skill selection rules, and the
  wave-name interpolation for reason templates.
- File: `skills/arc-status/references/status-dimensions.md`
  `Next-Step Suggestion Precedence` section rewritten to match Step 7,
  including the wave-linkage dependency on Unit 1.
- CLI: `/arc-status` on a fixture with an active `planned` wave containing
  one assigned idea that is `captured` P1 and one backlog-only `shaped` idea
  with no spec emits a `/arc-shape` recommendation (Priority 6), not the
  `/cw-spec` that the old precedence would have produced.
- CLI: `/arc-status` on a fixture with an active `active` wave containing
  only shipped or fully-progressed ideas and one backlog-only captured P0
  idea emits an `/arc-audit` recommendation (Priority 8), not the
  `/arc-shape` the old precedence would have produced.
- CLI: `/arc-status` on a fixture with an active `planned` wave and zero
  assigned ideas emits an `/arc-wave` recommendation (Priority 1).
- CLI: `/arc-status` on a fixture with no ROADMAP and an LG-2 gap emits a
  `/cw-spec` recommendation (Priority 12) — confirming no-wave fallback is
  unchanged.

## Non-Goals (Out of Scope)

- **Stalled-wave detection.** Heuristics for detecting that an active wave
  has made no progress in N days are deferred. This spec trusts the ROADMAP
  wave status field as authoritative.
- **Multi-wave support.** The spec assumes one active wave at a time (the
  first non-Completed row), matching existing skill behavior.
- **Backlog-only gap display changes** beyond the Scope column. No
  reordering, hiding, or grouping of backlog-only gaps is introduced.
- **Wave activation or transition skills.** This spec only recommends
  `/arc-wave`; it does not add planned→active transition logic to
  `arc-wave` itself.
- **Backlog idea wave-assignment UX.** This spec recommends `/arc-wave` for
  empty waves; it does not introduce new idea-to-wave assignment affordances.
- **Test harness for arc-status.** No new test runner is added; proof
  artifacts are verified by running the skill against crafted fixtures.

## Design Considerations

- **Scope-column rendering** is conditional on active-wave presence to keep
  the table compact for no-wave projects. This is a small branch in Step 6's
  output formatter.
- **Wave name with special markdown characters** (e.g., em dashes, colons)
  must pass through verbatim in both the table and the `AskUserQuestion`
  reason template so users see the exact roadmap string.
- **Skipped-check rows** inherit `--` in the Scope column when rendered in
  active-wave mode — scope cannot be computed for a check that failed to
  execute.

## Repository Standards

- Follow the Arc plugin skill conventions: context marker `**ARC-STATUS**`,
  read-only operation, `AskUserQuestion` for all skill-invocation prompts.
- Honor the ordering invariants documented in
  `references/skill-orchestration.md`.
- Conventional commit messages (`fix(arc-status): ...`).
- Standard Bash vs. built-in tools rules from CLAUDE.md apply.

## Technical Considerations

- The wave-linkage computation is a simple set-membership operation. For a
  project with M backlog ideas, it is O(M) — a single pass over the
  BACKLOG summary table to filter by the exact `Wave` match.
- Gap scope tagging adds O(G) work where G is the number of detected gaps.
  G is bounded by the existing LG-1..LG-5 detection, no change in
  complexity class.
- LG-3 and LG-4 resolve their subject via spec directory name; to scope
  these by wave, the system must look up the backlog idea linked to the
  spec (via a BACKLOG `Spec:` field whose value equals the spec directory
  path). If no such backlog idea exists, the gap is `backlog-only` by
  default. This is a read-only filesystem + text operation; no new
  dependencies.
- The existing fallback for "all waves completed" continues to return a
  null active wave, so the precedence falls through to Priorities 9–14 —
  preserving no-wave behavior for fully-completed roadmaps.

## Security Considerations

None. The skill is strictly read-only, does not touch credentials, and
operates only on already-readable repository files.

## Success Metrics

- `/arc-status` on a project with an active wave and wave-linked gaps
  recommends a wave-scoped action in 100% of fixture cases (confirmed by
  crafted-fixture CLI proof artifacts).
- `/arc-status` on a project with an active wave and only non-wave gaps
  recommends `/arc-wave` or `/arc-audit` (never a backlog-gap skill) in
  100% of fixture cases.
- No regression in no-wave recommendation behavior (Priority 9–14 rows
  mirror the previous Priority 1–7 rows exactly except for clarified
  templates).
- Running `/arc-status` on the Arc repo itself (currently no active wave)
  continues to produce its current recommendation.

## Open Questions

No open questions at this time.
