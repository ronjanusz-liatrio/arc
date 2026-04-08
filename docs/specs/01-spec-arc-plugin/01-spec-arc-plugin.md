# 01-spec-arc-plugin

## Introduction/Overview

Arc is a Claude Code plugin that manages the idea lifecycle from raw thought to spec-ready brief. It provides three skills (`/arc-capture`, `/arc-shape`, `/arc-wave`) and four product artifact templates (VISION, CUSTOMER, ROADMAP, BACKLOG) as markdown files tracked in the repository. Arc is the upstream companion to Temper — it shapes what gets built before Temper governs how it gets built, feeding spec-ready briefs directly into the claude-workflow SDD pipeline.

## Goals

1. **Fast idea capture** — Record a raw idea in under 30 seconds with `/arc-capture` (title, one-liner, priority → BACKLOG entry)
2. **Structured shaping** — Refine captured ideas into spec-ready briefs via `/arc-shape` using parallel subagent analysis across four dimensions
3. **Delivery cycle management** — Group spec-ready ideas into waves with `/arc-wave`, updating ROADMAP and injecting ARC: managed sections into project CLAUDE.md
4. **Temper integration** — Read Temper's management report when present to inform wave planning scope based on project phase and gate results
5. **Pipeline continuity** — Produce spec-ready briefs in a stable format consumable by `/cw-spec`, completing the arc → claude-workflow → temper pipeline

## User Stories

- As a **product owner**, I want to capture ideas quickly so that I don't lose thoughts while context-switching
- As a **product owner**, I want to refine ideas interactively so that briefs entering the SDD pipeline have clear problem framing, success criteria, and scope boundaries
- As a **tech lead**, I want to organize spec-ready ideas into delivery waves so that engineering work is sequenced and scoped appropriately
- As a **developer**, I want product direction tracked as markdown in the repo so that I can read vision, customer, and roadmap context without leaving the terminal
- As a **project stakeholder**, I want the idea pipeline to respect Temper phase constraints so that we don't plan work the project can't absorb

## Demoable Units of Work

### Unit 1: Reference Documents

**Purpose:** Establish the foundational reference documentation that all three skills and templates depend on — the idea lifecycle model, the spec-ready brief format, and wave planning guidance.

**Functional Requirements:**
- The system shall provide `references/idea-lifecycle.md` defining the four-stage progression: Capture → Shape → Spec-Ready → Shipped, with transition rules and backward transitions (Shape → Capture for "needs context", Spec-Ready → Shape for "scope change")
- The system shall provide `references/brief-format.md` specifying the exact structure of a spec-ready brief (Problem, Proposed Solution, Success Criteria, Constraints, Assumptions, Wave Assignment, Open Questions) with field descriptions and examples
- The system shall provide `references/wave-planning.md` describing wave organization principles: capacity constraints, precedence rules, theme grouping, and Temper phase compatibility
- The system shall provide `references/README.md` as a directory hub listing all reference docs with one-line descriptions

**Proof Artifacts:**
- File: `references/idea-lifecycle.md` contains all four stages with transition rules
- File: `references/brief-format.md` contains the spec-ready brief template with field descriptions
- File: `references/wave-planning.md` contains wave planning guidance
- File: `references/README.md` contains links to all three reference docs

### Unit 2: Product Artifact Templates

**Purpose:** Provide phase-graduated templates for the four product artifacts (VISION, CUSTOMER, ROADMAP, BACKLOG) that skills create and manage. Templates are adapted from Temper's recovered originals (commit `4227536`) and follow Temper's template conventions.

**Functional Requirements:**
- The system shall provide `templates/VISION.tmpl.md` with YAML frontmatter (`role: always-required`, `artifact: VISION`, `output_path: docs/VISION.md`) and phase-graduated sections from Spike through Maturity, with required sections and content guidance per phase
- The system shall provide `templates/CUSTOMER.tmpl.md` with YAML frontmatter (`role: always-required`, `artifact: CUSTOMER`, `output_path: docs/CUSTOMER.md`) and phase-graduated sections including persona definitions and JTBD statements
- The system shall provide `templates/ROADMAP.tmpl.md` with YAML frontmatter (`role: product-leadership`, `artifact: ROADMAP`, `output_path: docs/ROADMAP.md`) and phase-graduated sections including wave definitions and Mermaid dependency graphs using Liatrio brand colors
- The system shall provide `templates/BACKLOG.tmpl.md` with YAML frontmatter (`role: product-leadership`, `artifact: BACKLOG`, `output_path: docs/BACKLOG.md`) and phase-graduated sections including the inline section format: summary table header followed by `## {Title}` sections for each idea, where captured ideas are stubs and shaped ideas include full brief subsections
- All templates shall follow Temper's template conventions: YAML frontmatter, phase-graduated content (Spike → PoC → Vertical Slice → Foundation → MVP → Growth → Maturity), required sections per phase, content guidance, and cross-references to related artifacts
- All Mermaid diagrams in templates shall use Liatrio brand colors (primary: `#11B5A4`, secondary: `#E8662F`, tertiary: `#1B2A3D`)

