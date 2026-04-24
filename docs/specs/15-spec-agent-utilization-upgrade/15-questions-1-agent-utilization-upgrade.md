# Clarifying Questions — Round 1

**Spec:** 15-spec-agent-utilization-upgrade
**Date:** 2026-04-22

## Q1: Scope

**Question:** This spec could fit 5-6 demoable units. How should we scope it?

**Options presented:**
- All 5 required units in one spec (defer trigger eval)
- Split into two specs: foundation + infrastructure
- All 6 units including trigger eval

**Answer:** **All 6 units including trigger eval.** Trigger-eval bundle is in scope.

## Q2: Orchestration prescriptiveness

**Question:** How prescriptive should `references/skill-orchestration.md` be?

**Options presented:**
- Descriptive guidance
- Prescriptive contract with enforced invariants

**Answer:** **Descriptive guidance.** State-vector, validity matrix, and invariants documented; validators offer warnings, not hard refusals.

## Q3: Frontmatter field requirement

**Question:** Should new frontmatter fields (`requires`/`produces`/`consumes`/`triggers`) be required or optional?

**Options presented:**
- Required on all 9 arc skills, optional for future skills
- Optional across the board

**Answer:** **Required on all 9 arc skills, optional for future skills.** Sets the bar for arc; additive so no breaking changes.

## Q4: Manifest updates

**Question:** Does `.claude-plugin/plugin.json` need updates, or just `marketplace.json`?

**Options presented:**
- Just `marketplace.json`
- Both — add a `skills` array to `plugin.json` too

**Answer:** **Both.** Add a `skills` array to `plugin.json` alongside the `marketplace.json` fix.

## Implications for the spec

- 6 demoable units (all 5 required + tier-3 trigger eval).
- Orchestration contract is a reference document, not enforcement — validators WARN but do not refuse to run.
- Frontmatter additions are *required* for arc's 9 skills as part of this spec; external skills may opt in.
- Both plugin manifests get updated; add `skills` array to `plugin.json` with an Open Question flagged about whether Claude Code reads the field or treats it as purely documentation.
