# 04-spec-arc-sync

## Introduction/Overview

`/arc-sync` is a new Arc skill that keeps project README.md and Arc-relevant diagrams in sync with product direction artifacts. It scaffolds a full README for new projects and selectively injects `ARC:` managed sections into existing READMEs as ideas ship and waves progress. A companion WA-7 audit check in `/arc-audit` flags when Arc-managed README sections are stale or structurally incomplete.

The skill uses a **structural trust-signal framework** to validate that Arc-managed sections communicate product direction credibility. Rather than evaluating prose quality, it checks Grep/Read-detectable proxies that prove the content is real, current, and traceable to source artifacts.

## Goals

1. Eliminate README drift by propagating VISION, CUSTOMER, BACKLOG, and ROADMAP data into README managed sections after each wave
2. Scaffold a complete README structure for new projects using Arc artifacts as the content source
3. Keep Arc-relevant mermaid diagrams (idea lifecycle, wave pipeline) updated with live status counts
4. Add WA-7 README trust-signal audit to `/arc-audit` so structurally incomplete or drifted READMEs surface during health checks
5. Maintain clean namespace separation — `/arc-sync` owns `ARC:` sections only, never touches `TEMPER:` or manually-authored content
6. Define and enforce a structural trust-signal framework that validates Arc-managed README sections are real, current, and traceable — not placeholder scaffolding

## User Stories

- As a product owner, I want the README features section to reflect shipped BACKLOG items so that the README stays current without manual editing
- As a developer onboarding to a project, I want the README to show the current wave and roadmap so I understand where the project is headed
- As a product owner running `/arc-audit`, I want to be warned when Arc-managed README sections are stale or structurally incomplete so I can run `/arc-sync` to fix it
- As a project bootstrapper, I want `/arc-sync` to scaffold a complete README from my VISION and CUSTOMER docs so I don't start from a blank file
- As a product owner, I want structural validation that my README communicates trust (real content, not placeholders; current data, not stale snapshots; traceable to source artifacts) without requiring subjective prose review

## Demoable Units of Work

### Unit 1: WA-7 README Trust-Signal Audit

**Purpose:** Add a new audit dimension to `/arc-audit` that validates Arc-managed README sections against a structural trust-signal framework, completing the feedback loop that makes `/arc-sync` discoverable.

**Structural Trust-Signal Framework:**

The following 8 trust signals are Grep/Read-detectable proxies for product direction credibility. They don't prove prose quality — but a README passing all of them genuinely communicates "this project's product direction is managed." A README failing them does not.

| Signal | Trust for the reader | Detectable proxy |
|--------|---------------------|-----------------|
| **TS-1: Overview** | "This project solves a real problem" | `ARC:overview` section has 2+ non-blank content lines AND at least one sentence from VISION.md Problem Statement is present (not placeholder text) |
| **TS-2: Audience** | "They built this for someone specific" | `ARC:audience` section contains at least one persona name that matches a `##` heading in CUSTOMER.md |
| **TS-3: Features** | "This project ships real things" | `ARC:features` section contains a bullet list where 1+ item titles match a `Status: shipped` idea in BACKLOG.md |
| **TS-4: Roadmap** | "There's a delivery plan, not just ideas" | `ARC:roadmap` section contains a table or list with at least one wave name matching a wave section in ROADMAP.md |
| **TS-5: Lifecycle Diagram** | "The pipeline is active, not decorative" | `ARC:lifecycle-diagram` section contains a mermaid code fence AND at least one status count node label is non-zero |
| **TS-6: Currency** | "This data reflects the current state" | Shipped idea count in `ARC:features` matches shipped count in BACKLOG.md (no drift) |
| **TS-7: Traceability** | "This data comes from real artifacts" | At least one `ARC:` managed section contains a `](docs/` link that resolves to an existing file |
| **TS-8: No Placeholders** | "This isn't scaffolding they forgot to fill in" | No `ARC:` managed section contains "TBD", "TODO", "Coming soon", or "Not yet defined" when the corresponding source artifact has substantive content (>200 non-whitespace chars) |

**Functional Requirements:**

