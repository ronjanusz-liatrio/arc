# 01-spec-align-ignore-dirs

## Introduction/Overview

The arc-align hardcoded exclusion list currently only covers JS/generic build directories (`.git/`, `node_modules/`, `vendor/`, `dist/`, `build/`). This leaves common Python, Rust, Java, and modern JS framework directories to be caught by the >100 file heuristic or user-added patterns. This spec adds 12 new directory patterns to the hardcoded list so they are silently excluded without user intervention.

## Goals

- Expand the hardcoded exclusion list to cover Python, Rust, Java, and modern JS framework build/cache directories
- Ensure all 5 locations where the list appears are updated consistently
- Maintain the existing behavior: hardcoded exclusions are silent and never shown in the user-facing multi-select

## User Stories

- As a Python developer running `/arc-align`, I want `.venv/`, `__pycache__/`, and tool caches excluded automatically so I don't have to add them manually every run.
- As a Rust or Java developer, I want `target/` excluded by default so cargo/maven build output doesn't slow the scan.
- As a Next.js developer, I want `.next/` excluded automatically so build artifacts aren't scanned for product-direction content.

## Demoable Units of Work

### Unit 1: Update hardcoded exclusion list in SKILL.md

**Purpose:** Add the 12 new directory patterns to the three locations in `skills/arc-align/SKILL.md` where the hardcoded exclusion list is defined or referenced.

**Functional Requirements:**

- The system shall add the following directory patterns to the hardcoded exclusion table in Step 1a (~line 116):
  - Python: `.venv/`, `__pycache__/`, `.mypy_cache/`, `.pytest_cache/`, `.ruff_cache/`, `.tox/`, `*.egg-info/`
  - Rust/Java: `target/`
  - Java/Kotlin: `.gradle/`
  - JS frameworks: `.next/`, `.nuxt/`
  - Testing: `coverage/`
- The system shall update the inline exclusion references in Step 2c code comment scanning (~line 354) to include the new directories
- The system shall update the inline exclusion reference in the code comment patterns intro (~line 612) to include the new directories
- The system shall update the report template section (~line 1260) to list the new directories in the Hardcoded Exclusions table

**Proof Artifacts:**

- File: `skills/arc-align/SKILL.md` contains all 12 new directory patterns in the Step 1a table
- CLI: `grep -c 'Directory' skills/arc-align/SKILL.md` returns increased count reflecting new rows

### Unit 2: Update hardcoded exclusion list in align-report-template.md

**Purpose:** Keep the report template in sync with the SKILL.md definition.

**Functional Requirements:**

- The system shall add the same 12 directory patterns to the Hardcoded Exclusions table in `skills/arc-align/references/align-report-template.md` (~lines 64-68)
- The directory entries shall use the same `| {pattern} | Directory |` format as existing entries
- The entries shall be grouped by category (existing, Python, Rust/Java, JS frameworks, Testing) for readability

**Proof Artifacts:**

- File: `skills/arc-align/references/align-report-template.md` contains all 12 new directory patterns
- CLI: `diff` between the SKILL.md report section and align-report-template.md shows identical directory lists

## Non-Goals (Out of Scope)

- Adding IDE/editor directories (`.vscode/`, `.idea/`) — these rarely contain enough files to matter and may contain project-relevant config
- Adding `.terraform/`, `.cache/`, or other infra-tool directories — too project-specific for hardcoding
- Changing the >100 file heuristic or the user-facing exclusion flow
- Updating the detection-patterns.md or import-rules.md references (they don't enumerate the full hardcoded list)

## Design Considerations

No specific design requirements identified.

## Repository Standards

- Conventional commits: `fix(arc-align): expand hardcoded exclusion list`
- Markdown tables use `|` alignment consistent with existing style
- No trailing whitespace in table rows

## Technical Considerations

- The hardcoded list appears in **5 locations across 2 files** — all must stay in sync:
  1. `skills/arc-align/SKILL.md` Step 1a table (~line 116)
  2. `skills/arc-align/SKILL.md` Step 2c inline reference (~line 354)
  3. `skills/arc-align/SKILL.md` code comment intro (~line 612)
  4. `skills/arc-align/SKILL.md` report template section (~line 1260)
  5. `skills/arc-align/references/align-report-template.md` (~line 64)
- `*.egg-info/` uses a glob pattern rather than a literal directory name — consistent with existing `*.key` in the secret-bearing category

## Security Considerations

No security implications — this change only affects which directories are skipped during scanning.

## Success Metrics

- All 12 new patterns present in all 5 locations
- No regression in existing exclusion behavior
- Python, Rust, Java, and JS framework projects no longer require manual exclusion of standard tool directories

## Open Questions

No open questions at this time.