**Proof Artifacts:**
- File: `templates/VISION.tmpl.md` contains frontmatter with `role: always-required` and phase-graduated sections
- File: `templates/CUSTOMER.tmpl.md` contains frontmatter with `role: always-required` and JTBD format
- File: `templates/ROADMAP.tmpl.md` contains frontmatter with `role: product-leadership` and Mermaid diagrams with Liatrio colors
- File: `templates/BACKLOG.tmpl.md` contains frontmatter with `role: product-leadership` and inline section format spec

### Unit 3: `/arc-capture` Skill

**Purpose:** Provide fast idea entry that appends a structured stub to BACKLOG.md with minimal friction — title, one-line summary, and rough priority in under 30 seconds.

**Functional Requirements:**
- The system shall provide `skills/arc-capture/SKILL.md` with frontmatter (`name: arc-capture`, `description`, `user-invocable: true`, `allowed-tools`) following Temper's SKILL.md conventions
- The skill shall begin every response with the context marker `**ARC-CAPTURE**`
- The skill shall use AskUserQuestion to gather: idea title (freeform), one-line summary (freeform), and priority (single-select: P0-Critical, P1-High, P2-Medium, P3-Low)
- The skill shall check for an existing `docs/BACKLOG.md` file; if absent, create it from `templates/BACKLOG.tmpl.md` at the appropriate phase level (default: Foundation stub)
- The skill shall append a new `## {Title}` section to BACKLOG.md with status `captured`, the provided priority, one-line summary, and a timestamp
- The skill shall update the summary table at the top of BACKLOG.md with the new entry
- The skill shall confirm the capture with a brief inline summary (no separate report file)
- The skill shall offer next steps: capture another idea, shape this idea (`/arc-shape`), or done

**Proof Artifacts:**
- File: `skills/arc-capture/SKILL.md` contains frontmatter with `name: arc-capture` and `user-invocable: true`
- CLI: Invoking `/arc-capture` produces an AskUserQuestion prompt for title, summary, and priority
- File: After capture, `docs/BACKLOG.md` contains a new `## {Title}` section with `status: captured`

### Unit 4: `/arc-shape` Skill

**Purpose:** Interactively refine a captured idea into a spec-ready brief using parallel subagent analysis across four dimensions: problem clarity, customer fit, scope boundaries, and feasibility.

**Functional Requirements:**
- The system shall provide `skills/arc-shape/SKILL.md` with frontmatter (`name: arc-shape`, `description`, `user-invocable: true`, `allowed-tools`) following Temper's SKILL.md conventions
- The skill shall begin every response with the context marker `**ARC-SHAPE**`
- The skill shall read `docs/BACKLOG.md` and present all ideas with status `captured` for selection via AskUserQuestion (single-select with title and summary as description)
- The skill shall accept an optional argument to specify an idea by title, bypassing the selection step
- The skill shall launch four parallel subagents to analyze the selected idea:
  - **Problem clarity** — Is the problem statement specific enough? Who is affected? What is the impact?
  - **Customer fit** — Does this align with personas in `docs/CUSTOMER.md`? Which JTBD does it serve?
  - **Scope boundaries** — Are constraints and non-goals explicit? What is intentionally excluded?
  - **Feasibility** — Given the current project context (Temper phase if available), can engineering absorb this?
- The skill shall aggregate subagent results and present a synthesis to the user, highlighting gaps and recommendations
- The skill shall guide the user through an interactive Q&A to fill identified gaps, using AskUserQuestion with concrete options where possible
- The skill shall generate the shaped brief in the spec-ready format (Problem, Proposed Solution, Success Criteria, Constraints, Assumptions, Wave Assignment, Open Questions) as defined in `references/brief-format.md`
- The skill shall update the idea's section in `docs/BACKLOG.md`: change status from `captured` to `shaped`, replace the stub content with the full brief subsections
- The skill shall save a shaping report to `docs/shape-report.md` with timestamp, before/after comparison, and subagent dimension summaries
- The skill shall provide reference docs for subagent prompts: `skills/arc-shape/references/shaping-dimensions.md` (dimension definitions and analysis prompts) and `skills/arc-shape/references/brief-validation.md` (readiness criteria for spec-ready status)
- The skill shall offer next steps: shape another idea, approve as spec-ready, plan a wave (`/arc-wave`), or done