- The system shall add a WA-7 check to `skills/arc-audit/references/audit-dimensions.md` following the exact format of WA-1 through WA-6
- The system shall evaluate all 8 trust signals (TS-1 through TS-8) against README.md `ARC:` managed sections
- For each signal, the system shall cross-reference against the source artifact (VISION.md, CUSTOMER.md, BACKLOG.md, ROADMAP.md) to determine pass/fail — signals are only evaluated when their source artifact exists
- TS-8 (No Placeholders) shall only fail when the source artifact has substantive content — placeholder text is acceptable when the corresponding artifact is absent or a stub
- The system shall report a trust-signal scorecard: N of M signals passing (where M is the number of evaluable signals given which artifacts exist)
- The system shall assign severity `warning` when fewer than 75% of evaluable signals pass, `info` when 75%+ pass
- The system shall include WA-7 in the health rating calculation as a warning finding (consistent with WA-2 through WA-5)
- The system shall update `skills/arc-audit/SKILL.md` to include WA-7 in Step 3 (Wave Alignment Audit)
- The system shall recommend "Run `/arc-sync`" as the fix action, listing which signals failed
- The system shall skip WA-7 gracefully if README.md does not exist (report as info: "No README.md found")
- The system shall skip WA-7 gracefully if README.md contains no `ARC:` managed section markers (report as info: "No ARC: sections in README — run `/arc-sync` to scaffold")
- The system shall create `skills/arc-sync/references/trust-signals.md` defining the 8 signals with detection logic, used by both WA-7 and `/arc-sync` post-update validation

**Proof Artifacts:**

- File: `skills/arc-audit/references/audit-dimensions.md` contains WA-7 section with trust-signal framework, detection logic, severity, output format, and interactive fix
- File: `skills/arc-sync/references/trust-signals.md` contains the canonical trust-signal definitions shared by WA-7 and `/arc-sync`
- File: `skills/arc-audit/SKILL.md` references WA-7 in Step 3
- File: `skills/arc-audit/references/review-report-template.md` includes WA-7 trust-signal scorecard in the wave alignment findings table

### Unit 2: `/arc-sync` Scaffold Mode

**Purpose:** Generate a complete README.md from Arc artifacts for projects that don't have one yet, establishing the managed section markers for future selective updates.

**Functional Requirements:**

- The system shall create `skills/arc-sync/SKILL.md` with frontmatter matching Arc's skill conventions (name, description, user-invocable, allowed-tools)
- The system shall require `docs/VISION.md` to exist with substantive content (>200 non-whitespace characters) before running — if absent or stub, warn and exit: "Run `/arc-capture` or create VISION.md first"
- The system shall detect whether `README.md` exists at the project root
- If README.md does not exist, the system shall enter scaffold mode and generate a full README structure with these sections:
  1. Title and one-line description (from VISION.md Vision Summary, first sentence)
  2. `<!--# BEGIN ARC:overview -->` — Problem statement and value proposition (from VISION.md)
  3. `<!--# BEGIN ARC:audience -->` — Target audience and primary personas (from CUSTOMER.md if present, placeholder if not)
  4. `<!--# BEGIN ARC:features -->` — Shipped features list (from BACKLOG.md shipped items, or "No features shipped yet" if none)
  5. `<!--# BEGIN ARC:roadmap -->` — Current wave and upcoming waves (from ROADMAP.md if present, placeholder if not)
  6. `<!--# BEGIN ARC:lifecycle-diagram -->` — Mermaid idea lifecycle state diagram with live status counts
  7. Non-managed sections: Install, Contributing, License — generated as static placeholders for the user to fill in
