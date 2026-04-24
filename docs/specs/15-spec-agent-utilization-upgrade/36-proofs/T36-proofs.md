# T36 Proof Summary

**Task:** FIX-REVIEW: validate-roadmap.sh awk→JSON interpolation breaks on special chars
**Status:** PASS
**Completed:** 2026-04-23

## Fix Applied

Replaced `scripts/validate-roadmap.sh` lines 75-111 (the awk block that directly `printf`-interpolated
wave-table cell values into JSON strings) with a two-stage approach:

1. **Stage 1 (awk):** Extract raw cell values as tab-separated output to a TSV file. No JSON
   construction; just clean field extraction and whitespace trimming.

2. **Stage 2 (bash + jq):** Read each TSV row and invoke `jq -n --arg wave "$wave" --arg goal "$goal"
   --arg status "$status" --arg target "$target" --argjson ideas "$ideas" '{...}'`. The `jq --arg`
   flag handles all JSON string escaping automatically — double-quotes become `\"`, backslashes become
   `\\`, and no other special-character handling is needed.

## Proof Artifacts

| File | Type | Status | Description |
|------|------|--------|-------------|
| T36-01-shellcheck.txt | cli | PASS | ShellCheck clean at --severity=style |
| T36-02-special-chars.txt | cli | PASS | End-to-end run with double-quotes + backslashes in table cells |
| T36-03-json-validity.txt | cli | PASS | Demonstrates old bug (invalid JSON) vs new fix (valid JSON) |

## Key Evidence

- `Wave 1: Ship "Foo"` and `Launch "core" support` (double-quotes) parse to valid JSON: `"wave": "Wave 1: Ship \"Foo\""`
- `Wave 2: Fix \path\issues` (backslashes) parse to valid JSON: `"wave": "Wave 2: Fix \\path\\issues"`
- All 3 schema-validation calls via ajv pass (exit 0)
- ShellCheck reports zero issues at --severity=style
- Existing behavior preserved: exit 0 pass / 1 fail / 2 recoverable, non-interactive, chainable
