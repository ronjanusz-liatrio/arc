# schemas/tests — JSON Schema Test Fixtures

This directory contains PASS and FAIL fixtures for each of the four Arc JSON schemas.
They are used to verify that the schemas accept valid documents and reject invalid ones,
and to provide regression targets for CI and the `validate-*` scripts.

## Naming Convention

```
{schema-name}-pass.json                        # valid document — must validate with exit 0
{schema-name}-{rule-violated}.json             # invalid document — must fail with exit 1
```

The FAIL fixture filename identifies the specific schema rule it violates, so failures
are self-documenting without needing to inspect file contents.

## Fixtures

### backlog-entry

| File | Expected | Rule tested |
|------|----------|-------------|
| `backlog-entry-pass.json` | PASS | Minimal valid `captured` entry |
| `backlog-entry-missing-required-title.json` | FAIL | `title` is a top-level `required` field |
| `backlog-entry-missing-brief.json` | FAIL | `status: shaped` triggers `allOf` requiring `brief` object |

### brief

| File | Expected | Rule tested |
|------|----------|-------------|
| `brief-pass.json` | PASS | Fully populated brief with `open_questions: "None"` |
| `brief-too-few-success-criteria.json` | FAIL | `success_criteria` array requires `minItems: 3` |

### wave

| File | Expected | Rule tested |
|------|----------|-------------|
| `wave-pass.json` | PASS | Planned wave with one idea |
| `wave-missing-completed-timestamp.json` | FAIL | `status: Completed` triggers `allOf` requiring `completed` field |

### roadmap-row

| File | Expected | Rule tested |
|------|----------|-------------|
| `roadmap-row-pass.json` | PASS | Planned row with canonical wave name |
| `roadmap-row-invalid-wave-pattern.json` | FAIL | `wave` must match `^Wave \d+: .+$`; hyphenated form does not |

## Running Fixtures Against Schemas

With [check-jsonschema](https://check-jsonschema.readthedocs.io/) installed:

```bash
# Expect exit 0 (PASS fixtures)
check-jsonschema --schemafile schemas/backlog-entry.schema.json schemas/tests/backlog-entry-pass.json
check-jsonschema --schemafile schemas/brief.schema.json          schemas/tests/brief-pass.json
check-jsonschema --schemafile schemas/wave.schema.json           schemas/tests/wave-pass.json
check-jsonschema --schemafile schemas/roadmap-row.schema.json    schemas/tests/roadmap-row-pass.json

# Expect exit 1 (FAIL fixtures)
check-jsonschema --schemafile schemas/backlog-entry.schema.json schemas/tests/backlog-entry-missing-required-title.json
check-jsonschema --schemafile schemas/backlog-entry.schema.json schemas/tests/backlog-entry-missing-brief.json
check-jsonschema --schemafile schemas/brief.schema.json          schemas/tests/brief-too-few-success-criteria.json
check-jsonschema --schemafile schemas/wave.schema.json           schemas/tests/wave-missing-completed-timestamp.json
check-jsonschema --schemafile schemas/roadmap-row.schema.json    schemas/tests/roadmap-row-invalid-wave-pattern.json
```

Alternatively use `ajv-cli` (see `references/validator-decision.md` for the chosen CLI).

## Adding New Fixtures

1. Name the file `{schema-name}-{rule-violated}.json` (FAIL) or `{schema-name}-pass-{variant}.json` (PASS variant).
2. Add a row to the table above naming the rule violated.
3. Verify manually with `check-jsonschema` before committing.
