# Code Review Report

**Reviewed**: 2026-04-08
**Branch**: main (commits 710de7c..1ccdf2e)
**Base**: 8186ac4
**Commits**: 11 commits, 12 implementation files
**Overall**: CHANGES REQUESTED

## Summary

- **Blocking Issues**: 5 (A: 4 correctness, C: 1 spec compliance)
- **Advisory Notes**: 12
- **Files Reviewed**: 12 / 12 implementation files
- **FIX Tasks Created**: #29, #30, #31, #32, #33

## Blocking Issues

### [B1] Category A: Mermaid classDef styles declared but never applied
- **Files**: `skills/arc-readme/SKILL.md:333-336`, `skills/arc-readme/references/readme-mapping.md:216-219`
- **Severity**: Blocking
- **Description**: Four `classDef` styles (capture, shape, ready, shipped) with Liatrio brand colors are defined but never bound to nodes. Diagrams render in default colors.
- **Fix**: Add `class` directives after classDef block
- **Task**: #29

### [B2] Category A: Mermaid lifecycle diagram syntax diverges between docs
- **Files**: `skills/arc-readme/SKILL.md:316-337`, `skills/arc-readme/references/readme-mapping.md:206-214`
- **Severity**: Blocking
- **Description**: SKILL.md uses inline labels with capitalized IDs and backward transitions. readme-mapping.md uses aliased state syntax with lowercase aliases and forward-only. Also affects TS-5 detection regex in trust-signals.md.
- **Fix**: Standardize on readme-mapping.md syntax, update TS-5 regex
- **Task**: #30

### [B3] Category C: Heading placement contradicts between SKILL.md and readme-mapping.md
- **Files**: `skills/arc-readme/SKILL.md:173-289`, `skills/arc-readme/references/readme-mapping.md:57-223`
- **Severity**: Blocking
- **Description**: SKILL.md places `## Heading` outside ARC markers. readme-mapping.md places them inside. Determines whether headings survive update cycles.
- **Fix**: Align readme-mapping.md to SKILL.md convention (headings outside markers)
- **Task**: #31

### [B4] Category A: Roadmap table column mismatch
- **Files**: `skills/arc-readme/references/readme-mapping.md:168`, `skills/arc-readme/SKILL.md:272`, `skills/arc-readme/references/readme-quality-rules.md:101`
- **Severity**: Blocking
- **Description**: readme-mapping.md uses `Wave|Status|Goal`, SKILL.md and quality-rules use `Wave|Theme|Status`
- **Fix**: Standardize on `Wave|Theme|Status` in readme-mapping.md
- **Task**: #32

### [B5] Category A: Scaffold fallback text directs to wrong skill
- **File**: `skills/arc-readme/SKILL.md:215,287`
- **Severity**: Blocking
- **Description**: Scaffold fallbacks recommend `/arc-capture` for CUSTOMER.md and `/arc-wave` for ROADMAP.md — both incorrect. Also, traceability link text diverges from update mode causing unnecessary diff noise on first update.
- **Fix**: Align scaffold fallback text with update mode and readme-mapping.md canonical forms
- **Task**: #33

## Advisory Notes

### [A1] Pipeline diagrams show /arc-readme as mandatory step
- **Files**: `README.md:69,105`, `skills/README.md:17`
- **Description**: Mermaid and ASCII diagrams place arc-readme as a hard edge in the pipeline. Spec says it's "offered after arc-wave" — should use dotted edge for optionality.

### [A2] TS-5 detection regex may not match readme-mapping.md diagram syntax
- **File**: `skills/arc-readme/references/trust-signals.md:143`
- **Description**: Regex `\w+\(\d+\)` expects `Captured(3)` but readme-mapping produces `state "Captured({N})" as captured`. Related to B2 — resolving B2 will clarify.

### [A3] Quality rules mermaid init block incomplete
- **File**: `skills/arc-readme/references/readme-quality-rules.md:159-161`
- **Description**: Shows 3 theme variables; full Liatrio init requires 9. Gate 9 check would pass on incomplete init.

### [A4] WA-7 next-step triggers at <100% while severity threshold is 75%
- **File**: `skills/arc-review/SKILL.md:304-326`
- **Description**: The arc-readme option appears when any signal fails, but severity is only warning below 75%. Technically correct but potentially confusing.

### [A5] WA-7 in audit-dimensions.md duplicates trust-signals.md
- **File**: `skills/arc-review/references/audit-dimensions.md:429-480`
- **Description**: Reproduces trust-signals.md content instead of referencing it. Creates maintenance risk.

### [A6] Scaffold non-managed sections too minimal for own quality gates
- **File**: `skills/arc-readme/SKILL.md:347-362`
- **Description**: Bare blockquote placeholders for Getting Started, Contributing, License don't meet readme-quality-rules.md requirements.

### [A7] SKILL.md overview mentions 2 modes, skill has 3
- **File**: `skills/arc-readme/SKILL.md:16-19`
- **Description**: Overview omits injection mode (Step 2a).

### [A8] Inconsistent cross-reference path prefixes
- **Files**: `skills/arc-review/references/review-report-template.md:99,172`, `audit-dimensions.md:533`
- **Description**: Mix of full repo-root paths and relative-from-skill paths.

### [A9] Marketplace description skill ordering doesn't match pipeline
- **File**: `.claude-plugin/marketplace.json:13`
- **Description**: Lists arc-align last, pipeline puts it first.

### [A10] Lifecycle diagram backward transitions inconsistent between docs
- **File**: `skills/arc-readme/SKILL.md:325-326`
- **Description**: SKILL.md includes backward transitions, readme-mapping.md omits them.

### [A11] Typography conventions inconsistent in quality-rules.md
- **File**: `skills/arc-readme/references/readme-quality-rules.md`
- **Description**: Triple-hyphens for em-dashes, double-hyphens for ranges. Other docs use Unicode characters.

### [A12] Companions field not in original spec
- **File**: `.claude-plugin/plugin.json:5-9`
- **Description**: Added per user request during dispatch. Valid addition but not in spec. No action needed.

## Files Reviewed

| File | Status | Issues |
|------|--------|--------|
| `skills/arc-readme/SKILL.md` | New | 3 blocking, 3 advisory |
| `skills/arc-readme/references/readme-mapping.md` | New | 3 blocking, 1 advisory |
| `skills/arc-readme/references/readme-quality-rules.md` | New | 1 blocking (shared), 2 advisory |
| `skills/arc-readme/references/trust-signals.md` | New | 1 advisory |
| `skills/arc-review/SKILL.md` | Modified | 1 advisory |
| `skills/arc-review/references/audit-dimensions.md` | Modified | 1 advisory |
| `skills/arc-review/references/review-report-template.md` | Modified | 1 advisory |
| `skills/arc-wave/SKILL.md` | Modified | Clean |
| `.claude-plugin/plugin.json` | Modified | 1 advisory |
| `.claude-plugin/marketplace.json` | Modified | 1 advisory |
| `README.md` | Modified | 1 advisory |
| `skills/README.md` | Modified | 1 advisory |

## Checklist

- [x] No hardcoded credentials or secrets
- [x] Error handling at system boundaries (graceful skips for missing files)
- [x] Input validation (VISION.md gate, >200 char check)
- [ ] Changes match spec requirements (5 cross-document contradictions)
- [x] Follows repository patterns and conventions
- [x] No obvious performance regressions
