# Code Review Report: agent-utilization-upgrade

**Reviewed:** 2026-04-24
**Branch:** main
**Base:** `75ed55d` (spec-14 ship commit, pre-implementation)
**Commits:** 27 commits, 154 files changed (+11,834 / -100)
**Overall:** **CHANGES REQUESTED**

## Summary

- **Blocking Issues:** 12 (A: 10 correctness, B: 1 security, C: 5 spec compliance)
- **Advisory Notes:** 17
- **Files Reviewed:** 26 implementation files across 3 parallel reviewer batches
- **FIX Tasks Created:** #35, #36, #37, #38, #39, #40, #41 (7 tasks)

Review partitioned into 3 batches and dispatched to parallel reviewer sub-agents. Focus: shell-script correctness + portability, JSON Schema contract alignment, SKILL.md frontmatter vs. body consistency.

## Blocking Issues

### [ISSUE-1] Category A: Script portability regression on macOS bash 3.2 / BSD coreutils
- **Files:** `scripts/state.sh:214,225-234,267-271`; `scripts/validate-backlog.sh:133,153`; `scripts/parse-frontmatter.sh:95`; `scripts/validate-brief.sh:104`
- **Severity:** Blocking
- **Description:** Multiple scripts depend on GNU-only extensions (`find -printf`, `sort -z`, 3-arg `awk match()`) and bash ≥ 4 features (`declare -A`, `mapfile -t`). CLAUDE.md lists macOS as supported; these all fail on stock macOS (bash 3.2, BSD find/sort). `state.sh`'s validation-status parser also only matches exact `PASS|PENDING|FAIL`, missing suffixed verdicts like "PENDING - awaiting review".
- **Fix:** See FIX-35. Replace GNU flags with portable equivalents; drop `declare -A` and `mapfile -t`; make validation-status parser match prefixes.
- **Task:** FIX-REVIEW-35

### [ISSUE-2] Category A: validate-roadmap.sh awk→JSON interpolation breaks on special chars
- **File:** `scripts/validate-roadmap.sh:75-111`
- **Severity:** Blocking
- **Description:** Wave-summary cells are interpolated into JSON strings via awk without escaping. A Goal containing `"`, `\`, or newline yields invalid JSON; downstream `jq` invocations fail silently.
- **Fix:** See FIX-36. Use `jq -n --arg key "$value"` to build rows (handles escaping automatically).
- **Task:** FIX-REVIEW-36

### [ISSUE-3] Category A: validate-brief.sh empty-array detection is unreachable
- **File:** `scripts/validate-brief.sh:160-184`
- **Severity:** Blocking
- **Description:** `printf '%s\n' "" | jq -R . | jq -s .` produces `[""]` (length 1), not `[]`. The `if length == 0` guards never fire, so empty Success Criteria / Constraints / Assumptions silently pass the non-trivial check — false positive PASS on malformed briefs.
- **Fix:** See FIX-37. Filter `. != ""` before length, or guard with `test -z` upstream.
- **Task:** FIX-REVIEW-37

### [ISSUE-4] Category B: parse-frontmatter.sh temp filename collision / path handling
- **File:** `scripts/parse-frontmatter.sh:142`
- **Severity:** Blocking (security/correctness)
- **Description:** Temp filename derived from `basename $(dirname "$file")` without sanitization. Two inputs with the same parent-dir name silently overwrite; special characters flow into path construction.
- **Fix:** See FIX-38. Use `mktemp` or a hash-derived unique suffix with explicit sanitization.
- **Task:** FIX-REVIEW-38

### [ISSUE-5] Category A: backlog-entry.schema.json rejects canonical `open_questions: "None"` form
- **File:** `schemas/backlog-entry.schema.json:72-76`
- **Severity:** Blocking (contract break)
- **Description:** `brief.schema.json` permits `open_questions` as array OR `"None"` literal (per `references/brief-format.md`). Embedded brief in `backlog-entry.schema.json` only permits array. A canonically-formed shaped entry fails validation.
- **Fix:** See FIX-39. Align embedded brief with standalone schema's `oneOf` union.
- **Task:** FIX-REVIEW-39

### [ISSUE-6] Category C: arc-help/SKILL.md missing body ALWAYS directive for ARC-HELP marker
- **File:** `skills/arc-help/SKILL.md`
- **Severity:** Blocking (marker-convention rollout incomplete)
- **Description:** The header "Always begin your response with: **ARC-HELP**" exists but there's no body "CRITICAL CONSTRAINT — **ALWAYS**..." directive. All 8 other arc skills have both. The "ALWAYS" capitalization is the authoritative voice per the Anthropic skill-creator guide.
- **Fix:** See FIX-40. Add a short `## Critical Constraints` section with `- **ALWAYS** begin your response with \`**ARC-HELP**\``.
- **Task:** FIX-REVIEW-40

