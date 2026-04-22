# T25 Proof Summary — T05.1: Author 3 output templates

**Task:** T05.1 — Author 3 output templates (wave-report, audit-report, shape-report)
**Status:** COMPLETED
**Completed:** 2026-04-22T15:41:00Z
**Model:** sonnet

## Files Created

- `templates/wave-report.tmpl.md` — Wave report template for `/arc-wave` Step 10
- `templates/audit-report.tmpl.md` — Audit report template for `/arc-audit` Step 5
- `templates/shape-report.tmpl.md` — Shape report template for `/arc-shape` Step 7

## Proof Artifacts

| File | Type | Status | Description |
|------|------|--------|-------------|
| T25-01-file.txt | file | PASS | All 3 template files present under templates/ |
| T25-02-file.txt | file | PASS | {SlotName} convention used throughout; no divergent syntax |
| T25-03-file.txt | file | PASS | Each template ends with Acceptance Criteria (5 bullets each) |

## Template Design Decisions

### Shape Derivation

Each template shape was derived by reading the corresponding SKILL.md file:

- **wave-report.tmpl.md**: Derived from `/arc-wave` Step 10 inline report format plus the existing `skills/arc-wave/references/wave-report-template.md` reference. Added the Engineering Readiness section from Step 1.5.
- **audit-report.tmpl.md**: Derived from `/arc-audit` Step 5 output format, the `skills/arc-audit/references/review-report-template.md` reference, and the Engineering Maturity section from SKILL.md Step 5.
- **shape-report.tmpl.md**: Derived from `/arc-shape` Step 7 output format, including the Subagent Analysis Summary table (5 dimensions including Skill Discovery), the full Shaped Brief, Gaps Resolved, and Open Questions Deferred sections.

### Placeholder Convention

All placeholders use the `{SlotName}` convention matching the existing 4 arc templates (BACKLOG.tmpl.md, VISION.tmpl.md, CUSTOMER.tmpl.md, ROADMAP.tmpl.md). No divergent syntax (`<<Slot>>`, `${Slot}`, `[[Slot]]`) was introduced.

### Acceptance Criteria

Each template ends with an "Acceptance Criteria" section containing exactly 5 bullets, phrased as pass/fail checks that an agent running the corresponding skill can evaluate against the generated report.

### What Is NOT Done (by design)

Per task constraints:
- Skills are NOT yet wired to use these templates (blocked by this task — T05.2 does that)
- Filled-in examples are NOT rendered (T05.3 does that)
