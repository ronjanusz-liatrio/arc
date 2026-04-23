# JSON Schema Tooling Decision

## Choice: `ajv-cli`

**Toolchain:** `ajv-cli@5` + `ajv-formats@2`  
**Decision Date:** 2026-04-23  
**Rationale:** Proven in T04.2 (schema authoring phase), supports Draft-07, format validation, and shell integration via `npx`.

## Why `ajv-cli`?

| Criterion | `ajv-cli` | `check-jsonschema` | Winner |
|-----------|-----------|-------------------|--------|
| **Proven in Arc** | ✓ Used & tested in T04.2 | ✗ Not yet tested | ajv-cli |
| **Shell integration** | ✓ CLI with exit codes | ✓ CLI with exit codes | Tie |
| **Installation** | ✓ `npx` (no global install) | ✓ `pip` or `npm` | ajv-cli (npx is simpler) |
| **Footprint** | ✓ npm packages | ~ Python ecosystem | ajv-cli (npm native) |
| **Format validation** | ✓ `ajv-formats` plugin | ✓ Built-in | Both |
| **Draft-07 support** | ✓ Explicit via `--spec=draft7` | ✓ Supported | Both |

**Decision:** Use `ajv-cli@5` + `ajv-formats@2`. It is already proven in T04.2 and provides the lightest shell integration (npx-based installation, no global setup required).

## Canonical Invocation

All validator scripts (`scripts/validate-*.sh`) shall use this pattern:

```bash
npx --yes --package=ajv-cli@5 --package=ajv-formats@2 \
  ajv validate \
    -s schemas/<schema>.schema.json \
    -d <data>.json \
    --spec=draft7 \
    -c ajv-formats
```

### Exit Codes
- `0` — validation passed
- `1` — validation failed
- `2` or higher — fatal error (e.g., schema not found, malformed JSON)

### Usage Pattern
```bash
#!/bin/bash
set -e  # Exit on first error

SCHEMA="schemas/brief.schema.json"
DATA_FILE="$1"

npx --yes --package=ajv-cli@5 --package=ajv-formats@2 \
  ajv validate \
    -s "$SCHEMA" \
    -d "$DATA_FILE" \
    --spec=draft7 \
    -c ajv-formats

# Exit code 0 = valid, 1 = invalid
exit $?
```

## Evidence

See `/home/ron.linux/arc/docs/specs/15-spec-agent-utilization-upgrade/04-proofs/`:
- `T04.2-01-compile.txt` — All 4 schemas compile cleanly under ajv-cli@5 + ajv-formats@2, Draft-07
- `T04.2-02-validate-real.txt` — All 4 schemas validate real Arc artifacts (backlog entries, briefs, waves, roadmap rows)
- `T04.2-proofs.md` — Summary of T04.2 schema authoring proof artifacts

## Downstream Tasks

This decision unblocks:
- T04.3 (#20) — `scripts/validate-backlog.sh`
- T04.4 (#21) — `scripts/validate-brief.sh` + `scripts/validate-roadmap.sh`
- T04.7 (#24) — Proof transcripts for pass/fail validation

All validator scripts must follow the canonical invocation documented above.
