# Code Review Report (Pass 2): agent-utilization-upgrade

**Reviewed:** 2026-04-24 (second pass after fix cycle)
**Branch:** main
**Base:** `303b420` (H1-remediation; pre-fix-pass snapshot)
**Commits in scope:** 7 fix commits (02674d3, df5cd37, 52bfb2f, 62bc677, 1ae3c9f, 6e03ed3, 7477b34)
**Overall:** **APPROVED**

## Summary

- **Blocking Issues:** 0
- **Advisory Notes:** 3
- **Files Reviewed:** 14 implementation files across 2 parallel reviewer batches
- **FIX Tasks Created:** none (Category D advisories don't block merge)

Pass 2 focused exclusively on regressions introduced by the fix cycle. All 12 blocking issues from Pass 1 are remediated and none of the fixes introduced new blocking issues. The 3 advisory notes below are quality-of-life items for a follow-up.

## Automated gates (all green)

- ShellCheck `--severity=style` on all 5 scripts: exit 0, zero findings
- `scripts/state.sh`: exit 0, valid JSON, all 6 required fields
- `scripts/validate-backlog.sh docs/BACKLOG.md`: exit 0, 20/20 entries pass
- `scripts/validate-roadmap.sh docs/ROADMAP.md`: exit 0
- `scripts/validate-brief.sh` on fake BACKLOG with empty success_criteria: exit 1 with named diagnostic (FIX-37 verified)
- `scripts/parse-frontmatter.sh` with duplicate parent-dir-name inputs: exit 0, no collision (FIX-38 verified)
- All 6 schemas/tests fixtures validate as expected (pass fixtures pass, fail fixtures fail with correct diagnostics)
- All 9 SKILL.md files: single `ARC-{SKILL-NAME}` marker each
- arc-help Critical Constraints section: placement and bullet format match the other 8 skills

## Fix-pass correctness checklist

| Fix | Claim | Verified? |
|---|---|---|
| T35 prefix-match parser | Handles `PASS*`, `PENDING*`, `FAIL*` with suffixes | ✓ Confirmed |
| T35 portability | No regressions on Linux | ✓ All scripts exit 0 |
| T36 jq --arg escaping | Goals with quotes/backslashes safe | ✓ Confirmed |
| T37 empty-array filter | False-negative risk on legitimate-list inputs | ✓ No false negatives |
| T38 sha256 temp filenames | Collision-free for duplicate parent-dir-name | ✓ Both entries present |
| T39 schema oneOf | Structural match with brief.schema.json | ✓ jq diff shows only description drift |
| T40 arc-help Critical Constraints | Matches convention | ✓ Placement + format correct |
| T41 frontmatter drifts | All 4 target fields corrected | ✓ yq-parse confirms |
| 303b420 H1 markers (base) | arc-assess/audit/sync markers consistent | ✓ No fix-pass re-touches |

## Advisory Notes

### [NOTE-1] Category D: validate-roadmap.sh TSV pipeline breaks on embedded tabs
- **File:** `scripts/validate-roadmap.sh:108-131`
- **Description:** The `IFS=$'\t' read` step misaligns columns when a markdown cell contains a literal tab, causing `jq --argjson ideas` to fail with "invalid JSON text passed to --argjson" and the script to die with exit 2 under `set -euo pipefail`. The comment at lines 78-80 claims "values containing tabs or newlines are still handled safely" — inaccurate.
- **Severity:** Advisory (pre-existing behavior, not a fix-pass regression)
- **Suggestion:** Either sanitize embedded tabs with `gsub(/\t/, " ", ...)` in awk before printf, or reword the comment. Follow-up.

### [NOTE-2] Category D: state.sh prefix-match could misclassify rare identifiers
- **File:** `scripts/state.sh:246-251`
- **Description:** Case arms `PASS*`/`PENDING*`/`FAIL*` greedily match verdicts like `PASSTHROUGH` → PASS, `FAILSAFE` → FAIL, `PENDINGPASS` → PENDING. The documented intent is to tolerate parenthetical suffixes and dash explanations, not arbitrary identifier continuation.
- **Severity:** Advisory (edge case with unusual manual verdict text)
- **Suggestion:** Normalize `verdict` to its first whitespace-delimited token before case-matching: `split($2, a, /[[:space:]]/); print toupper(a[1])`. Preserves "PENDING - awaiting review" while tightening against `PASSTHROUGH`.

### [NOTE-3] Category D: arc-ship `requires.artifacts` still lists ROADMAP
- **File:** `skills/arc-ship/SKILL.md:9-11`
- **Description:** FIX-41 correctly removed `docs/ROADMAP.md` from `requires.files`, but `ROADMAP` remains in `requires.artifacts`. The files-list now reflects the optional status; the artifacts-list does not. Body (line 103: "docs/ROADMAP.md — Optional. Read if present.") treats it as optional.
- **Severity:** Advisory (FIX-41 scope was explicitly files-only per task prompt)
- **Suggestion:** Follow-up commit: remove `ROADMAP` from `requires.artifacts`, leaving only `BACKLOG`. Body already handles absent-ROADMAP gracefully.

## Files Reviewed

| File | Batch | Fix-pass change | Issues |
|------|-------|-----------------|--------|
| `scripts/state.sh` | 42 | T35 (portability) | Clean (1 advisory) |
| `scripts/validate-backlog.sh` | 42 | T35 | Clean |
| `scripts/validate-brief.sh` | 42 | T35 + T37 | Clean |
| `scripts/validate-roadmap.sh` | 42 | T36 | Clean (1 advisory) |
| `scripts/parse-frontmatter.sh` | 42 | T35 + T38 | Clean |
| `schemas/backlog-entry.schema.json` | 43 | T39 (open_questions oneOf) | Clean |
| `schemas/tests/backlog-entry-open-questions-none.json` | 43 | T39 (new fixture) | Clean |
| `skills/arc-capture/SKILL.md` | 43 | T41 (requires.artifacts=[]) | Clean |
| `skills/arc-wave/SKILL.md` | 43 | T41 (requires.files/artifacts + consumes) | Clean |
| `skills/arc-ship/SKILL.md` | 43 | T41 (requires.files) | Clean (1 advisory) |
| `skills/arc-help/SKILL.md` | 43 | T40 (Critical Constraints) | Clean |
| `skills/arc-assess/SKILL.md` | 43 | unchanged since 303b420 | Clean (verified unchanged) |
| `skills/arc-audit/SKILL.md` | 43 | unchanged since 303b420 | Clean (verified unchanged) |
| `skills/arc-sync/SKILL.md` | 43 | unchanged since 303b420 | Clean (verified unchanged) |

## Checklist

- [x] No hardcoded credentials or secrets
- [x] Error handling at system boundaries preserved
- [x] Input validation unchanged or improved by fixes
- [x] Fix-pass commits on-scope (only files listed in each FIX task touched)
- [x] Repo standards (ShellCheck, marker convention, frontmatter contract)
- [x] No performance regressions (state.sh still <500ms budget)
- [x] Cross-platform intent maintained (macOS bash 3.2 compatibility per T35)
- [x] Schema/frontmatter contracts self-consistent (drift corrections applied)

## Recommendation

**APPROVED for PR.** The 3 advisory notes are worth a small follow-up commit but do not block merge. Suggested follow-up scope: ~15 minutes.
