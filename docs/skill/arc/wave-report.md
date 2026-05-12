# Wave Report: Status Visibility

**Created:** 2026-05-08T19:00:00Z
**Theme:** Status Visibility
**Target:** TBD (use /arc-wave to add)

## Wave Goal

Make `/arc-status` and `/arc-assess` accurately reflect lifecycle state. Today both skills produce false-clean signals: `/arc-status` hides PASS-validated specs that bypassed the capture→shape→wave→ship flow (LG-5 silently skips them) and lists every spec directory ever created in its In-Flight table; `/arc-assess` re-creates duplicate captured stubs from already-shipped spec user stories on every re-run, undoing what spec 08 manually fixed. This wave restores trust in the Product Owner's pulse check (`/arc-status`) and the Tech Lead's safe-rerun guarantee (`/arc-assess`) by re-anchoring both detection paths on the wave archive — the single authoritative completion source defined by spec 13.

## Selected Ideas

| # | Title | Priority | Summary |
|---|-------|----------|---------|
| 1 | [Detect orphan specs and exclude completed specs from arc-status](docs/BACKLOG.md#detect-orphan-specs-and-exclude-completed-specs-from-arc-status) | P0-Critical | Add LG-6 lifecycle gap for orphan PASS-validated specs and filter the In-Flight Specs table to exclude specs already present in the wave archive. |
| 2 | [Classify shipped-spec user stories as merge candidates in arc-assess](docs/BACKLOG.md#classify-shipped-spec-user-stories-as-merge-candidates-in-arc-assess) | P2-Medium | Add a "merge-candidate" sub-branch to KW-19 detection so `/arc-assess` re-runs do not re-create duplicate captured stubs from already-shipped spec user stories. |

## Dependencies and Blockers

- None identified. Both ideas are additive prose changes to independent skills (`/arc-status` and `/arc-assess`) and share no code paths. They can be specced and shipped in any order.

## Engineering Readiness

- **Temper Phase:** Not available — Temper not configured
- **Gate Status:** Not available
- **Failing Gates:** Not available
- **Delivery Risk:** Low — both ideas are prose-only edits to existing skill SKILL.md files, fitting established LG-* and KW-* branching patterns. No code paths, no new infrastructure, no spike required.
- **Recommendation:** Not available — Temper not configured

## Temper Context

**Phase:** Not available
**Hard gate failures:** Not available
**Scope constraint:** No constraints applied

> No Temper management report available. Wave planned without phase constraints.

## Handoff Instructions

For each spec-ready idea in this wave, proceed with the SDD pipeline:

1. Run `/cw-spec` with the idea's brief as input:
   - Copy the brief sections from `docs/BACKLOG.md#{IdeaAnchor}`
   - Use the brief's Problem, Proposed Solution, and Success Criteria as the spec starter prompt

2. After spec generation, continue with `/cw-plan` → `/cw-dispatch`

3. After implementation, run `/temper-audit` to evaluate gate status

### Per-Idea Handoff

| Idea | Status | Next Action |
|------|--------|-------------|
| Detect orphan specs and exclude completed specs from arc-status | spec-ready | `/cw-spec` — Add LG-6 detection (PASS-validated orphan specs with no BACKLOG `Spec:` link) plus an In-Flight filter that excludes specs whose dir name appears in `docs/skill/arc/waves/*.md` (subsection title or `**Spec:**` field). Extend Step 6.6 scope tagging and Step 7 precedence list. Append-only — no renumbering of LG-1..LG-5 or priorities 1–13. |
| Classify shipped-spec user stories as merge candidates in arc-assess | spec-ready | `/cw-spec` — Add a "merge-candidate" sub-branch to the KW-19 classification rule. Build a shipped-spec index from `docs/skill/arc/waves/*.md` using both signals OR'd. When KW-19 hits in a shipped spec dir, emit a report-only annotation in `align-report.md`; multi-match cases list all candidates for user confirmation; persona extraction continues unchanged. |

## Backlog Status

| Status | Count |
|--------|-------|
| Captured | 19 |
| Shaped | 0 |
| Spec-Ready | 2 |
| Shipped | 11 |
| **Total** | **32** |
