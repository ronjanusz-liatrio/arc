# T26 Proof Summary

Task: T05.2 — Update arc-wave, arc-audit, arc-shape SKILL.md to reference new templates

## Artifacts

| File | Type | Status |
|------|------|--------|
| T26-01-grep.txt | cli grep | PASS |
| T26-02-grep.txt | cli grep | PASS |
| T26-03-grep.txt | cli grep | PASS |

## Changes Made

### skills/arc-wave/SKILL.md

- Step 10: Replaced inline 45-line wave report markdown block with: `Read \`templates/wave-report.tmpl.md\` for the report format. Render each \`{SlotName}\` placeholder with values derived from the wave planning session. Save the rendered report to \`docs/skill/arc/wave-report.md\`.`
- Step 10 Target rendering note: Updated cross-reference from `skills/arc-wave/references/wave-report-template.md` to `templates/wave-report.tmpl.md`
- References section: Replaced `skills/arc-wave/references/wave-report-template.md` entry with `templates/wave-report.tmpl.md`

### skills/arc-audit/SKILL.md

- Step 5: Replaced `Read \`skills/arc-audit/references/review-report-template.md\` for the full report format.` with `Read \`templates/audit-report.tmpl.md\` for the full report format. Render each \`{SlotName}\` placeholder with values derived from the audit session.`
- References section: Replaced `skills/arc-audit/references/review-report-template.md` entry with `templates/audit-report.tmpl.md`

### skills/arc-shape/SKILL.md

- Step 7: Replaced inline 29-line shape report markdown block with: `Read \`templates/shape-report.tmpl.md\` for the report format. Render each \`{SlotName}\` placeholder with values from the shaping session. Save the rendered report to \`docs/skill/arc/shape-report.md\`.`
- References section: Added `templates/shape-report.tmpl.md` entry

## Zero Behavior Change Verification

- arc-wave template `templates/wave-report.tmpl.md` was confirmed to contain the same sections as the inline block: Wave Goal, Selected Ideas, Dependencies and Blockers, Engineering Readiness, Temper Context, Handoff Instructions, Backlog Status.
- arc-audit template `templates/audit-report.tmpl.md` was confirmed to contain the same report sections as listed in Step 5 prose.
- arc-shape template `templates/shape-report.tmpl.md` was confirmed to contain the same sections as the inline block: Before (Captured Stub), Subagent Analysis Summary, Relevant Skills, After (Shaped Brief), Gaps Resolved During Q&A, Open Questions Deferred.
- Frontmatter (requires/produces/consumes/triggers) is unchanged in all three files.