- The system shall use Liatrio brand colors in mermaid diagrams (matching Arc's existing convention: `primaryColor: '#11B5A4'`, `secondaryColor: '#E8662F'`, `tertiaryColor: '#1B2A3D'`)
- The system shall guarantee that all evaluable trust signals (TS-1 through TS-8) pass on the scaffolded output — scaffold mode must produce content that clears every signal for which the source artifact exists
- The system shall use "Not yet defined" placeholders only when the source artifact is absent — TS-8 permits this
- The system shall include at least one `](docs/` link in a managed section to satisfy TS-7 (Traceability)
- The system shall present the scaffolded README for user approval via AskUserQuestion before writing to disk, including the trust-signal scorecard showing all signals passing
- The system shall create `skills/arc-sync/references/readme-mapping.md` defining the artifact-to-section mapping rules
- The system shall create `skills/arc-sync/references/readme-quality-rules.md` defining quality gates adapted from readme-author (100-200 line target, accessibility basics, progressive disclosure)

**Proof Artifacts:**

- File: `skills/arc-sync/SKILL.md` exists with complete skill definition
- File: `skills/arc-sync/references/readme-mapping.md` exists with artifact-to-section mapping
- File: `skills/arc-sync/references/readme-quality-rules.md` exists with quality gates
- CLI: Running `/arc-sync` on a project with VISION.md but no README.md produces a scaffolded README with all 6 managed section markers
- CLI: Trust-signal scorecard in scaffold output shows all evaluable signals passing

### Unit 3: `/arc-sync` Update Mode

**Purpose:** Selectively update `ARC:` managed sections in an existing README.md, syncing features, roadmap, audience, and diagrams with current Arc artifact state.

**Functional Requirements:**

- If README.md exists and contains at least one `<!--# BEGIN ARC:... -->` marker, the system shall enter update mode
- The system shall read all available Arc artifacts (VISION.md, CUSTOMER.md, BACKLOG.md, ROADMAP.md) and update each managed section:
  - `ARC:overview` — Re-extract problem statement and value proposition from VISION.md
  - `ARC:audience` — Re-extract personas and JTBD from CUSTOMER.md (skip if absent)
  - `ARC:features` — Rebuild shipped features list from BACKLOG.md items with `Status: shipped`
  - `ARC:roadmap` — Rebuild wave summary from ROADMAP.md (active and planned waves)
  - `ARC:lifecycle-diagram` — Regenerate mermaid diagram with current status counts from BACKLOG.md
- The system shall follow the bootstrap-protocol pattern: replace content between BEGIN/END markers, never move marker positions, validate no nesting conflicts
- The system shall never modify content outside `ARC:` managed sections
- The system shall never modify `TEMPER:` or `MM:` managed sections
- The system shall show a diff summary of what changed and ask the user to confirm before writing
- If README.md exists but has no `ARC:` markers, the system shall offer to inject markers at appropriate positions (using the bootstrap-protocol insertion priority algorithm)
- The system shall also update any mermaid diagrams in `docs/` that contain `ARC:` managed diagram markers:
  - `<!--# BEGIN ARC:wave-pipeline-diagram -->` — Pipeline diagram showing current wave ideas and their statuses
  - The system shall scan `docs/` for files containing `ARC:` diagram markers and update them
- The system shall report a summary after update: sections updated, diagrams updated, line count delta
- After writing updates, the system shall run trust-signal validation (TS-1 through TS-8) against the updated README and report the scorecard
- If any trust signal that was passing before the update is now failing (regression), the system shall warn the user with the specific signal and what caused the regression
- If new trust signals became evaluable (e.g., CUSTOMER.md was just created), the system shall report newly passing or newly failing signals

**Proof Artifacts:**

- CLI: Running `/arc-sync` on a project with existing README.md containing `ARC:` markers updates only managed sections
- CLI: Running `/arc-sync` shows diff summary before writing
- CLI: Post-update trust-signal scorecard is displayed after writing
- File: Content outside `ARC:` markers in README.md is unchanged after update
- File: Mermaid diagrams in managed sections reflect current BACKLOG status counts

### Unit 4: Pipeline Integration and Skill Registration

**Purpose:** Wire `/arc-sync` into the Arc pipeline so it's offered after `/arc-wave`, registered in the plugin manifest, and documented in the skill hub.

**Functional Requirements:**

- The system shall update `skills/README.md` to add `/arc-sync` to the skill table and workflow diagram
- The system shall update the workflow diagram to show `/arc-sync` as a step after `/arc-wave`:
  ```
  /arc-assess → /arc-capture → /arc-shape → /arc-wave → /arc-sync → /cw-spec
  ```
- The system shall update `.claude-plugin/marketplace.json` to mention `/arc-sync` in the plugin description
- The system shall update the project `README.md` (Arc's own) to list `/arc-sync` in the Skills section and the Two-Plugin Pipeline diagram
- The system shall add `/arc-sync` as a next-step option in `/arc-wave`'s Step 11 (next steps AskUserQuestion), alongside the existing `/cw-spec` option
- The system shall add "Run `/arc-sync`" as a next-step option in `/arc-audit`'s Step 8 when WA-7 detects staleness
- The system shall bump the plugin version in `.claude-plugin/plugin.json` from `0.4.0` to `0.5.0`

**Proof Artifacts:**

- File: `skills/README.md` lists `/arc-sync` with description and invocation syntax
- File: `.claude-plugin/marketplace.json` description includes `/arc-sync`
- File: `.claude-plugin/plugin.json` version is `0.5.0`
- File: `skills/arc-wave/SKILL.md` offers `/arc-sync` as a next step
- File: `skills/arc-audit/SKILL.md` offers `/arc-sync` when WA-7 triggers
- File: `README.md` (Arc's own) includes `/arc-sync` in skills table and pipeline diagram

## Non-Goals (Out of Scope)

- Temper-managed README sections — Temper handles its own phase-level README concerns
- Creating or modifying LICENSE, CONTRIBUTING.md, or CHANGELOG files
- External link validation or badge generation (readme-author's domain)
- Automatic invocation — `/arc-sync` is always user-triggered or suggested, never auto-executed
- Managing READMEs in subdirectories or monorepo packages
- Full readme-author integration as a runtime dependency — quality rules are adapted as reference docs, not enforced by calling readme-author

## Design Considerations

- Scaffold mode should produce a README that looks complete and professional out of the box — not a skeleton of TODOs
- Managed section content should be concise (features as bullet list, roadmap as table) to keep the README within the 100-200 line target
- Mermaid diagrams should use Liatrio brand colors consistently with existing Arc diagrams
- The idea lifecycle diagram should show status counts as node labels (e.g., `Captured(3)`, `Shipped(7)`) for at-a-glance pipeline health
- Non-managed placeholder sections (Install, Contributing, License) in scaffold mode should contain enough structure to be useful, not just `<!-- TODO -->`
- The trust-signal framework is defined once in `skills/arc-sync/references/trust-signals.md` and consumed by both WA-7 (audit) and `/arc-sync` (post-update validation) — single source of truth for detection logic
- Trust signals validate structure and traceability, never prose quality — a passing signal means "this content is real and current," not "this content is well-written"
- TS-8 (No Placeholders) uses artifact-aware gating: placeholder text is acceptable when the source artifact doesn't exist yet, but becomes a failure when the artifact has real content and the README still shows scaffolding defaults

## Repository Standards

- Skill YAML frontmatter: `name`, `description`, `user-invocable: true`, `allowed-tools` list
- Context marker: `**ARC-README**` at the start of every response
- Managed sections: `<!--# BEGIN ARC:{section-name} -->` / `<!--# END ARC:{section-name} -->`
- Mermaid theme: Liatrio brand colors via `%%{init: {'theme': 'base', 'themeVariables': {...}}}%%`
- References: skill-specific docs in `skills/arc-sync/references/`
- Conventional commits: `feat(arc-sync): ...`

## Technical Considerations

- The bootstrap-protocol insertion algorithm must be extended to handle README.md in addition to CLAUDE.md — same marker format, same nesting validation, but different insertion priority rules (README has no TEMPER/Snyk sections to anchor against)
- For README.md insertion priority: after the last `ARC:` section → before Contributing/License sections → at EOF
- WA-7 trust-signal validation uses artifact cross-referencing (not git dates) — more reliable and doesn't depend on git history
- BACKLOG.md shipped item title matching against README content (TS-3, TS-6) should be case-insensitive substring search, not exact match
- TS-2 persona name matching against CUSTOMER.md should normalize whitespace and casing when comparing
- TS-8 requires reading each source artifact to determine if it has substantive content (>200 non-whitespace chars) before flagging placeholder text as a failure
- Diagram updates in `docs/` require scanning for `ARC:` markers across multiple files — use Glob + Grep, not recursive file reads
- `trust-signals.md` must be structured so both WA-7 (in arc-audit) and `/arc-sync` (post-update) can reference the same detection logic without duplication

## Security Considerations

- `/arc-sync` reads Arc artifacts (VISION, CUSTOMER, BACKLOG, ROADMAP) which may contain sensitive product strategy — the skill only writes to README.md and diagram files, never to external systems
- No API keys, tokens, or credentials are involved
- The skill should not expose internal priority ratings (P0/P1/P2/P3) in the public README — features section shows shipped items without priority metadata

## Success Metrics

- After running `/arc-sync`, all shipped BACKLOG items appear in the README features section
- After running `/arc-wave` followed by `/arc-sync`, the README roadmap section reflects the current wave
- Scaffold mode produces a README that passes all evaluable trust signals on first run
- Update mode changes only managed sections — `git diff` shows no changes outside `ARC:` markers
- Update mode detects and warns on trust-signal regressions (signal that was passing now fails)
- WA-7 correctly reports trust-signal scorecard with no false positives — signals only fail when the source artifact has content that should be reflected
- WA-7 reports `info` severity when 75%+ of evaluable signals pass, `warning` when below 75%

## Open Questions

No open questions at this time.
