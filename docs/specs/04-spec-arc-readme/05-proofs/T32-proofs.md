# T32 Proof Summary

**Task:** FIX-REVIEW #32 — Roadmap table column mismatch across three documents
**Status:** PASS
**Timestamp:** 2026-04-08T15:00:00Z

## Issue

`readme-mapping.md` defined the ARC:roadmap table as `Wave | Status | Goal`, while both `SKILL.md` and `readme-quality-rules.md` used `Wave | Theme | Status`. This column mismatch meant that an implementer following `readme-mapping.md` would produce a structurally different table than what the other two documents specify.

## Fix Applied

Updated `skills/arc-sync/references/readme-mapping.md`:

1. **Extraction step 3**: Changed from extracting "Goal" (first sentence or Wave Goal subsection) to extracting "Theme" (from heading suffix after `—` or from a `Theme:` field)
2. **Output format table**: Changed column order from `Wave | Status | Goal` to `Wave | Theme | Status`
3. **Table row placeholders**: Changed from `{status} | {one-line goal}` to `{theme} | {status}`

## Proof Artifacts

| # | Type | File | Status |
|---|------|------|--------|
| 1 | file | T32-01-file.txt | PASS |
| 2 | file | T32-02-file.txt | PASS |

## Verification

All three documents now use identical column structure `Wave | Theme | Status`:
- `skills/arc-sync/references/readme-mapping.md` line 168
- `skills/arc-sync/SKILL.md` line 272
- `skills/arc-sync/references/readme-quality-rules.md` line 101
