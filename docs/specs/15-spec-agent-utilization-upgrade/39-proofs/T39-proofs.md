# T39 Proof Summary

**Task:** FIX-REVIEW: backlog-entry.schema.json embedded brief.open_questions rejects "None" string
**Status:** COMPLETED
**Date:** 2026-04-23

## Changes Made

1. **`schemas/backlog-entry.schema.json` (lines 72-76):** Changed `open_questions` from a plain array type to a `oneOf` union matching `brief.schema.json` — accepts either an array of strings or the literal string `"None"`.

2. **`schemas/tests/backlog-entry-open-questions-none.json`:** New test fixture for a shaped backlog entry with `brief.open_questions: "None"`.

## Proof Artifacts

| File | Type | Status |
|------|------|--------|
| T39-01-cli.txt | cli | PASS |
| T39-02-cli.txt | cli | PASS |

## Results

- **T39-01-cli.txt:** `backlog-entry-open-questions-none.json` validates successfully against the fixed schema (exit 0).
- **T39-02-cli.txt:** Existing `backlog-entry-pass.json` still validates (no regression).

## Fix Detail

Before:
```json
"open_questions": {
  "type": "array",
  "items": { "type": "string", "minLength": 1 },
  "description": "Unresolved clarifications. Empty or absent means 'None'."
}
```

After:
```json
"open_questions": {
  "oneOf": [
    { "type": "array", "items": { "type": "string", "minLength": 1 } },
    { "type": "string", "enum": ["None"] }
  ],
  "description": "Either an array of question strings or the literal string 'None'. Matches brief.schema.json."
}
```
