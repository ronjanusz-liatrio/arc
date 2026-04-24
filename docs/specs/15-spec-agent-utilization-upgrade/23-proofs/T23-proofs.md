# T23 Proof Summary — schemas/tests/ Fixtures

Task: T04.6: Create schemas/tests/ fixtures (pass + fail per schema)

## Artifacts

| File | Type | Status |
|------|------|--------|
| T23-01-file.txt | file inventory | PASS |
| T23-02-cli.txt | CLI validation run | PASS |

## What Was Verified

1. **9 fixture files** exist under `schemas/tests/` (requirement: >=8).
2. **4 PASS fixtures** (one per schema) exit 0 when validated with `check-jsonschema`.
3. **5 FAIL fixtures** (at least one per schema) exit 1 with diagnostics naming the violated rule.
4. **README.md** documents the naming convention, fixture table, and usage instructions.

## Fixtures Created

### PASS (exit 0)
- `backlog-entry-pass.json` — valid `captured` entry
- `brief-pass.json` — fully populated brief, `open_questions: "None"`
- `wave-pass.json` — Planned wave with one idea
- `roadmap-row-pass.json` — Planned row with canonical `Wave N: Name` format

### FAIL (exit 1)
- `backlog-entry-missing-required-title.json` — top-level `required: title` violated
- `backlog-entry-missing-brief.json` — `allOf` rule: `status=shaped` requires `brief` object
- `brief-too-few-success-criteria.json` — `success_criteria` has 2 items, minItems is 3
- `wave-missing-completed-timestamp.json` — `allOf` rule: `status=Completed` requires `completed`
- `roadmap-row-invalid-wave-pattern.json` — `wave` field does not match `^Wave \d+: .+$`

## Validation Tool

`check-jsonschema` (Draft-07 compliant, consistent with T04.1 decision).
