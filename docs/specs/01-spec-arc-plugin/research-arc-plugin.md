# Research Report: Arc Plugin

**Topic:** Arc — Claude Code plugin for lightweight product direction and idea lifecycle management
**Date:** 2026-04-07
**Working Directory:** /Users/ron/dev/arc

---

## Summary

Arc is a scaffold-stage Claude Code plugin (v0.1.0) at `/Users/ron/dev/arc/` that will provide three skills (`/arc-capture`, `/arc-shape`, `/arc-wave`) for managing product direction as markdown files in the repository. It is the upstream companion to [Temper](https://github.com/ronjanusz-liatrio/temper) in a three-plugin pipeline: `arc → claude-workflow → temper`.

Arc was extracted from the Focus/Temper plugin during the temper-split (PR #4, spec `06-spec-temper-split`). Four product artifact templates (VISION, CUSTOMER, ROADMAP, BACKLOG) and the Product Leadership role were removed from Temper and designated for Arc. The scaffold exists with plugin metadata, README, CLAUDE.md, and empty skill/template/reference directories.

**Key findings:**

- **Four artifact templates** recovered from Temper's git history (deleted in commit `4227536`): VISION (156 lines), CUSTOMER (165 lines), ROADMAP (163 lines), BACKLOG (147 lines) — all follow Temper's phase-graduated format with YAML frontmatter
- **Three skills** planned: `/arc-capture` (fast idea entry → BACKLOG), `/arc-shape` (interactive refinement → shaped brief), `/arc-wave` (delivery cycle management → ROADMAP update + handoff to temper/cw-spec)
- **Idea lifecycle model:** Capture → Shape → Spec-Ready → Shipped — inspired by Linear's Triage → Backlog → In Progress → Done but adapted for markdown-native, terminal-driven usage
- **CLAUDE.md managed sections:** Arc will inject `ARC:` namespace markers alongside Temper's `TEMPER:` markers, following the same bootstrap-protocol coexistence rules
- **Three reference docs** needed: idea-lifecycle.md (progression model), brief-format.md (spec-ready brief specification), wave-planning.md (delivery cycle organization)
- **Pipeline position:** Arc produces spec-ready briefs consumed by `/cw-spec`; `/temper-progress` gate results feed back to inform arc's next wave planning
- **No executable code:** Pure markdown plugin — testing = spec-driven verification with proof artifacts, Gherkin BDD scenarios, and gate evaluation

---

## 1. Tech Stack & Project Structure

### Plugin Identity

| Field | Value |
|-------|-------|
| Name | arc |
| Version | 0.1.0 |
| Owner | ronjanusz-liatrio |
| Marketplace | strict: true |
| Type | Pure markdown Claude Code plugin |
| Dependencies | temper (engineering maturity), claude-workflow (SDD pipeline) |
| Git commits | 1 (scaffold) |

### Current File Inventory

```
arc/
  .claude-plugin/
    plugin.json               # {"name": "arc", "version": "0.1.0"}
    marketplace.json          # ronjanusz-liatrio owner, strict mode
  skills/
    .gitkeep                  # Planned: arc-capture/, arc-shape/, arc-wave/
  templates/
    .gitkeep                  # Planned: VISION, CUSTOMER, ROADMAP, BACKLOG
  references/
    .gitkeep                  # Planned: idea-lifecycle, brief-format, wave-planning
  README.md                   # 145 lines — design vision, pipeline, planned skills
  CLAUDE.md                   # 23 lines — development instructions
  .gitignore                  # Standard ignores
```

### Planned Structure (Post-Implementation)

```
arc/
  .claude-plugin/
    plugin.json
    marketplace.json
  skills/
    README.md                       # Skill directory hub
    arc-capture/
      SKILL.md                      # Fast idea entry (3-4 step workflow)
      references/
        capture-protocol.md         # Quick-entry format, validation rules
    arc-shape/
      SKILL.md                      # Interactive refinement (5-7 step workflow)
      references/
        shaping-dimensions.md       # Problem framing, solution scoping subagent prompts
        brief-validation.md         # Readiness criteria for spec-ready status
    arc-wave/
      SKILL.md                      # Delivery cycle management (4-5 step workflow)
      references/
        wave-report-template.md     # Wave planning report format
        bootstrap-protocol.md       # ARC: namespace CLAUDE.md injection
  templates/
    VISION.tmpl.md                  # Product vision (always-required)
    CUSTOMER.tmpl.md                # Personas and JTBD (always-required)
    ROADMAP.tmpl.md                 # Phased delivery plan (product-leadership)
    BACKLOG.tmpl.md                 # Triaged idea list (product-leadership)
  references/
    README.md                       # Reference directory hub
    idea-lifecycle.md               # Capture → Shape → Spec-Ready → Shipped model
    brief-format.md                 # Spec-ready brief specification and examples
    wave-planning.md                # Wave organization, precedence, capacity
  docs/
    quick-reference.md              # Consolidated lookup tables
    specs/                          # SDD spec history
  README.md
  CLAUDE.md
  .gitignore
```

### Plugin Packaging Convention (Mirroring Temper)

**plugin.json:**
```json
{
  "name": "arc",
  "version": "0.1.0",
  "description": "Lightweight product direction for spec-driven development..."
}
```

**marketplace.json:**
```json
{
  "name": "arc",
  "owner": {"name": "ronjanusz-liatrio"},
  "metadata": {
    "description": "...",
    "version": "0.1.0"
  },
  "plugins": [{
    "name": "arc",
    "description": "...",
    "source": "./",
    "strict": true
  }]
}
```

### SKILL.md Format Convention

```yaml
---
name: arc-{skill}
description: "{one-line purpose}"
user-invocable: true
allowed-tools: Glob, Grep, Read, Write, Bash, AskUserQuestion, Task, Skill
---
```

Followed by: Context marker → Overview → Critical constraints → Process steps → References → What comes next.

### Template Format Convention

```yaml
---
role: always-required | product-leadership
artifact: VISION | CUSTOMER | ROADMAP | BACKLOG
output_path: docs/{ARTIFACT}.md
---
```

Followed by: Phase-graduated sections (Spike → Maturity), each with required sections, content guidance, Mermaid diagram specs (Liatrio brand colors), and cross-references.

---

## 2. Architecture & Patterns

### Three-Skill Architecture

| Skill | Analogue in Temper | Steps | Primary Action | Output |
|-------|-------------------|-------|----------------|--------|
| `/arc-capture` | temper-update (change detection) | 3-4 | Append idea stub to BACKLOG | BACKLOG entry (captured status) |
| `/arc-shape` | temper-update (interactive update) | 5-7 | Refine idea into structured brief | Shaped brief in BACKLOG (shaped status) |
| `/arc-wave` | temper-incept (project bootstrap) | 4-5 | Group ideas into delivery cycle | ROADMAP wave + ARC: CLAUDE.md sections |

### Context Markers

Each skill begins its response with a context marker:
- **ARC-CAPTURE** — signals fast capture mode
- **ARC-SHAPE** — signals interactive refinement mode
- **ARC-WAVE** — signals delivery cycle management mode

### AskUserQuestion Interaction Model

Arc follows Temper's proven patterns:

- **Single-select with descriptions** — for stage transitions (Capture → Shape → Spec-Ready)
- **Multi-select** — for selecting which ideas to include in a wave
- **Freeform input** — for problem statements, success criteria, constraints
- **Binary confirmation** — for brief approval, wave finalization

### CLAUDE.md Managed Section Pattern (ARC: Namespace)

Arc injects managed sections alongside Temper's `TEMPER:` markers:

```markdown
<!--# BEGIN ARC:product-context -->
## Product
- **Vision**: docs/VISION.md
- **Customer**: docs/CUSTOMER.md
- **Roadmap**: docs/ROADMAP.md (current wave: {wave name})
- **Backlog**: docs/BACKLOG.md ({N} spec-ready, {M} shaping)
<!--# END ARC:product-context -->
```

**Coexistence rules** (from Temper's bootstrap-protocol.md):
- Never modify TEMPER: or MM: sections
- Never nest markers across namespaces
- Insert after last TEMPER: section (or before Snyk block)
- Independent namespaces can interleave in any order

### Report Generation Pattern

Each skill produces a timestamped report:

| Skill | Report File | Contents |
|-------|------------|----------|
| `/arc-capture` | (inline — no separate report) | Confirmation of captured idea |
| `/arc-shape` | `docs/shape-report.md` | Brief refinement summary, before/after comparison |
| `/arc-wave` | `docs/wave-report.md` | Wave plan, selected ideas, handoff context |

### Subagent Pattern (for /arc-shape)

`/arc-shape` uses parallel subagents to analyze an idea across multiple dimensions:
- **Problem clarity** — Is the problem statement specific enough?
- **Customer fit** — Does this align with personas in CUSTOMER.md?
- **Scope boundaries** — Are constraints and non-goals explicit?
- **Feasibility** — Given the current Temper phase, can engineering absorb this?

---

## 3. Dependencies & Integrations

### Three-Plugin Pipeline

```
/arc-capture → /arc-shape → /arc-wave → /temper-incept → /cw-spec → /cw-plan → /cw-dispatch → /temper-progress
                                              ↑                                                          |
                                              '-------------------- phase loop --------------------------'
```

### Handoff Points

| From | To | Artifact | Content |
|------|----|----------|---------|
| `/arc-wave` | `/temper-incept` | Wave brief (markdown) | Selected ideas, vision context, customer focus, wave dependencies |
| `/arc-wave` | `/cw-spec` | Spec-ready brief | Problem, solution, success criteria, constraints, assumptions |
| `/temper-progress` | `/arc-wave` | Management report | Gate results, phase, coverage matrix — informs next wave planning |

### CLAUDE.md as Central Hub

All three plugins write to and read from the project's CLAUDE.md:

```
CLAUDE.md
  ├── ARC:product-context     ← written by /arc-wave
  ├── TEMPER:project-context   ← written by /temper-incept
  ├── TEMPER:rules             ← written by /temper-incept
  ├── TEMPER:architecture      ← written by /temper-incept
  ├── TEMPER:testing           ← written by /temper-incept
  ├── TEMPER:development       ← written by /temper-incept
  ├── TEMPER:specs             ← written by /temper-incept
  └── TEMPER:ecosystem         ← written by /temper-incept
```

**Stateless skill invocation:** Each skill reads CLAUDE.md at invocation time. No hidden state persists between skill runs.

### Plugin Installation Order

```bash
# 1. Install claude-workflow (execution engine)
claude plugin marketplace add https://github.com/ronjanusz-liatrio/claude-workflow.git
claude plugin install claude-workflow@claude-workflow --scope user

# 2. Install temper (engineering maturity)
claude plugin marketplace add https://github.com/ronjanusz-liatrio/temper.git
claude plugin install temper@temper --scope user

# 3. Install arc (product direction)
claude plugin marketplace add https://github.com/ronjanusz-liatrio/arc.git
claude plugin install arc@arc --scope user
```

### Feedback Loop: Temper → Arc

`/temper-progress` produces `docs/management-report.md` containing:
- **Current phase** — informs what complexity arc can plan next
- **Hard gate failures** — blocks arc from planning features the project can't absorb
- **Coverage matrix** — shows engineering artifact completeness
- **Phase advancement** — unlocks new complexity in ideas arc can shape

Arc reads this context to inform wave planning decisions:
- Projects at Spike/PoC → small waves, minimal scope
- Projects at Foundation+ → larger waves, more concurrent features
- Hard gate failures → next wave should include engineering stabilization

---

## 4. Test & Quality Patterns

### Testing = Spec-Driven Verification

For a pure markdown plugin, "testing" is fundamentally different from code-based projects:

1. **Specs with proof artifacts** — each demoable unit defines explicit proof artifacts (file existence, grep assertions, content checks, CLI output)
2. **Gherkin BDD scenarios** — `.feature` files define acceptance criteria in Given/When/Then format
3. **Gate evaluation** — `/temper-progress` gates A-B verify artifact existence and maturity
4. **No automated test suite** — validation via `/cw-validate` and `/cw-review-team`

### Proof Artifact Types

| Type | Method | Example |
|------|--------|---------|
| File Existence | Glob | `skills/arc-capture/SKILL.md` exists |
| Content Check | Read + section validation | SKILL.md contains context marker and frontmatter |
| Grep Assertion | Regex matching | No occurrence of "focus" in any arc file |
| CLI Output | Command execution | `claude plugin install arc@arc` succeeds |
| Config Validation | JSON parsing | plugin.json contains `"name": "arc"` |

### Commit Conventions

```
type(scope): description

Types: feat, fix, docs, refactor, test, chore
Scopes: arc, skills, templates, references, plugin
```

---

## 5. Data Models & API Surface

### Four Product Artifact Templates

All four templates were recovered from Temper's git history (deleted in commit `4227536`, recovered from commits `913b964`, `4f9522a`, `d5b17e3`):

#### VISION.tmpl.md (Always-Required)

| Phase | Level | Required Sections |
|-------|-------|-------------------|
| Spike | stub | One-paragraph summary (what + why) |
| PoC | draft | Problem statement, target audience, value proposition |
| Vertical Slice | draft-stable | + scope boundaries |
| Foundation | full | + success criteria (3+ measurable), strategic alignment, vision-to-strategy diagram |
| MVP+ | maintained | + current state summary, evolution trajectory |

**Cross-references:** CUSTOMER.md, PROJECT_CHARTER.md, ROADMAP.md, DECISIONS.md

#### CUSTOMER.tmpl.md (Always-Required)

| Phase | Level | Required Sections |
|-------|-------|-------------------|
| Spike | notes | Informal "who might use this" (2-4 sentences) |
| PoC | draft | Primary persona, needs/pain points, ≥1 JTBD statement |
| Vertical Slice | draft-validated | + secondary personas, ≥2 JTBD, interaction model |
| Foundation | full | + all personas finalized, JTBD catalog (≥3 per primary), success metrics, persona-to-artifact map |
| MVP+ | maintained | + adoption status, segmentation, expansion opportunities |

**JTBD format:** "When [situation], I want to [motivation], so I can [expected outcome]"
**Cross-references:** VISION.md, PROJECT_CHARTER.md, ROADMAP.md, DECISIONS.md

#### ROADMAP.tmpl.md (Product-Leadership)

| Phase | Level | Required Sections |
|-------|-------|-------------------|
| Spike/PoC | n/a | Not required |
| Vertical Slice | stub | Current wave (3-5 features), next wave preview, open questions |
| Foundation | draft | ≥3 waves with goal/deliverables/target/dependencies, milestone tracker, wave dependency graph (Mermaid) |
| MVP | full | + PO & architect rationale per wave, completed wave retrospectives, risk/contingency |
| Growth+ | maintained | + scaling considerations, long-term vision alignment, estimation retrospective |

**Mermaid diagrams:** Wave dependency flowchart (all phases), milestone timeline/gantt (MVP+)
**Cross-references:** VISION.md, PROJECT_CHARTER.md, BACKLOG.md, CUSTOMER.md, DECISIONS.md, ARCHITECTURE.md

#### BACKLOG.tmpl.md (Product-Leadership)

| Phase | Level | Required Sections |
|-------|-------|-------------------|
| Spike–VS | n/a | Not required |
| Foundation | stub | Overview, priority categories (MoSCoW or P0-P3), 5-15 initial items with name/description/priority/wave |
| MVP | draft | + IDs, size estimates, acceptance criteria, status tracking, customer persona reference, cut list |
| Growth | full | + backlog health metrics, feature streams, technical debt register |
| Maturity | maintained | + retrospective (estimation accuracy, lessons) |

**Cross-references:** VISION.md, ROADMAP.md, CUSTOMER.md, PROJECT_CHARTER.md, DECISIONS.md

### Idea Lifecycle Data Model

```
Capture → Shape → Spec-Ready → Shipped
  ↓         ↓
(needs    (scope
context)  change)
```

| Stage | Input | Output | Data Fields |
|-------|-------|--------|-------------|
| Capture | Raw idea | BACKLOG stub | title, one-line summary, priority, status |
| Shape | Captured idea + Q&A | Shaped brief | + problem, solution, success criteria, constraints, assumptions |
| Spec-Ready | Approved brief | Ready for `/cw-spec` | All fields locked, wave assignment |
| Shipped | Completed SDD pipeline | Done | Audit trail via DECISIONS.md |

### Spec-Ready Brief Format

A spec-ready brief is Arc's primary output — the artifact consumed by `/cw-spec`:

```markdown
## {Idea Title}

### Problem
{1-3 sentences: who, what pain, impact}

### Proposed Solution
{1-2 sentences: high-level approach, capability unlocked}

### Success Criteria
- {Metric/outcome with target}
- {Metric/outcome with target}
- {Metric/outcome with target}

### Constraints
- {Time, technical, team, scope constraints}

### Assumptions
- {What must be true}

### Wave Assignment
{ROADMAP wave reference, if known}

### Open Questions
- {Clarifications needed before /cw-spec}
```

### CLAUDE.md Managed Sections (ARC: Namespace)

Planned `ARC:` sections to inject into project CLAUDE.md:

| Section | Content | Injected by |
|---------|---------|-------------|
| `ARC:product-context` | Vision summary, current wave, primary personas, backlog status | `/arc-wave` |

Additional sections may be warranted but the initial implementation should start minimal — one section with pointers to the four artifact files.

---

## 6. Linear-Inspired Design Philosophy

### Concept Mapping

| Linear Concept | Arc Equivalent | Key Difference |
|---------------|----------------|----------------|
| Issue | BACKLOG entry | Arc entries are idea-focused (problem/solution/criteria), not task-focused |
| Triage | Capture stage | Arc capture is intentionally lightweight (no shape requirement) |
| Backlog | BACKLOG file | Both prioritized queues; Arc's is markdown-based, repo-tracked |
| Cycle | Wave | Arc waves are product-themed; Linear cycles are engineering-focused sprints |
| Project | ROADMAP theme | Arc themes are product direction; Linear projects are work containers |
| Labels | Priority (P0-P3) | Intentional simplicity — only priority and status |

### What Arc Adopts

1. **Fast capture** — `/arc-capture` enforces title + summary + priority only (30 seconds)
2. **Clean triage** — Capture stage as dedicated review before shaping
3. **Opinionated workflow** — Rigid Capture → Shape → Spec-Ready → Shipped (no branching)
4. **Time-boxed delivery** — Waves group spec-ready ideas into themed cycles

### What Arc Adapts

1. **Markdown-native** — Ideas as files in git, not SaaS database
2. **Terminal-first** — Claude Code CLI, not browser UI
3. **Explicit shaping** — Interactive `/arc-shape` dialogue forces product thinking
4. **Product ≠ engineering** — Arc (what to build) vs Temper (is it ready?)

### What Arc Intentionally Omits

- Issue templates and custom properties (Arc's only job is produce input for `/cw-spec`)
- Team/role assignment (handled by claude-workflow's `/cw-plan` and `/cw-dispatch`)
- Labels and advanced filtering (intentional simplicity)
- AI-assisted triage (Arc is for thinking, not automation)
- Burndown charts and velocity tracking (Temper gates provide readiness metrics)
- Cross-team permissions (single BACKLOG per repo)

---

## 7. Key Decisions & Constraints

### Architecture Constraints

1. **Must follow Temper's plugin conventions** — SKILL.md frontmatter, template format, reference organization, Liatrio brand colors in Mermaid diagrams
2. **Must use ARC: namespace** for CLAUDE.md managed sections, coexisting with TEMPER: and MM:
3. **Must produce spec-ready briefs** consumable by `/cw-spec` — this is Arc's primary output
4. **Must read Temper's management report** for feedback loop — gate results inform wave planning
5. **Skills are stateless** — each invocation reads CLAUDE.md and artifact files; no persistent state between runs

### Design Constraints

1. **Markdown-native only** — no database, no external service, no executable code
2. **No product artifact maturity gates** — Arc doesn't block engineering work; Temper handles gates
3. **Templates must be phase-graduated** — same 7-phase model as Temper (Spike → Maturity)
4. **Brief format must be stable** — `/cw-spec` depends on consistent brief structure

### Scope Boundaries

1. **In scope:** Three skills, four templates, three reference docs, ARC: namespace bootstrap
2. **Out of scope:** Analytics, reporting dashboards, multi-repo coordination, automated triage
3. **Future consideration:** Integration with Linear/Jira for teams using external tracking

---

## Meta-Prompt

---

The following is a ready-to-use `/cw-spec` starter prompt enriched with codebase knowledge:

**Feature Name:** Arc Plugin — Product Direction and Idea Lifecycle Management

**Research:** `docs/specs/research-arc-plugin/`

**Problem Statement:** Projects using the Temper + claude-workflow SDD pipeline lack a structured upstream process for product direction. Ideas enter `/cw-spec` as ad-hoc prompts without consistent problem framing, customer context, success criteria, or scope boundaries. Arc fills this gap with three skills (`/arc-capture`, `/arc-shape`, `/arc-wave`) that manage four product artifacts (VISION, CUSTOMER, ROADMAP, BACKLOG) as markdown files in the repository, producing spec-ready briefs that feed directly into the SDD pipeline.

**Key Components:**
- `/arc-capture` skill — fast idea entry (3-4 step workflow, appends to BACKLOG)
- `/arc-shape` skill — interactive refinement (5-7 step workflow, produces shaped brief)
- `/arc-wave` skill — delivery cycle management (4-5 step workflow, updates ROADMAP, injects ARC: CLAUDE.md sections, prepares handoff)
- VISION.tmpl.md — product vision template (phase-graduated, recovered from Temper)
- CUSTOMER.tmpl.md — customer personas template (phase-graduated, recovered from Temper)
- ROADMAP.tmpl.md — delivery plan template (phase-graduated, recovered from Temper)
- BACKLOG.tmpl.md — triaged idea list template (phase-graduated, recovered from Temper)
- idea-lifecycle.md — reference doc defining Capture → Shape → Spec-Ready → Shipped model
- brief-format.md — reference doc specifying the spec-ready brief structure
- wave-planning.md — reference doc for wave organization, precedence rules, capacity

**Architectural Constraints:**
- Follow Temper's SKILL.md format (frontmatter: name, description, user-invocable, allowed-tools)
- Follow Temper's template format (YAML frontmatter: role, artifact, output_path; phase-graduated sections)
- Use ARC: namespace for CLAUDE.md managed sections (coexist with TEMPER: per bootstrap-protocol.md)
- All Mermaid diagrams use Liatrio brand colors (primary: #11B5A4, secondary: #E8662F, tertiary: #1B2A3D)
- Skills are stateless — read CLAUDE.md + artifact files on each invocation
- Brief format must be stable for `/cw-spec` consumption

**Patterns to Follow:**
- Temper's context marker pattern: `**ARC-{SKILL}**` at start of response
- Temper's AskUserQuestion pattern: options with descriptions, multiSelect for idea selection
- Temper's report generation: timestamped markdown reports saved to docs/
- Temper's bootstrap-protocol.md: HTML comment markers, insertion algorithm, coexistence rules
- Temper's phase-graduated templates: 7 phases with stub/draft/full maturity levels

**Suggested Demoable Units:**
1. Reference documents (idea-lifecycle.md, brief-format.md, wave-planning.md)
2. Product artifact templates (VISION, CUSTOMER, ROADMAP, BACKLOG — adapted from recovered Temper templates)
3. `/arc-capture` skill (fast idea entry → BACKLOG append)
4. `/arc-shape` skill (interactive refinement → shaped brief)
5. `/arc-wave` skill (wave management → ROADMAP update + ARC: CLAUDE.md injection + handoff)
6. Plugin metadata update (version bump, marketplace description update)
7. README update (reflect implemented skills, remove "Planned" labels)

**Code References:**
- Temper SKILL.md examples: `/Users/ron/dev/temper/skills/temper-incept/SKILL.md`, `temper-progress/SKILL.md`, `temper-update/SKILL.md`
- Temper bootstrap protocol: `/Users/ron/dev/temper/skills/temper-incept/references/bootstrap-protocol.md`
- Temper template examples: `/Users/ron/dev/temper/templates/always-required/PROJECT_CHARTER.tmpl.md`, `DECISIONS.tmpl.md`
- Temper reference examples: `/Users/ron/dev/temper/references/maturity-model.md`, `ecosystem-model.md`
- Recovered product templates: git history at commits `913b964`, `4f9522a`, `d5b17e3` in Temper repo
- Arc scaffold: `/Users/ron/dev/arc/`

---
