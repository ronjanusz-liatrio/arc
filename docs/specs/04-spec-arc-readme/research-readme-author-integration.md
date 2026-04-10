# Research Report: readme-author Integration with Arc

**Topic:** How to use liatrio-labs/claude-plugins readme-author plugin with Arc
**Date:** 2026-04-08
**Dimensions explored:** 5/5
**Deep-dives completed:** 3

---

## Summary

The [readme-author](https://github.com/liatrio-labs/claude-plugins/tree/main/plugins/readme-author) plugin (v1.0.0) from liatrio-labs creates and improves README.md files using 6 project-type templates, interactive section-by-section workflows, 14 reference guides, and 3 helper scripts. Arc (v0.4.0) manages the upstream idea lifecycle with 5 skills and 4 markdown artifacts (VISION, CUSTOMER, ROADMAP, BACKLOG).

The two plugins have a natural integration surface: Arc knows *what* was built and *why* (product direction), while readme-author knows *how to present it* (documentation craft). Together, they can keep a project's README automatically aligned with its product lifecycle — from vision statement through shipped features.

**Five concrete integration ideas emerged, ranked by value and effort:**

1. **Arc-managed README sections** (medium effort, high value) — Use Arc's existing managed-section injection pattern (`<!--# BEGIN/END -->`) to keep README sections in sync with Arc artifacts
2. **New `/arc-sync` skill** (medium effort, high value) — Invoke readme-author patterns to generate/update README from Arc artifacts after features ship
3. **Arc-review README staleness check** (low effort, medium value) — Add WA-7 audit dimension to flag when README is stale relative to shipped waves
4. **Claude plugin README template** (low effort, medium value) — Contribute a `template-claude-plugin.md` to readme-author for Claude Code plugin projects
5. **Cross-plugin pipeline extension** (high effort, high value) — Full end-to-end: `arc-wave → SDD → ship → arc-sync → readme-author`

---

## Tech Stack & Project Structure

### readme-author (liatrio-labs/claude-plugins)

```
plugins/readme-author/
  .claude-plugin/plugin.json          # v1.0.0, MIT license
  README.md                           # Plugin documentation
  skills/readme-author/
    SKILL.md                          # Core skill definition
    assets/templates/                 # 6 project-type templates
      template-universal.md           # All-purpose (100-150 lines)
      template-library.md             # Libraries/packages (120-180 lines)
      template-cli.md                 # CLI tools
      template-application.md         # Desktop/web apps
      template-api.md                 # APIs/services
      template-minimal.md             # Bare essentials (20-50 lines)
    references/                       # 14 reference guides
      interactive-workflow.md         # Section-by-section workflow
      length-and-conciseness.md       # Target lengths, bloat red flags
      license-handling.md             # LICENSE file rules
      readme-best-practices-research.md
      readme-components-guide.md
      readme-research-analysis.md
      markdown-gfm-reference.md
      accessibility-inclusive-documentation-guide.md
      badge-systems-visual-elements-guide.md
      section-{installation,usage,api,contributing,badges}.md
    scripts/
      badge_generator.py              # Shields.io badge generation
      generate_toc.py                 # Table of contents
      validate_links.py               # Link validation
```

### Arc (this repo)

```
arc/
  .claude-plugin/                     # v0.4.0
  skills/
    arc-assess/                        # Discover & import scattered content
    arc-capture/                      # Fast idea entry (30 seconds)
    arc-shape/                        # Refine into spec-ready brief
    arc-wave/                         # Delivery cycle management
    arc-audit/                       # Pipeline health audit
  templates/                          # Phase-aware artifact templates
    VISION.tmpl.md, CUSTOMER.tmpl.md, ROADMAP.tmpl.md, BACKLOG.tmpl.md
  references/                         # Shared lifecycle models
    idea-lifecycle.md, brief-format.md, wave-planning.md
```

---

## Architecture & Patterns

### Shared Design Patterns

Both plugins follow identical structural conventions:
- **SKILL.md** with YAML frontmatter (name, description, allowed-tools)
- **references/** for domain knowledge documents
- **templates/** or **assets/templates/** for scaffolding
- **.claude-plugin/plugin.json** for identity
- **Interactive workflows** using AskUserQuestion with approve/modify/skip patterns

### Key Difference: State Management

| Concern | Arc | readme-author |
|---------|-----|---------------|
| **Managed files** | 4 artifacts in `docs/` + CLAUDE.md injection | Single README.md per invocation |
| **State tracking** | Status lifecycle (captured→shaped→spec-ready→shipped) | Stateless — each run is independent |
| **Idempotency** | Manifest tracking, managed section markers | No state between runs |
| **Cross-references** | Artifacts reference each other extensively | Self-contained within README |

### Arc's Managed-Section Injection Pattern

Arc uses HTML comment markers to inject and maintain content in files:

```html
<!--# BEGIN ARC:product-context -->
## Product Context
- **Vision:** {first sentence of docs/VISION.md}
- **Current Wave:** {wave name}
- **Primary Personas:** {comma-separated}
- **Backlog:** {N} captured, {N} shaped, {N} spec-ready, {N} shipped
<!--# END ARC:product-context -->
```

**This pattern is directly applicable to README.md** — Arc could inject managed sections that stay in sync with product artifacts while leaving the rest of the README under readme-author's control.

---

## Integration Ideas (Deep-Dive)

### Idea 1: Arc-Managed README Sections

**What:** Use Arc's `<!--# BEGIN/END -->` managed-section pattern to inject product-aware content directly into README.md, alongside manually-authored content managed by readme-author.

**How it works:**
```markdown
# My Project

{readme-author manages: badges, description, installation, usage}

<!--# BEGIN ARC:features -->
## Features

- **Fast Idea Capture** — Record product ideas in under 30 seconds (shipped Wave 1)
- **Interactive Shaping** — Refine ideas into spec-ready briefs (shipped Wave 1)
- **Delivery Cycles** — Group ideas into themed waves (shipped Wave 2)
<!--# END ARC:features -->

<!--# BEGIN ARC:roadmap -->
## Roadmap

| Wave | Theme | Status |
|------|-------|--------|
| Wave 3 | Pipeline Health | Active |
| Wave 4 | Cross-Plugin Integration | Planned |
<!--# END ARC:roadmap -->

{readme-author manages: contributing, license, support}
```

**Pros:** Low coupling — each plugin owns its sections. Idempotent updates. No new skill needed.
**Cons:** Requires arc-wave to know README structure. Manual setup of initial markers.

### Idea 2: New `/arc-sync` Skill

**What:** A new Arc skill that reads all 4 artifacts and generates/updates README content using readme-author's templates and best practices as a reference.

**Trigger:** After features ship (post `/cw-validate` or `/temper-audit`), or on-demand.

**Workflow:**
1. Read VISION.md → extract project description, problem statement, value proposition
2. Read CUSTOMER.md → extract target audience, primary persona, JTBD statements
3. Read BACKLOG.md → extract shipped features, spec-ready pipeline
4. Read ROADMAP.md → extract current wave, upcoming waves, milestones
5. Detect existing README.md — update managed sections or scaffold from template
6. Apply readme-author quality rules (100-200 line target, accessibility, progressive disclosure)
7. Validate links, generate TOC if needed
8. Present for user approval

**Artifact → README Section Mapping:**

| Arc Artifact | Field | README Section |
|---|---|---|
| VISION.Vision Summary | 1 paragraph | Opening description |
| VISION.Problem Statement | 2-3 sentences | "Why This Project?" |
| VISION.Value Proposition | 1 sentence | Tagline / subtitle |
| VISION.Scope Boundaries | In/Out lists | "What This Does (and Doesn't)" |
| CUSTOMER.Primary Persona | Name, role, context | "Who It's For" |
| CUSTOMER.JTBD Statements | When/Want/So | "Use Cases" |
| CUSTOMER.Needs & Pain Points | Bullet list | "Problems We Solve" |
| ROADMAP.Wave Summary Table | Wave/Goal/Status | "Roadmap" |
| ROADMAP.Completed Waves | Delivered/Deferred | "Changelog" |
| BACKLOG shipped items | Problem + Solution | "Features" |
| BACKLOG spec-ready items | Title + Priority | "Coming Soon" |

**Phase-awareness:** The README scales with project maturity:
- **Spike:** Minimal README (VISION summary only, ~50 lines)
- **PoC:** + problem statement, primary persona, installation
- **Vertical Slice:** + features, use cases, basic roadmap
- **Foundation+:** Full README with all sections (100-200 lines)

### Idea 3: Arc-Review README Staleness Check (WA-7)

**What:** Add a new audit dimension to `/arc-audit` that checks if README.md is stale relative to shipped waves.

**Detection logic:**
1. Check if `README.md` exists at project root
2. Compare README's last git commit date against most recent wave completion date in ROADMAP.md
3. Parse README for mentions of shipped features — flag if shipped BACKLOG items aren't referenced
4. Check for managed section markers — flag if markers exist but content is outdated

**Severity:** Warning (not critical — stale README doesn't block pipeline)

**Output format (matching existing audit-dimensions.md pattern):**
```markdown
**WA-7: README Staleness**

README last updated: 2026-03-15
Most recent shipped wave: Wave 2 (2026-04-01)
Shipped features not in README: 3 of 5

Warning: README not updated since Wave 2 shipped.
Recommended: Run /arc-sync or manually update features section.
```

**Interactive fix:** Offer to run `/arc-sync` or mark as acknowledged.

### Idea 4: Claude Plugin README Template

**What:** Contribute a `template-claude-plugin.md` to the readme-author plugin, designed specifically for Claude Code plugins.

**Why it matters:** Arc, temper, claude-workflow, and readme-author are all Claude Code plugins. A purpose-built template would include:
- Plugin installation via marketplace (`claude plugin marketplace add`, `claude plugin install`)
- Skill invocation syntax (`/skill-name [args]`)
- Plugin structure diagram (`.claude-plugin/`, `skills/`, `references/`)
- Prerequisites section (dependent plugins)
- Arc artifact reference section (for Arc-integrated plugins)
- Workflow diagrams (mermaid) showing skill interaction

**This benefits the broader liatrio-labs ecosystem** — any new plugin gets a consistent, high-quality README.

### Idea 5: Cross-Plugin Pipeline Extension

**What:** Extend the full SDD pipeline to include documentation as a delivery artifact:

```
/arc-wave → /cw-spec → /cw-plan → /cw-dispatch → /cw-validate → /temper-audit → /arc-sync
                                                                                         ↓
                                                                                   readme-author
                                                                                   (quality rules)
```

**How:** After `/temper-audit` advances the project phase, `/arc-sync` runs automatically (or is offered as a next step) to update the README with:
- Newly shipped features from the wave
- Updated roadmap status
- Phase-appropriate detail level (using Temper's phase as input)
- readme-author quality validation (length, accessibility, link checking)

**This makes README a first-class delivery artifact** — it's never an afterthought because the pipeline includes it.

---

## Dependencies & Integrations

### Cross-Plugin Dependency Map

```
readme-author (liatrio-labs/claude-plugins)
    ↑ patterns/templates consumed by
arc (ronjanusz-liatrio/arc)
    ↑ product direction consumed by
temper (ronjanusz-liatrio/temper)
    ↑ maturity gates consumed by
claude-workflow (ronjanusz-liatrio/claude-workflow)
```

### Integration Approaches

| Approach | Coupling | Effort | Value |
|----------|---------|--------|-------|
| Arc managed sections in README | Low | Low | Medium |
| `/arc-sync` skill (standalone) | Medium | Medium | High |
| `/arc-sync` invoking readme-author | High | High | Very High |
| WA-7 audit check | None | Low | Medium |
| Claude plugin template contribution | None | Low | Medium |

### Recommended Sequence

1. **Start with WA-7** (low effort, immediate value from arc-audit)
2. **Add managed sections** to arc-wave's existing CLAUDE.md injection step
3. **Build `/arc-sync`** as a standalone skill using readme-author's quality rules as reference docs
4. **Contribute template-claude-plugin.md** upstream to liatrio-labs/claude-plugins
5. **Wire into pipeline** as the final delivery step

---

## Test & Quality Patterns

### readme-author Quality Gates

readme-author enforces several quality gates that `/arc-sync` should respect:

- **Length target:** 100-200 lines (refactor if exceeding)
- **Accessibility:** Alt text on images, heading hierarchy (H1→H2→H3), descriptive links, plain language (Grade 8-10)
- **Progressive disclosure:** README for quick start, `docs/` for deep dives
- **License handling:** Only reference existing LICENSE files, never create
- **Link validation:** All internal/external links verified
- **Badge limit:** 3-7 functional badges

### Arc Quality Gates

Arc's existing validation patterns that apply:
- **Brief validation:** 19-point checklist for spec-ready briefs
- **Manifest tracking:** Idempotent re-runs via audit trail
- **Health ratings:** Healthy / Needs Attention / Critical

---

## Data Models & API Surface

### readme-author Template Placeholder System

Templates use bracketed placeholders and HTML comment annotations:

```markdown
<!-- LENGTH TARGET: 120-180 lines -->
<!-- DELETE sections you don't need -->

# [Project Name]

[![Version](https://img.shields.io/badge/version-{version}-green.svg)]()

A concise, one-sentence description of what the project does.

## Why [Project Name]?

- **Problem**: Brief statement of the problem
- **Solution**: How this solves it
- **Benefit**: The concrete advantage
```

### Arc Artifact Data Available for README

| Data Source | Available Fields | Update Frequency |
|---|---|---|
| VISION.md | Summary, problem, value prop, scope, success criteria | Rarely (per phase) |
| CUSTOMER.md | Personas, JTBD, needs/pain points, interaction model | Rarely (per phase) |
| ROADMAP.md | Waves, themes, statuses, milestones, retrospectives | Per wave |
| BACKLOG.md | Ideas (title, status, priority, brief), summary table | Per capture/shape/ship |

---

## Meta-Prompt

---

The following is a ready-to-use `/cw-spec` starter prompt, enriched with codebase knowledge from this research:

**Feature:** `/arc-sync` — Arc-aware README generation and maintenance

**Problem:** Project READMEs drift out of sync with product direction as features ship. Arc tracks the full idea lifecycle (VISION, CUSTOMER, ROADMAP, BACKLOG) but has no mechanism to propagate shipped features, updated roadmaps, or audience context into the project's README. Teams either manually update READMEs (inconsistently) or skip it entirely.

**Key components to modify or create:**
- `skills/arc-sync/SKILL.md` — New skill definition
- `skills/arc-sync/references/readme-mapping.md` — Artifact-to-README section mapping rules
- `skills/arc-sync/references/readme-quality-rules.md` — Quality gates adapted from readme-author
- `skills/arc-audit/references/audit-dimensions.md` — Add WA-7 README Staleness check
- `skills/README.md` — Update skill directory hub
- `.claude-plugin/marketplace.json` — Update skill list

**Architectural constraints:**
- Must use Arc's existing `<!--# BEGIN/END -->` managed-section injection pattern for README sections
- Must coexist with manually-authored README content (readme-author or hand-written)
- Must respect Temper phase for README detail level (Spike=minimal, Foundation+=full)
- Must not create README.md if it doesn't exist (warn and offer to scaffold instead)
- Quality rules should reference readme-author's standards (100-200 lines, accessibility, progressive disclosure) but not require readme-author as a runtime dependency

**Patterns to follow:**
- Arc-wave's CLAUDE.md injection (bootstrap-protocol.md) for managed sections
- Arc-review's audit-dimensions.md for the WA-7 check pattern
- Arc-shape's parallel subagent analysis for multi-dimensional README assessment
- Arc's AskUserQuestion interactive workflow for section-by-section approval

**Suggested demoable units:**
1. WA-7 README staleness check in arc-audit (audit-only, no changes)
2. `/arc-sync` scaffold mode — generate initial README from VISION + CUSTOMER artifacts
3. `/arc-sync` update mode — sync managed sections from BACKLOG shipped items + ROADMAP
4. Pipeline integration — arc-sync offered as next step after temper-audit phase advance

**Code references:**
- `skills/arc-wave/references/bootstrap-protocol.md` — Managed section injection pattern
- `skills/arc-audit/references/audit-dimensions.md` — Health check pattern (for WA-7)
- `templates/VISION.tmpl.md` — Phase-aware template structure to follow
- `references/idea-lifecycle.md` — Status transitions that trigger README updates
- readme-author `SKILL.md` — Quality rules and template patterns to adapt
- readme-author `references/length-and-conciseness.md` — Length targets and bloat rules
- readme-author `references/accessibility-inclusive-documentation-guide.md` — Accessibility standards

---
