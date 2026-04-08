# 02-spec-arc-plugin-enhancement

## Introduction/Overview

Arc v0.2.0 delivered three skills, four templates, and three reference docs — all 7 demoable units from spec 01 are implemented. This enhancement iteration hardens quality by adding error-path Gherkin scenarios for all three existing skills, and extends the plugin with a new `/arc-review` skill that audits backlog health and wave alignment across all product artifacts, offering interactive fixes for issues found.

## Goals

1. **Error-path coverage** — Add negative and edge-case Gherkin scenarios for `/arc-capture`, `/arc-shape`, and `/arc-wave` to cover missing files, empty inputs, validation failures, and graceful degradation paths
2. **Pipeline audit skill** — Deliver `/arc-review` for full pipeline health checks: stale ideas, priority imbalances, broken cross-references, wave coherence, and VISION/CUSTOMER alignment
3. **Interactive remediation** — `/arc-review` produces a diagnostic report and offers to fix identified issues interactively, not just flag them
4. **Plugin continuity** — Bump version to 0.3.0, update skill directory and README to reflect the new skill

## User Stories

- As a **product owner**, I want to audit my backlog health so that I can identify stale ideas, priority imbalances, and gaps before planning the next wave
- As a **tech lead**, I want to verify cross-reference integrity between BACKLOG, ROADMAP, VISION, and CUSTOMER so that broken links don't silently degrade product context
- As a **developer**, I want error-path scenarios documented so that skill behavior under edge cases is explicit and testable
- As a **product owner**, I want to fix identified issues interactively during the review so that audit findings become immediate action, not a separate task

## Demoable Units of Work

### Unit 1: Error-Path Gherkin Scenarios

**Purpose:** Extend the existing 48 Gherkin scenarios with negative and edge-case scenarios for all three skills, covering the error handling patterns already defined in SKILL.md files but not yet captured in `.feature` files.

**Functional Requirements:**
- The system shall add error-path scenarios to `arc-capture-skill.feature` covering: capture with empty title input, capture with empty summary, BACKLOG.md write failure recovery, and duplicate idea title handling
- The system shall add error-path scenarios to `arc-shape-skill.feature` covering: shaping when no captured ideas exist in BACKLOG, shaping with argument that matches no idea, brief validation failure (multiple criteria fail), subagent returning incomplete analysis, and backward transition from shaped to captured when critical gaps are unresolvable
- The system shall add error-path scenarios to `arc-wave-skill.feature` covering: wave planning when no shaped ideas exist, wave planning when BACKLOG.md is absent, wave with zero ideas selected, wave scope exceeding phase recommendation (user override flow), CLAUDE.md absent (warn and skip injection), and ARC: section insertion when it would nest inside a TEMPER: block
- All new scenarios shall follow the existing Gherkin conventions: source comment, pattern annotation, recommended test type, and Given/When/Then structure consistent with existing scenarios
- New scenarios shall be appended to existing `.feature` files (not separate files) to maintain feature-level cohesion

**Proof Artifacts:**
- File: `docs/specs/01-spec-arc-plugin/arc-capture-skill.feature` contains scenarios with "error" or "absent" or "empty" in their names
- File: `docs/specs/01-spec-arc-plugin/arc-shape-skill.feature` contains scenarios covering "no captured ideas" and "validation failure"
- File: `docs/specs/01-spec-arc-plugin/arc-wave-skill.feature` contains scenarios covering "BACKLOG.md is absent" and "CLAUDE.md absent"

### Unit 2: `/arc-review` Skill

**Purpose:** Provide a pipeline health audit skill that reads all product artifacts, identifies issues across two dimensions (backlog health and wave alignment), generates a diagnostic report, and offers interactive fixes.

