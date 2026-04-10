# Code Review Report

**Reviewed**: 2026-04-08T21:00:00Z
**Branch**: main
**Base**: 5947e69
**Commits**: 10 commits, 7 implementation files
**Overall**: CHANGES REQUESTED

## Summary

- **Blocking Issues**: 5 (A: 3 correctness, B: 0 security, C: 2 spec compliance)
- **Advisory Notes**: 5
- **Files Reviewed**: 7 / 7 changed files (excluding proof artifacts)
- **FIX Tasks Created**: #17, #18, #19, #20, #21

## Blocking Issues

### [ISSUE-1] [A] Bash not in allowed-tools — file deletion will fail
- **File**: `skills/arc-assess/SKILL.md:5,613`
- **Severity**: Blocking
- **Description**: Step 6a instructs `rm {file_path}` via Bash, but frontmatter declares `allowed-tools: Glob, Grep, Read, Write, Edit, AskUserQuestion` — Bash is absent. Claude Code will refuse the tool call at runtime.
- **Fix**: Add `Bash` to the allowed-tools frontmatter list.
- **Task**: FIX-REVIEW #17

### [ISSUE-2] [C] docs/align-report.md missing from hardcoded exclusion list
- **File**: `skills/arc-assess/SKILL.md:42-43`, `skills/arc-assess/references/align-report-template.md:60-78`
- **Severity**: Blocking
- **Description**: The generated report contains keywords (roadmap, backlog, vision, persona) that will trigger false-positive discoveries on re-runs. Both SKILL.md and the report template omit it from the Arc-managed file exclusion list.
- **Fix**: Add `docs/align-report.md` to the Arc-managed files row in both locations.
- **Task**: FIX-REVIEW #18

### [ISSUE-3] [A] Keyword scan restricted to *.md — misses text files
- **File**: `skills/arc-assess/SKILL.md:159-160`
- **Severity**: Blocking
- **Description**: The Grep call uses `glob: "*.md"`, excluding .txt, .rst, .adoc files. The spec non-goals say "only text/markdown files are scanned" — implying non-markdown text files should be covered. TODO.txt, ROADMAP.rst would be missed.
- **Fix**: Change glob to `"*.{md,txt,rst,adoc}"` in both keyword (Step 2a) and structural (Step 2b) scans.
- **Task**: FIX-REVIEW #19

### [ISSUE-4] [C] ST-1 task list discovery granularity — block vs item
- **File**: `skills/arc-assess/SKILL.md:194-198`
- **Severity**: Blocking
- **Description**: ST-1 records "the full block of consecutive task items as one discovery." This means a 5-item task list becomes 1 BACKLOG stub. The user's requirement was "be as inclusive as possible" — item-level granularity (1 stub per checkbox) captures more individual ideas.
- **Fix**: Change ST-1 to record each task list item as a separate discovery. Update detection-patterns.md to match.
- **Task**: FIX-REVIEW #20

### [ISSUE-5] [A] "Remaining unmanaged" report section has no population mechanism
- **File**: `skills/arc-assess/SKILL.md:706,812-834,895`
- **Severity**: Blocking
- **Description**: The report template and inline summary reference "remaining unmanaged content" and "items left behind (below threshold)," but the process flow never filters items into this bucket. The inclusivity principle imports everything. Only user rejections (Step 3 individual review) produce non-imported items, but those are labeled "user-rejected" — a separate concept.
- **Fix**: Merge "user-rejected" and "remaining unmanaged" into a single concept. Clarify that items in this section are those the user explicitly rejected during individual review.
- **Task**: FIX-REVIEW #21

## Advisory Notes

### [NOTE-1] [D] Step 10 "Run again" creates session-state ambiguity
- **File**: `skills/arc-assess/SKILL.md:936`
- **Description**: "Loop back to Step 1" doesn't clarify whether session state resets. Sibling skills use "Inform the user to run `/arc-X`" for clarity.
- **Suggestion**: Change to "Inform the user to run `/arc-assess` again" for consistency.

### [NOTE-2] [D] Step 1c multiSelect defaults not specified
- **File**: `skills/arc-assess/SKILL.md:57-70`
- **Description**: The multi-select for exclusion recommendations doesn't specify pre-selected defaults. Spec says "smart defaults pre-checked."
- **Suggestion**: Add a note that all recommended exclusions should be pre-selected by default.

### [NOTE-3] [D] Step 5a-v summary table insertion order not explicit
- **File**: `skills/arc-assess/SKILL.md:510`
- **Description**: Row insertion assumes stubs from Step 5a-iv already exist. Execution order (all stubs first, then all rows) should be explicit.
- **Suggestion**: Add a sequencing note: "After all stubs are appended (5a-iv), add all summary table rows in a single Edit operation."

### [NOTE-4] [D] KW-1 purpose mentions ROADMAP as a consolidation target
- **File**: `skills/arc-assess/references/detection-patterns.md:28`
- **Description**: "should be consolidated into BACKLOG or ROADMAP" — but ROADMAP is not one of the three import targets (BACKLOG, VISION, CUSTOMER).
- **Suggestion**: Change to "should be consolidated into BACKLOG."

### [NOTE-5] [D] Duplicate "Cross-References" sections in align-report-template.md
- **File**: `skills/arc-assess/references/align-report-template.md:117-124,222-228`
- **Description**: Two sections titled "Cross-References" — one inside the template (for the generated report) and one outside (meta-references for the template doc). Confusing.
- **Suggestion**: Rename the outer one to "Template Cross-References."

## Files Reviewed

| File | Status | Issues |
|------|--------|--------|
| `skills/arc-assess/SKILL.md` | New (948 lines) | 5 blocking, 4 advisory |
| `skills/arc-assess/references/detection-patterns.md` | New (513 lines) | 1 advisory |
| `skills/arc-assess/references/import-rules.md` | New (312 lines) | Clean |
| `skills/arc-assess/references/align-report-template.md` | New (228 lines) | 1 blocking, 1 advisory |
| `.claude-plugin/plugin.json` | Modified | Clean |
| `README.md` | Modified | Clean |
| `skills/README.md` | Modified | Clean |

## Checklist

- [x] No hardcoded credentials or secrets
- [x] Error handling at system boundaries (graceful no-ops for absent files)
- [x] Input validation (exclusion confirmation, import confirmation)
- [x] Changes match spec requirements (with noted exceptions above)
- [x] Follows repository patterns and conventions (frontmatter, step numbering, AskUserQuestion)
- [x] No obvious performance regressions (keyword-first ordering, exclusion pre-scan)