### [ISSUE-7] Category C: arc-wave/SKILL.md `requires.files` includes VISION.md that body treats as optional
- **File:** `skills/arc-wave/SKILL.md` (frontmatter)
- **Severity:** Blocking
- **Description:** Frontmatter declares `requires.files: [docs/VISION.md]` but body Step 1 treats VISION as optional ("graceful no-op if any absent") and Step 8 auto-creates it. Description says only "Requires at least one shaped idea".
- **Fix:** See FIX-41. Remove VISION.md from requires; move to consumes.from as optional.
- **Task:** FIX-REVIEW-41

### [ISSUE-8] Category C: arc-ship/SKILL.md `requires.files` includes ROADMAP.md that body says is optional
- **File:** `skills/arc-ship/SKILL.md` (frontmatter)
- **Severity:** Blocking
- **Description:** Frontmatter declares `requires.files: [docs/ROADMAP.md]` but body Step 1:104 says "Optional. Read if present" and Step 5a has a `00-uncategorized.md` fallback when absent.
- **Fix:** See FIX-41. Remove ROADMAP.md from requires.
- **Task:** FIX-REVIEW-41

### [ISSUE-9] Category C: arc-capture/SKILL.md description says "no prerequisites" but requires.artifacts includes BACKLOG
- **File:** `skills/arc-capture/SKILL.md` (frontmatter)
- **Severity:** Blocking
- **Description:** Description explicitly states "Prerequisites: none (creates BACKLOG if absent)" but `requires.artifacts: [BACKLOG]`. BACKLOG is produced/initialized by arc-capture, not required.
- **Fix:** See FIX-41. Change `requires.artifacts` to `[]`.
- **Task:** FIX-REVIEW-41