**Functional Requirements:**
- The system shall provide `skills/arc-review/SKILL.md` with frontmatter (`name: arc-review`, `description`, `user-invocable: true`, `allowed-tools: [Glob, Grep, Read, Write, Edit, AskUserQuestion]`) following the same SKILL.md conventions as the existing three skills
- The skill shall begin every response with the context marker `**ARC-REVIEW**`
- The skill shall read `docs/BACKLOG.md`, `docs/ROADMAP.md`, `docs/VISION.md`, `docs/CUSTOMER.md`, and `docs/management-report.md` (all optional except BACKLOG.md — if BACKLOG.md is absent, report "No backlog found" and exit gracefully)
- The skill shall perform **backlog health** checks:
  - **Stale ideas**: Ideas with status `captured` that have no `Shaped` timestamp and were captured more than 14 days ago (configurable threshold via AskUserQuestion if the user wants to adjust)
  - **Priority imbalance**: More than 50% of non-shipped ideas at a single priority level, or zero ideas at P2-Medium or P3-Low (suggests everything is urgent)
  - **Status distribution**: Count of ideas per status (captured, shaped, spec-ready, shipped) with warnings if pipeline is bottlenecked (e.g., many shaped but zero spec-ready)
  - **Missing brief fields**: Shaped ideas missing any of the 7 required brief sections (Problem, Proposed Solution, Success Criteria, Constraints, Assumptions, Wave Assignment, Open Questions)
  - **Invalid status values**: Ideas with status values not in the allowed set
- The skill shall perform **wave alignment** checks:
  - **Broken ROADMAP references**: Wave entries in ROADMAP.md that reference BACKLOG ideas by anchor, where the anchor does not exist in BACKLOG.md
  - **Status mismatch**: Ideas referenced in a ROADMAP wave that are not `spec-ready` or `shipped`
  - **Orphaned spec-ready ideas**: Ideas with status `spec-ready` that are not assigned to any ROADMAP wave
  - **VISION alignment**: Check that VISION.md exists and is not a stub (has content beyond the auto-created note)
  - **CUSTOMER alignment**: Check that CUSTOMER.md exists with at least one named persona; warn if shaped ideas reference personas not found in CUSTOMER.md
  - **Cross-reference integrity**: Verify that BACKLOG summary table rows match the `## {Title}` sections below (no orphaned rows, no orphaned sections)
- The skill shall generate `docs/review-report.md` with: timestamp, overall health rating (Healthy / Needs Attention / Critical), per-dimension findings with severity (info / warning / critical), and recommended actions
- The skill shall present findings summary via AskUserQuestion and offer to fix issues interactively:
  - Mark stale captured ideas with a `<!-- stale: reviewed {date} -->` comment to suppress future warnings
  - Update BACKLOG summary table to match section headings (fix orphaned rows/sections)
  - Flag missing brief fields with `<!-- TODO: fill {field} -->` markers in the idea section
  - Remove broken ROADMAP wave references with user confirmation
- The skill shall never modify VISION.md or CUSTOMER.md content — only report on their state
- The skill shall offer next steps: run review again after fixes, proceed to `/arc-capture` or `/arc-wave`, or done
- The skill shall provide reference docs: `skills/arc-review/references/audit-dimensions.md` (health check definitions, thresholds, severity levels) and `skills/arc-review/references/review-report-template.md` (report format and sections)

**Proof Artifacts:**
- File: `skills/arc-review/SKILL.md` contains frontmatter with `name: arc-review` and `user-invocable: true`
- File: `skills/arc-review/references/audit-dimensions.md` contains backlog health and wave alignment check definitions
- File: `skills/arc-review/references/review-report-template.md` contains report format
- CLI: Invoking `/arc-review` with a BACKLOG.md containing stale and misaligned ideas produces a review report
- File: After review, `docs/review-report.md` contains health rating, findings, and recommended actions
- File: After interactive fixes, `docs/BACKLOG.md` contains `<!-- stale: reviewed -->` or `<!-- TODO: fill -->` markers on affected ideas

### Unit 3: Plugin Metadata and Documentation Update

**Purpose:** Bump plugin version to 0.3.0 and update all metadata, skill directory, and README to reflect the addition of `/arc-review`.

