# State Vector → Recommended Next Skill Mapping

This document extends the **Worked Example** from `references/skill-orchestration.md` with additional state vector scenarios and their recommended next skills. Each row shows a distinct project state and the dispatcher's reasoning for the recommended skill per the Dispatcher Precedence list (P1–P7).

## Mapping Table

| Scenario | `idea_status` | `shaped_count` | `spec_ready_count` | `wave_active` | `validation_status` | Recommended Skill | Reasoning |
|----------|---------------|----------------|--------------------|---------------|---------------------|-------------------|-----------|
| **Empty backlog (project inception)** | `captured` | 0 | 0 | `false` | `N/A` | `/arc-shape` | First idea is captured but unshaped. Matches P5: "Captured → Shaped gap exists on a P0 or P1 idea". No other gaps present; shaping must precede spec writing. |
| **Two ideas shaped, no wave started** | `shaped` | 2 | 0 | `false` | `N/A` | `/cw-spec` | Two shaped ideas exist with no spec directory for either. Matches P4: "Shaped → Spec gap exists". Dispatcher recommends spec creation to unblock wave planning. |
| **Wave active, spec written, plan exists, no validation** | `spec-ready` | 0 | 1 | `true` | `PENDING` | `/cw-validate` | One spec-ready idea in an active wave has plan evidence but no validation report. Matches P2: "Plan → Validation gap exists". SDD pipeline stalls here until validation completes. |
| **Validation passed, idea not yet shipped** | `spec-ready` | 0 | 1 | `true` | `PASS` | `/arc-ship` | Spec-ready idea has `validation_status = "PASS"` but has not transitioned to shipped. Matches P1 (highest priority): "Validation → Shipped gap exists". Must ship before closing the wave. |
| **All ideas shipped, wave closeable** | `shipped` | 0 | 0 | `false` | `PASS` | `/arc-wave` | No gaps present (`idea_status = "shipped"`, `wave_active = false`, all counts 0). Matches P7: "No gaps AND wave_active = false". Dispatcher recommends planning the next delivery wave. |
| **Post-validation failure recovery** | `spec-ready` | 1 | 1 | `true` | `FAIL` | `/cw-spec` | One spec-ready idea in an active wave failed validation. The backlog also has 1 shaped idea. P2 check fails (no PASS); P3 check fails (plan evidence exists). P4 triggers: shaped idea has no spec. Prioritize spec creation for the shaped backup idea. |
| **Mid-wave with plan evidence gap** | `spec-ready` | 0 | 1 | `true` | `N/A` | `/cw-plan` | One spec-ready idea in an active wave exists; spec directory present but no plan files yet. Matches P3: "Spec → Plan gap exists". SDD pipeline stalls at planning phase. |
| **Multiple shaped, first wave planned** | `shaped` | 3 | 0 | `true` | `N/A` | `/cw-spec` | Wave is active; 3 shaped ideas in backlog, none yet spec-ready. Matches P4: "Shaped → Spec gap exists". Dispatcher recommends spec creation for the wave's assigned ideas. |
| **Captured idea at P0 priority in active wave** | `captured` | 1 | 1 | `true` | `PASS` | `/arc-shape` | One spec-ready idea in active wave has passed validation; one shaped idea in backlog. P1 check fails (PASS + spec-ready ≠ shipped, but no other gaps). P2–P4 checks fail (plan and spec evidence exist). P5 triggers: captured idea unshaped. Shape it to unblock next spec cycle. |

## Notes

1. **Precedence evaluation is first-match-wins**: Each state vector is evaluated against the Dispatcher Precedence list (P1–P7 from `references/skill-orchestration.md`) in order. The first matching condition determines the recommended skill.

2. **State vector completeness**: All five fields (`idea_status`, `shaped_count`, `spec_ready_count`, `wave_active`, `validation_status`) are shown in each row. A real state vector returned by `scripts/state.sh` will include all five fields in JSON form.

3. **Grounding in the source**: Rows 1–5 directly correspond to the 5-row example table in the Worked Example section of `references/skill-orchestration.md` (lines 108–114). Rows 6–9 are extensions that demonstrate additional realistic project states not covered in the source table.

4. **Dispatcher implementation**: The reasoning for each recommendation is derived from the Dispatcher Precedence logic (P1–P7, lines 79–87 of `references/skill-orchestration.md`). Validators and autonomous dispatchers can use this table as a reference for expected skill recommendations under different state conditions.

## Cross-Reference

- Source table: `references/skill-orchestration.md` § Worked Example, lines 108–134
- Precedence rules: `references/skill-orchestration.md` § Dispatcher Precedence, lines 75–87
- State vector definition: `references/skill-orchestration.md` § State Vector, lines 5–29