### [ISSUE-10] Category C: arc-wave/SKILL.md consumes non-existent `shaped-brief` artifact
- **File:** `skills/arc-wave/SKILL.md` (frontmatter)
- **Severity:** Blocking
- **Description:** `consumes.from: [{ skill: /arc-shape, artifact: shaped-brief }]` references an artifact that arc-shape does not produce (arc-shape's `produces.artifacts` is `[BACKLOG, shape-report]`). A dispatcher resolving this contract fails.
- **Fix:** See FIX-41. Change artifact to `BACKLOG` (matching how arc-sync consumes it).
- **Task:** FIX-REVIEW-41

## Advisory Notes

### [NOTE-1] Category D: `sort -z` used in parse-frontmatter.sh:95
Breaks macOS. See FIX-35 (grouped).

### [NOTE-2] Category D: 3-arg `awk match()` gawk-only
`validate-backlog.sh:118`, `validate-brief.sh:104`. See FIX-35.

### [NOTE-3] Category D: validate-brief.sh silences jq stderr
Hides real parse errors. Unquote stderr or capture + re-emit on non-zero exit.

### [NOTE-4] Category D: state.sh awk parser drops `##` sections missing `- **Status:**`
Counts under-report when a section is malformed. Emit a warning instead of silently skipping.

### [NOTE-5] Category D: validate-brief.sh title escaping
`awk -v title="$IDEA_TITLE"` unescapes the title; titles with literal backslashes mismatch.

### [NOTE-6] Category D: validate-backlog.sh:265 blank-line test `${line// }` only strips spaces
Doesn't strip tabs. Use `[[ "${line//[[:space:]]}" == "" ]]` for portability.

### [NOTE-7] Category D: state.sh `slugify()` helper is dead code
Logic duplicated inline in awk; remove the helper or delegate to it.

### [NOTE-8] Category D: wave.schema.json allows `completed: "N/A"` on any Completed wave
Only the uncategorized fallback (number=0) should use "N/A". Tighten to `if (number == 0) allow "N/A"`.

### [NOTE-9] Category D: wave.schema.json doesn't require `target`
Description says target is present on all real waves; enforce.

### [NOTE-10] Category D: wave.schema.json `ideas[]` items leave status/priority as free strings
Tighten to enums (matching backlog-entry.schema.json).

### [NOTE-11] Category D: backlog-entry.schema.json embedded brief disallows `title`
`additionalProperties: false` + no title property blocks round-tripping of standalone briefs.

### [NOTE-12] Category D: brief.schema.json requires `wave_assignment` at creation time
Contradicts `references/brief-format.md` which sets it later via `/arc-wave`. Works due to validate-brief.sh default but contract is misaligned.

### [NOTE-13] Category D: arc-assess/SKILL.md `produces.artifacts` missing `align-manifest`
File `align-manifest.md` is in `produces.files` but not artifacts. Add for parity.

### [NOTE-14] Category D: arc-audit/SKILL.md template rename inconsistency
Template now `audit-report.tmpl.md` but output file still `review-report.md`, artifact name still `review-report`. Intentional for backward compat; add inline note.

### [NOTE-15] Category D: arc-wave / arc-ship produce `CLAUDE.md` file without artifact name
Other skills pair file + artifact; these don't. Add artifact name (e.g., `product-context`).

### [NOTE-16] Category D: arc-wave:339 references `WaveTarget` slot in template
Verify the template slot is labeled `WaveTarget` (not `Target`) so the cross-reference resolves.

### [NOTE-17] Category D: schema em-dash vs. colon in wave name
`backlog-entry.schema.json` example uses em-dash; `roadmap-row.schema.json` pattern uses colon. Pick one canonical form (colon, per `references/wave-archive.md`).

## Files Reviewed

| File | Batch | Status | Issues |
|------|-------|--------|--------|
| `scripts/parse-frontmatter.sh` | 1 | Modified | 1 blocking (B), 1 advisory |
| `scripts/state.sh` | 1 | New | 2 blocking (A), 2 advisory |
| `scripts/validate-backlog.sh` | 1 | New | 1 blocking (A), 2 advisory |
| `scripts/validate-brief.sh` | 1 | New | 1 blocking (A), 3 advisory |
| `scripts/validate-roadmap.sh` | 1 | New | 1 blocking (A), 1 advisory |
| `schemas/backlog-entry.schema.json` | 2 | New | 1 blocking (A), 2 advisory |
| `schemas/brief.schema.json` | 2 | New | Clean (1 advisory) |
| `schemas/wave.schema.json` | 2 | New | Clean (3 advisory) |
| `schemas/roadmap-row.schema.json` | 2 | New | Clean |
| `.claude-plugin/plugin.json` | 2 | Modified | Clean |
| `.claude-plugin/marketplace.json` | 2 | Modified | Clean |
| `skills/arc-assess/SKILL.md` | 3 | Modified | Clean (1 advisory) |
| `skills/arc-audit/SKILL.md` | 3 | Modified | Clean (1 advisory) |
| `skills/arc-capture/SKILL.md` | 3 | Modified | 1 blocking (C) |
| `skills/arc-help/SKILL.md` | 3 | Modified | 1 blocking (C) |
| `skills/arc-shape/SKILL.md` | 3 | Modified | Clean |
| `skills/arc-ship/SKILL.md` | 3 | Modified | 1 blocking (C), 1 advisory |
| `skills/arc-status/SKILL.md` | 3 | Modified | Clean |
| `skills/arc-sync/SKILL.md` | 3 | Modified | Clean |
| `skills/arc-wave/SKILL.md` | 3 | Modified | 2 blocking (C), 2 advisory |
| (3 templates, 3 new references, CLAUDE.md, README.md) | inline | Modified/New | Not deep-reviewed; all pre-validated by cw-validate |

## Checklist

- [x] No hardcoded credentials or secrets
- [x] Error handling at system boundaries (scripts exit cleanly on bad input)
- [x] Input validation on user-facing entry points (validators check schema compliance)
- [x] Changes match spec requirements (31/31 spec FRs covered per cw-validate)
- [~] Follows repository patterns and conventions (marker-convention partial; see ISSUE-6)
- [~] No obvious performance regressions (state.sh runs 17-34ms, well under 500ms target)
- [~] Cross-platform compatibility (macOS bash 3.2 broken — ISSUE-1)
- [~] Schema/frontmatter contracts self-consistent (drift in 4 files — ISSUES 5, 7-10)

Legend: [x] pass, [~] partial, [ ] fail

## Recommendation

Dispatch the 7 FIX tasks via `/cw-dispatch`. Most are small (single-file edits). Order considerations:
- FIX-35 (portability) touches 4 scripts; largest.
- FIX-36, FIX-37, FIX-38 are independent script fixes (different files).
- FIX-39 is an isolated schema fix.
- FIX-40 is a 3-line addition to arc-help/SKILL.md.
- FIX-41 touches 3 SKILL.md frontmatters.

Estimated completion: 30-60 minutes for all 7 dispatched in parallel.