**Functional Requirements:**
- The system shall update `.claude-plugin/plugin.json` version to `0.3.0`
- The system shall update `.claude-plugin/marketplace.json` version to `0.3.0`
- The system shall update `skills/README.md` to include `/arc-review` with a one-line description, invocation syntax, and link to SKILL.md
- The system shall update `README.md` to add `/arc-review` to the Skills section, the Two-Plugin Pipeline description (where relevant), and the Plugin Structure file tree
- The system shall ensure no internal links are broken after the update

**Proof Artifacts:**
- File: `.claude-plugin/plugin.json` contains `"version": "0.3.0"`
- File: `.claude-plugin/marketplace.json` contains `"version": "0.3.0"`
- File: `skills/README.md` contains a link to `arc-review/SKILL.md`
- Grep: `README.md` contains `/arc-review`
- File: `README.md` Plugin Structure section includes `arc-review/` directory

## Non-Goals (Out of Scope)

- **CI/CD pipeline** — No GitHub Actions or automation in this iteration
- **Proof execution for spec 01 units 3-7** — Proofs of the original spec are tracked separately
- **Automated fix application** — `/arc-review` offers interactive fixes with user confirmation, not batch auto-fixes
- **VISION or CUSTOMER content editing** — Review reports on their state but never modifies their content
- **New templates or reference docs** — No changes to existing templates/ or references/ beyond what `/arc-review` needs
- **Backward-incompatible changes** — All existing skills, templates, and references remain unchanged

## Design Considerations

- `/arc-review` follows the same SKILL.md conventions as the existing three skills: YAML frontmatter, context marker, critical constraints, numbered process steps, references section
- The review report uses the same markdown formatting patterns as `shape-report.md` and `wave-report.md` (timestamp header, structured sections, actionable findings)
- Interactive fix offers use AskUserQuestion with multi-select (user picks which fixes to apply) and descriptions explaining what each fix does
- Health rating thresholds (Healthy / Needs Attention / Critical) are defined in `audit-dimensions.md` to keep them configurable without changing SKILL.md
- Error-path Gherkin scenarios follow the exact formatting conventions of existing `.feature` files (source comment, pattern, Given/When/Then)

## Repository Standards

- **Commit convention:** `type(scope): description` — types: feat, fix, docs, chore; scopes: skills, plugin, docs
- **Plugin conventions:** Follow existing SKILL.md frontmatter format, template YAML format, and reference doc structure
- **File naming:** Lowercase with hyphens; skill in `skills/arc-review/`
- **Version:** Semantic versioning; 0.2.0 -> 0.3.0 (minor bump for new skill)

## Technical Considerations

- **Stateless audit:** `/arc-review` reads all artifacts fresh on each invocation — no cached state between runs
- **Timestamp parsing:** Stale idea detection requires parsing ISO 8601 timestamps from BACKLOG.md `Captured:` fields. The 14-day default threshold is adjustable via AskUserQuestion at the start of each review
- **Anchor matching:** Cross-reference validation between ROADMAP wave entries and BACKLOG section headings uses the same anchor generation rules as `/arc-wave` (lowercase, hyphens, strip special characters)
- **Summary table sync:** The BACKLOG summary table and `## {Title}` sections can drift if manual edits occur. `/arc-review` detects and offers to reconcile mismatches
- **Non-destructive fixes:** All interactive fixes add markers or reconcile existing content — no content deletion without explicit user confirmation

## Security Considerations

- No API keys, tokens, or secrets involved — pure markdown plugin
- No external network calls — all operations are local file reads and writes
- Interactive fixes require user confirmation via AskUserQuestion before any file modification

## Success Metrics

- All three existing `.feature` files gain error-path scenarios covering the edge cases defined in each SKILL.md
- `/arc-review` detects stale ideas, priority imbalances, broken cross-references, and missing brief fields in a test BACKLOG
- `docs/review-report.md` includes health rating, per-dimension findings, and recommended actions
- Interactive fixes correctly add markers and reconcile summary table mismatches
- Plugin version is 0.3.0 with `/arc-review` in README and skill directory

## Open Questions

No open questions at this time.