**Proof Artifacts:**
- File: `skills/arc-shape/SKILL.md` contains frontmatter with `name: arc-shape` and `user-invocable: true`
- File: `skills/arc-shape/references/shaping-dimensions.md` contains four dimension definitions
- File: `skills/arc-shape/references/brief-validation.md` contains readiness criteria
- CLI: Invoking `/arc-shape` presents captured ideas for selection and launches parallel subagent analysis
- File: After shaping, `docs/BACKLOG.md` contains the idea with `status: shaped` and full brief subsections
- File: `docs/shape-report.md` contains timestamped shaping report

### Unit 5: `/arc-wave` Skill

**Purpose:** Group spec-ready ideas into a delivery cycle, update the ROADMAP, inject ARC: managed sections into the project CLAUDE.md, and prepare the handoff to Temper and claude-workflow.

**Functional Requirements:**
- The system shall provide `skills/arc-wave/SKILL.md` with frontmatter (`name: arc-wave`, `description`, `user-invocable: true`, `allowed-tools`) following Temper's SKILL.md conventions
- The skill shall begin every response with the context marker `**ARC-WAVE**`
- The skill shall read `docs/BACKLOG.md` and present all ideas with status `shaped` (spec-ready) for wave inclusion via AskUserQuestion (multi-select with title, priority, and brief summary as description)
- The skill shall read `docs/management-report.md` if present (Temper feedback loop) and use project phase and gate results to constrain wave scope:
  - Spike/PoC phases → recommend small waves (1-2 ideas), warn about overscoping
  - Foundation+ phases → allow larger waves (3-5 ideas)
  - Hard gate failures → recommend including stabilization work in the wave
  - If management report is absent, proceed without constraints (graceful no-op)
- The skill shall use AskUserQuestion to gather: wave name/theme, target timeframe, and any dependencies or blockers
- The skill shall check for existing `docs/ROADMAP.md`; if absent, create from `templates/ROADMAP.tmpl.md` at the appropriate phase level
- The skill shall append the new wave to `docs/ROADMAP.md` with: wave name, goal, selected ideas (with links to BACKLOG sections), target timeframe, dependencies, and status
- The skill shall update selected ideas in `docs/BACKLOG.md`: change status from `shaped` to `spec-ready` with wave assignment
- The skill shall inject or update `ARC:product-context` managed section in the project CLAUDE.md using HTML comment markers (`<!--# BEGIN ARC:product-context -->` / `<!--# END ARC:product-context -->`), following Temper's bootstrap-protocol coexistence rules:
  - Never modify TEMPER: or MM: sections
  - Never nest markers across namespaces
  - Insert after last TEMPER: section (or before Snyk block, or at EOF)
  - Content: vision summary, current wave name, primary personas, backlog status counts
- The skill shall check for `docs/VISION.md` and `docs/CUSTOMER.md`; if absent, create from templates at stub level with a note to fill in
- The skill shall save a wave report to `docs/wave-report.md` with: wave plan, selected ideas, Temper context (if read), and handoff instructions for `/cw-spec`
- The skill shall provide reference docs: `skills/arc-wave/references/wave-report-template.md` (report format) and `skills/arc-wave/references/bootstrap-protocol.md` (ARC: namespace injection rules)
- The skill shall offer next steps: hand off to `/cw-spec` (with the spec-ready brief as input), plan another wave, or done

**Proof Artifacts:**
- File: `skills/arc-wave/SKILL.md` contains frontmatter with `name: arc-wave` and `user-invocable: true`
- File: `skills/arc-wave/references/wave-report-template.md` contains wave report format
- File: `skills/arc-wave/references/bootstrap-protocol.md` contains ARC: namespace injection rules
- CLI: Invoking `/arc-wave` presents shaped ideas for multi-select wave inclusion
- File: After wave creation, `docs/ROADMAP.md` contains the new wave with selected ideas
- File: After wave creation, `docs/BACKLOG.md` shows selected ideas with `status: spec-ready`
- Grep: Project CLAUDE.md contains `<!--# BEGIN ARC:product-context -->` managed section
- File: `docs/wave-report.md` contains timestamped wave report with handoff instructions

### Unit 6: Plugin Metadata and Skill Directory

**Purpose:** Update plugin metadata to reflect implemented skills and provide a skill directory hub.

**Functional Requirements:**
- The system shall update `.claude-plugin/plugin.json` version to `0.2.0`
- The system shall update `.claude-plugin/marketplace.json` version to `0.2.0` and ensure skill descriptions are accurate
- The system shall provide `skills/README.md` as a skill directory hub listing all three skills with one-line descriptions, invocation syntax, and links to SKILL.md files

