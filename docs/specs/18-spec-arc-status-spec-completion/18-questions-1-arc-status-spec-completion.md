# Spec Questions — Round 1: arc-status-spec-completion

## Resolved during shaping (BACKLOG `Detect orphan specs and exclude completed specs from arc-status`)

| Question | Answer |
|----------|--------|
| What signal makes a spec "completed" for the In-Flight filter? | Wave archive only — spec dir name appears as `### {Title}` subsection or `Spec:` field value inside `docs/skill/arc/waves/*.md`. Single source of truth, matches SD-2 shipped count. |
| Which spec dirs should LG-6 flag? | PASS-validated orphans only — spec dir has `*-validation-*.md` with `**Overall**: PASS` AND no BACKLOG idea links via `Spec:`. |
| What remediation should LG-6 suggest? | Run `/arc-capture` then `/arc-shape` — retroactively create a BACKLOG entry, reusing existing skills. |
| One spec or two? | One combined spec — both fixes share data sources and touch the same skill steps. |

## Resolved during cw-spec Round 1

| Question | Answer | Rationale |
|----------|--------|-----------|
| Should the two demoable units be sequential or parallel? | Parallel — independent. | LG-6 (Step 6) and In-Flight filter (Step 4) touch separate steps in the same skill. Two parent tasks with no dependency edge. |
| When In-Flight excludes completed specs, render a count note? | Silent exclusion. | Matches the existing "no fallback notice" convention when items are absent. Keeps output stable. |
| Update the worked example in `status-dimensions.md`? | Update existing worked example. | Add an LG-6 row and a filtered-out completed-spec callout to the existing example so docs stay coherent. |
| Proof strategy? | Manual `/arc-status` re-run + diff check. | Run `/arc-status` before/after on the current repo. Capture In-Flight + Lifecycle Gaps. Verify spec 17 surfaces as LG-6 and shipped specs vanish from In-Flight. Augmented by auto-generated Gherkin via cw-gherkin. |

## Open questions

None.