**Proof Artifacts:**
- File: `.claude-plugin/plugin.json` contains `"version": "0.2.0"`
- File: `.claude-plugin/marketplace.json` contains `"version": "0.2.0"`
- File: `skills/README.md` contains links to all three skill SKILL.md files

### Unit 7: README Update

**Purpose:** Update README.md to reflect implemented (not planned) skills, accurate file structure, and installation instructions.

**Functional Requirements:**
- The system shall update `README.md` to remove "Planned" labels from skills section
- The system shall update the plugin structure diagram to reflect actual implemented file tree
- The system shall verify all internal links and cross-references are accurate

**Proof Artifacts:**
- Grep: `README.md` does not contain the string "Planned"
- File: `README.md` plugin structure section matches actual file tree

## Non-Goals (Out of Scope)

- **Analytics or dashboards** — No metrics collection, velocity tracking, or burndown charts
- **Multi-repo coordination** — Arc manages a single BACKLOG per repository
- **Automated triage** — Arc is for intentional product thinking, not AI-automated prioritization
- **External tool integration** — No Linear, Jira, or GitHub Issues sync (future consideration)
- **Custom labels or properties** — Only priority (P0-P3) and status fields on ideas
- **Team or role assignment** — Handled by claude-workflow's `/cw-plan` and `/cw-dispatch`
- **Executable code or tests** — Pure markdown plugin; validation via SDD proof artifacts and Gherkin BDD

## Design Considerations

- All Mermaid diagrams use Liatrio brand theme variables: `primaryColor: #11B5A4`, `secondaryColor: #E8662F`, `tertiaryColor: #1B2A3D`, `fontFamily: Inter, sans-serif`
- AskUserQuestion interactions follow Temper's proven patterns: single-select with descriptions for stage transitions, multi-select for idea selection, freeform for problem statements
- Context markers (`**ARC-CAPTURE**`, `**ARC-SHAPE**`, `**ARC-WAVE**`) begin every skill response for disambiguation

## Repository Standards

- **Commit convention:** `type(scope): description` — types: feat, fix, docs, refactor, chore; scopes: arc, skills, templates, references, plugin
- **Plugin conventions:** Follow Temper's SKILL.md frontmatter, template YAML format, and reference doc structure
- **File naming:** Lowercase with hyphens; templates use `.tmpl.md` extension
- **Directory structure:** Skills in `skills/{skill-name}/`, templates in `templates/`, references in `references/`

## Technical Considerations

- **Stateless skills:** Each invocation reads CLAUDE.md and artifact files fresh — no hidden state persists between runs
- **BACKLOG storage format:** Inline sections with summary table header. Each idea is a `## {Title}` section. Captured ideas are stubs (title, summary, priority, status line). Shaped ideas expand inline with full brief subsections (Problem, Proposed Solution, Success Criteria, Constraints, Assumptions). The summary table at the top provides a scannable overview with columns: Title, Status, Priority, Wave.
- **Parallel subagents in `/arc-shape`:** Four concurrent subagent analyses (problem clarity, customer fit, scope boundaries, feasibility). Each subagent reads relevant context (CUSTOMER.md for customer fit, management report for feasibility) and returns structured findings. The skill aggregates results before presenting to the user.
- **CLAUDE.md injection:** Uses HTML comment markers (`<!--# BEGIN ARC:product-context -->`) following Temper's bootstrap-protocol.md coexistence rules. Independent of TEMPER: and MM: namespaces.
- **Temper integration:** `/arc-wave` reads `docs/management-report.md` if present. Graceful degradation when Temper is not installed or hasn't been run.
- **Template recovery:** VISION, CUSTOMER, ROADMAP, BACKLOG templates are adapted from Temper's git history (deleted in commit `4227536`) — not copied verbatim but tailored for Arc's product direction focus.

## Security Considerations

- No API keys, tokens, or secrets involved — pure markdown plugin
- No external network calls — all operations are local file reads and writes
- CLAUDE.md injection uses deterministic marker-based replacement, not regex on user content
- No user data collection or telemetry

## Success Metrics

- All three skills installable and invocable via `claude plugin install arc@arc`
- `/arc-capture` completes idea entry in ≤3 AskUserQuestion interactions
- `/arc-shape` produces a complete spec-ready brief from a captured idea stub
- `/arc-wave` creates a wave in ROADMAP.md and injects ARC:product-context into project CLAUDE.md
- Temper management report (when present) visibly constrains wave scope recommendations
- All four product artifact templates follow Temper's phase-graduated format conventions
- Zero occurrences of "focus" (legacy name) in any Arc file

## Open Questions

No open questions at this time.
