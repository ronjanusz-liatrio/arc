# Research Report: Arc Codebase — Product-Direction Discovery

**Topic:** Product-direction discovery for `/arc-assess` import consolidation
**Date:** 2026-04-12
**Working Directory:** /Users/ron/dev/arc
**Arc Version:** 0.10.0

---

## Architecture & Module Structure

### Plugin Identity

| Field | Value |
|-------|-------|
| Name | arc |
| Version | 0.10.0 |
| Owner | ronjanusz-liatrio |
| Type | Pure markdown Claude Code plugin (no executable code) |
| Strict mode | true |
| Required companions | temper, claude-workflow |
| Optional companions | readme-author |

### Directory Layout

```
arc/
  .claude-plugin/
    plugin.json                             # Plugin identity: name, version, description, companions
    marketplace.json                        # Marketplace registration: owner, metadata, source
  .claude/
    settings.local.json                     # Local dev permissions (gitignored)
  skills/
    README.md                               # Skill directory hub (7 skills listed)
    arc-assess/
      SKILL.md                              # Codebase discovery and migration (~1400 lines)
      references/
        align-report-template.md            # Alignment report format
        detection-patterns.md               # 22 keyword + 4 structural + 4 code comment patterns
        import-rules.md                     # Classification, stub generation, cleanup, manifest
    arc-capture/
      SKILL.md                              # Fast idea entry (~155 lines)
    arc-shape/
      SKILL.md                              # Interactive refinement with parallel subagents (~379 lines)
      references/
        shaping-dimensions.md               # Four analysis dimensions
        brief-validation.md                 # 19-criterion readiness checklist
    arc-wave/
      SKILL.md                              # Delivery cycle management (~357 lines)
      references/
        wave-report-template.md             # Wave report format
        bootstrap-protocol.md               # ARC: namespace CLAUDE.md injection rules
    arc-sync/
      SKILL.md                              # README lifecycle management (~762 lines, largest skill)
      references/
        trust-signals.md                    # 10 structural trust-signal definitions (TS-1 to TS-10)
        readme-mapping.md                   # Artifact-to-section extraction rules
        readme-quality-rules.md             # Quality gates (line count, headings, accessibility)
    arc-audit/
      SKILL.md                              # Pipeline health audit (~390 lines)
      references/
        audit-dimensions.md                 # 5 backlog health + 10 wave alignment checks
        review-report-template.md           # Report format
    arc-help/
      SKILL.md                              # Quick reference guide (~112 lines, static output)
  templates/
    VISION.tmpl.md                          # Phase-graduated (Spike-Maturity), role: always-required
    CUSTOMER.tmpl.md                        # Phase-graduated, role: always-required
    ROADMAP.tmpl.md                         # Phase-graduated, role: product-leadership
    BACKLOG.tmpl.md                         # Phase-graduated, role: product-leadership
  references/
    README.md                               # Reference directory hub
    idea-lifecycle.md                       # 4-stage model: Capture > Shape > Spec-Ready > Shipped
    brief-format.md                         # 7-section spec-ready brief specification
    wave-planning.md                        # Wave sizing, precedence, theme grouping
    cross-plugin-contract.md                # What Arc reads from Temper (read-only)
    vocabulary-mapping.md                   # Arc vs Temper terminology disambiguation
  docs/
    specs/
      01-spec-arc-plugin/                   # Initial 7-unit plugin spec (v0.2.0)
      02-spec-arc-plugin-enhancement/       # /arc-audit + error-path Gherkin (v0.3.0)
      03-spec-arc-align/                    # /arc-assess codebase discovery (v0.4.0)
      04-spec-arc-readme/                   # /arc-sync README management (v0.5.0)
      05-spec-arc-help/                     # /arc-help quick reference (v0.6.0)
      06-spec-arc-align-enhance/            # arc-assess enhancements (research, specs, code comments)
      07-spec-capture-speedup/              # Capture flow consolidation to 1-2 prompts
      01-spec-align-ignore-dirs/            # Align exclusion list expansion
  CLAUDE.md                                 # Project instructions
  README.md                                 # Full project documentation with Mermaid diagrams
  .gitignore                                # OS, editor, Claude, Node, Python, build exclusions
```

### Key Architectural Patterns

1. **Skill-based architecture:** Each skill is a self-contained SKILL.md with YAML frontmatter (`name`, `description`, `user-invocable`, `allowed-tools`), context marker, critical constraints, numbered process steps, and references section.
2. **File-based state machine:** All state lives in `docs/BACKLOG.md` with explicit status transitions (`captured` > `shaped` > `spec-ready` > `shipped`) and two backward transitions (Shape > Capture for "needs context", Spec-Ready > Shape for "scope change").
3. **Managed section protocol:** HTML comment markers (`<!--# BEGIN ARC:{section} -->` / `<!--# END ARC:{section} -->`) for injecting content into CLAUDE.md and README.md. Coexists with TEMPER: and MM: namespaces.
4. **Phase-graduated templates:** Each artifact template scales content requirements across 7 Temper maturity phases (Spike > PoC > Vertical Slice > Foundation > MVP > Growth > Maturity).
5. **Parallel subagent analysis:** `/arc-shape` launches 4 concurrent subagents (problem clarity, customer fit, scope boundaries, feasibility) to analyze ideas.
6. **Trust-signal framework:** 10 structural signals (TS-1 through TS-10) validate README quality by cross-referencing managed sections against source artifacts.
7. **Audit dimensions:** 5 backlog health checks (BH-1 to BH-5) + 10 wave alignment checks (WA-1 to WA-10) with severity-based health rating.

### Product-Direction Artifacts (Not Yet Created)

The following files are defined by the plugin but do **not** exist in the repository yet:

| Artifact | Expected Path | Created By |
|----------|--------------|------------|
| VISION | `docs/VISION.md` | `/arc-wave` (stub), `/arc-assess` (import), or manual |
| CUSTOMER | `docs/CUSTOMER.md` | `/arc-wave` (stub), `/arc-assess` (import), or manual |
| ROADMAP | `docs/ROADMAP.md` | `/arc-wave` |
| BACKLOG | `docs/BACKLOG.md` | `/arc-capture`, `/arc-assess` |
| Align report | `docs/skill/arc/align-report.md` | `/arc-assess` |
| Align manifest | `docs/skill/arc/align-manifest.md` | `/arc-assess` |
| Align analysis | `docs/skill/arc/align-analysis.md` | `/arc-assess` |
| Wave report | `docs/skill/arc/wave-report.md` | `/arc-wave` |
| Review report | `docs/skill/arc/review-report.md` | `/arc-audit` |
| Shape report | `docs/skill/arc/shape-report.md` | `/arc-shape` |

---

## Conventions & Naming Patterns

### File Naming

| Category | Convention | Examples |
|----------|-----------|---------|
| Skill definitions | `skills/{skill-name}/SKILL.md` | `skills/arc-capture/SKILL.md` |
| Skill references | `skills/{skill-name}/references/{topic}.md` | `skills/arc-shape/references/shaping-dimensions.md` |
| Templates | `templates/{ARTIFACT}.tmpl.md` | `templates/VISION.tmpl.md` |
| Shared references | `references/{topic}.md` | `references/idea-lifecycle.md` |
| Spec directories | `docs/specs/{NN}-spec-{feature}/` | `docs/specs/01-spec-arc-plugin/` |
| Spec files | `{NN}-spec-{feature}.md` | `01-spec-arc-plugin.md` |
| Research reports | `research-{topic}.md` inside spec dir | `research-arc-plugin.md` |
| Proof artifacts | `{NN}-proofs/T{NN}-proofs.md` | `01-proofs/T01.1-proofs.md` |
| Question files | `{NN}-questions-{N}-{feature}.md` | `01-questions-1-arc-plugin.md` |

### Markdown Structure Patterns

- **SKILL.md:** YAML frontmatter > Context Marker > Overview > Critical Constraints > Process (numbered steps) > References
- **Templates:** YAML frontmatter (`role`, `artifact`, `output_path`) > Template description > Phase Requirements (7 phases) > Cross-References
- **References:** H1 title > Prose overview > Structured sections (tables, code blocks, examples) > Cross-References
- **Specs:** H1 title > Introduction/Overview > Goals (numbered) > User Stories > Demoable Units > Non-Goals > Design/Technical/Security Considerations > Success Metrics > Open Questions

### Status and Priority Labels

**Idea statuses:** `captured`, `shaped`, `spec-ready`, `shipped`

**Priority levels:** `P0-Critical`, `P1-High`, `P2-Medium`, `P3-Low`

**Health ratings:** `Healthy`, `Needs Attention`, `Critical`

**Finding severities:** `info`, `warning`, `critical`

**Trust-signal outcomes:** `PASS`, `FAIL`, `N/A`

### Commit Convention

`type(scope): description` where types are `feat`, `fix`, `docs`, `refactor`, `chore`, `test` and scopes include `arc`, `arc-capture`, `arc-shape`, `arc-wave`, `arc-sync`, `arc-audit`, `arc-assess`, `arc-help`, `skills`, `templates`, `references`, `plugin`.

### Branding

Liatrio brand colors used in all Mermaid diagrams:
- Primary (teal): `#11B5A4`
- Secondary (orange): `#E8662F`
- Tertiary (dark blue): `#1B2A3D`
- Font: `Inter, sans-serif`

---

## Dependencies & Integrations

### Required Companions

| Plugin | Relationship | Integration Points |
|--------|-------------|-------------------|
| **temper** | Arc reads Temper artifacts (read-only) | `docs/ARCHITECTURE.md`, `docs/TESTING.md`, `docs/DEPLOYMENT.md`, `docs/TECH_STACK.md`, `docs/skill/temper/management-report.md`, `TEMPER:project-context` in CLAUDE.md |
| **claude-workflow** | Arc feeds briefs to CW's SDD pipeline | Shaped briefs from BACKLOG.md feed `/cw-spec` > `/cw-plan` > `/cw-dispatch` > `/cw-validate` |

### Optional Companion

| Plugin | Relationship |
|--------|-------------|
| **readme-author** | Arc absorbed its patterns into `/arc-sync`; listed as optional in plugin.json |

### Cross-Plugin Contract

Arc > Temper access is strictly read-only. Arc never creates, modifies, or deletes Temper-managed artifacts. Key reads:
- Phase and gate status from `docs/skill/temper/management-report.md` (constrains wave sizing)
- Architecture context from `docs/ARCHITECTURE.md` (informs feasibility analysis in `/arc-shape`)
- Test strategy from `docs/TESTING.md` (scope boundary analysis)
- Deployment complexity from `docs/DEPLOYMENT.md` (delivery risk assessment)
- Tech stack from `docs/TECH_STACK.md` (feasibility assessment)

### Vocabulary Mapping

| Arc Term | Temper Term | Relationship |
|----------|------------|--------------|
| Wave (delivery cycle) | Phase (maturity stage) | Waves happen within phases |
| Trust signals | Gates | Both are quality checks, different domain |
| captured/shaped/spec-ready/shipped | notes/sketch/draft/stub/full | Different axes: idea lifecycle vs document maturity |
| assess/sync/audit | assess/sync/audit | Same verbs, same intent, different domain |

---

## Product-Direction Content Findings

### Overview

Arc is a tool-building repo (the plugin itself). It does not have its own `docs/VISION.md`, `docs/CUSTOMER.md`, `docs/ROADMAP.md`, or `docs/BACKLOG.md` yet. All product-direction content is scattered across spec files, the README, CLAUDE.md, skill definitions, and research reports.

### Finding 1: Vision and Mission Content in README.md

**File:** `README.md`
**Lines:** 1-5
**Content:**
```
# Arc
Lightweight product direction for spec-driven development -- inspired by Linear's fast capture and clean triage, arc is the upstream companion to temper.
Arc manages the idea lifecycle from raw thought to spec-ready brief.
```
**Classification:** VISION
**Signal strength:** Strong -- product vision statement with clear positioning

---

### Finding 2: Product Scope Definition in README.md

**File:** `README.md`
**Lines:** 4-5
**Content:** "It keeps product direction as plain markdown files in your repo (VISION, CUSTOMER, ROADMAP, BACKLOG) and feeds shaped ideas directly into the claude-workflow SDD pipeline. Where temper governs engineering maturity, arc governs what gets built and why."
**Classification:** VISION
**Signal strength:** Strong -- value proposition and scope boundaries

---

### Finding 3: Idea Lifecycle Description in README.md

**File:** `README.md`
**Lines:** 7-33
**Content:** Mermaid state diagram and 4-stage lifecycle table (Capture > Shape > Spec-Ready > Shipped)
**Classification:** VISION (operational model)
**Signal strength:** Strong -- core product model definition

---

### Finding 4: Two-Plugin Pipeline Description in README.md

**File:** `README.md`
**Lines:** 49-82
**Content:** Mermaid flowchart showing full arc > temper > claude-workflow pipeline with all 7 arc skills, 3 CW skills, 2 temper skills.
**Classification:** VISION (architecture/pipeline)
**Signal strength:** Strong -- strategic positioning and integration model

---

### Finding 5: Skill Descriptions (Roadmap of Capabilities) in README.md

**File:** `README.md`
**Lines:** 84-103
**Content:** 7-skill descriptions with one-line summaries covering assess, capture, shape, wave, sync, audit, help.
**Classification:** BACKLOG (shipped features)
**Signal strength:** Strong -- these represent shipped capabilities

---

### Finding 6: Target Audience in CLAUDE.md

**File:** `CLAUDE.md`
**Lines:** 1-7
**Content:** "A Claude Code plugin providing /arc-capture, /arc-shape, and /arc-wave skills for product direction and idea lifecycle management. Arc is the upstream companion to temper -- it shapes what gets built before temper governs how it gets built."
**Classification:** VISION
**Signal strength:** Moderate -- abbreviated vision statement

---

### Finding 7: Goals in Spec 01

**File:** `docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md`
**Lines:** 8-14
**Content:** 5 numbered goals: fast idea capture, structured shaping, delivery cycle management, Temper integration, pipeline continuity
**Classification:** VISION
**Signal strength:** Strong -- strategic goals

---

### Finding 8: User Stories in Spec 01

**File:** `docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md`
**Lines:** 16-22
**Content:** 5 user stories covering product owner, tech lead, developer, stakeholder personas
**Classification:** BACKLOG (shipped -- all units implemented) + CUSTOMER (persona references)
**Signal strength:** Strong -- spec-level user stories with persona patterns

---

### Finding 9: Non-Goals in Spec 01

**File:** `docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md`
**Lines:** 172-180
**Content:** 7 non-goals: analytics/dashboards, multi-repo coordination, automated triage, external tool integration, custom labels, team assignment, executable code
**Classification:** BACKLOG (deferred scope)
**Signal strength:** Strong -- explicit future-work candidates

---

### Finding 10: Success Metrics in Spec 01

**File:** `docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md`
**Lines:** 211-219
**Content:** 7 success metrics including "capture in <=3 interactions", "complete spec-ready brief", "Temper constraints visible in wave scope"
**Classification:** VISION (success criteria)
**Signal strength:** Strong -- measurable product goals

---

### Finding 11: Goals in Spec 02

**File:** `docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md`
**Lines:** 8-13
**Content:** 4 goals: error-path coverage, pipeline audit skill, interactive remediation, plugin continuity
**Classification:** VISION (shipped -- /arc-audit exists)
**Signal strength:** Strong

---

### Finding 12: User Stories in Spec 02

**File:** `docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md`
**Lines:** 15-20
**Content:** 4 user stories for product owner, tech lead, developer (audit and error-path scenarios)
**Classification:** BACKLOG (shipped) + CUSTOMER
**Signal strength:** Strong

---

### Finding 13: Non-Goals in Spec 02

**File:** `docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md`
**Lines:** 96-104
**Content:** 6 non-goals: CI/CD pipeline, automated fix application, VISION/CUSTOMER content editing, new templates, backward-incompatible changes
**Classification:** BACKLOG (deferred scope)
**Signal strength:** Strong

---

### Finding 14: Goals in Spec 03 (arc-assess)

**File:** `docs/specs/03-spec-arc-align/03-spec-arc-align.md`
**Lines:** 8-14
**Content:** 5 goals: discover all product-direction content, automatically import as captured stubs, delete original sources, maintain manifest, produce summary report
**Classification:** VISION (shipped -- /arc-assess exists)
**Signal strength:** Strong

---

### Finding 15: User Stories in Spec 03

**File:** `docs/specs/03-spec-arc-align/03-spec-arc-align.md`
**Lines:** 16-20
**Content:** 3 user stories for product owner, developer, team lead (consolidation, TODO migration, idempotent re-runs)
**Classification:** BACKLOG (shipped) + CUSTOMER
**Signal strength:** Strong

---

### Finding 16: Goals in Spec 04 (arc-sync)

**File:** `docs/specs/04-spec-arc-readme/04-spec-arc-readme.md`
**Lines:** 9-17
**Content:** 6 goals: eliminate README drift, scaffold complete README, update mermaid diagrams, WA-7 audit, namespace separation, trust-signal framework
**Classification:** VISION (shipped -- /arc-sync exists)
**Signal strength:** Strong

---

### Finding 17: User Stories in Spec 04

**File:** `docs/specs/04-spec-arc-readme/04-spec-arc-readme.md`
**Lines:** 19-25
**Content:** 5 user stories for product owner, developer, bootstrapper (README sync, staleness detection, trust validation)
**Classification:** BACKLOG (shipped) + CUSTOMER
**Signal strength:** Strong

---

### Finding 18: Goals in Spec 05 (arc-help)

**File:** `docs/specs/05-spec-arc-help/05-spec-arc-help.md`
**Lines:** 8-13
**Content:** 5 goals: single-command help, cover all skills, describe artifacts, installation instructions, link to README
**Classification:** VISION (shipped)
**Signal strength:** Strong

---

### Finding 19: User Stories in Spec 05

**File:** `docs/specs/05-spec-arc-help/05-spec-arc-help.md`
**Lines:** 15-19
**Content:** 3 user stories for new users, existing users, first-time installers
**Classification:** BACKLOG (shipped) + CUSTOMER
**Signal strength:** Strong

---

### Finding 20: Non-Goals in Spec 05

**File:** `docs/specs/05-spec-arc-help/05-spec-arc-help.md`
**Lines:** 57-63
**Content:** 5 non-goals: dynamic content, argument parsing, interactive menus, versioned output, modifying existing skills
**Classification:** BACKLOG (deferred scope)
**Signal strength:** Strong

---

### Finding 21: Goals in Spec 06 (arc-assess enhancement)

**File:** `docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md`
**Lines:** 8-14
**Content:** 5 goals: cw-research subagent pre-scan, spec-directory scanning, source-code comment scanning, analysis artifact, artifact relocation to docs/skill/arc/
**Classification:** VISION (shipped -- enhancements implemented)
**Signal strength:** Strong

---

### Finding 22: User Stories in Spec 06

**File:** `docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md`
**Lines:** 16-22
**Content:** 5 user stories for product owner, developer, team lead, repo maintainer (spec extraction, TODO consolidation, analysis, cw-research, artifact separation)
**Classification:** BACKLOG (shipped) + CUSTOMER
**Signal strength:** Strong

---

### Finding 23: Goals in Spec 07 (capture speedup)

**File:** `docs/specs/07-spec-capture-speedup/07-spec-capture-speedup.md`
**Lines:** 8-13
**Content:** 5 goals: reduce inline capture to 1 prompt, full capture to 2 prompts, combine priority with confirmation, eliminate post-capture menu, preserve data fields
**Classification:** VISION (shipped -- consolidation implemented)
**Signal strength:** Strong

---

### Finding 24: User Stories in Spec 07

**File:** `docs/specs/07-spec-capture-speedup/07-spec-capture-speedup.md`
**Lines:** 15-19
**Content:** 3 user stories for mid-workflow user, inline idea user, free-text user
**Classification:** BACKLOG (shipped) + CUSTOMER
**Signal strength:** Strong

---

### Finding 25: Non-Goals in Spec 07

**File:** `docs/specs/07-spec-capture-speedup/07-spec-capture-speedup.md`
**Lines:** 65-70
**Content:** 5 non-goals: changing backlog format, modifying other skills, batch capture, changing priority levels, modifying template
**Classification:** BACKLOG (deferred scope)
**Signal strength:** Strong

---

### Finding 26: Persona References Across All Specs

**Files:** All 7 spec files
**Content:** Consistent persona patterns across user stories:
- **Product owner** -- appears in specs 01, 02, 03, 04, 06 (5 specs)
- **Tech lead / Team lead** -- appears in specs 01, 02, 03 (3 specs)
- **Developer** -- appears in specs 01, 02, 04, 06 (4 specs)
- **Project stakeholder** -- appears in spec 01 (1 spec)
- **New Arc user / existing user** -- appears in spec 05 (1 spec)
- **Mid-workflow user** -- appears in spec 07 (1 spec)
- **Repo maintainer** -- appears in spec 06 (1 spec)
- **Bootstrapper** -- appears in spec 04 (1 spec)
**Classification:** CUSTOMER
**Signal strength:** Strong -- 4 primary personas with consistent roles across multiple specs

---

### Finding 27: Plugin Description in plugin.json

**File:** `.claude-plugin/plugin.json`
**Lines:** 4
**Content:** "Lightweight product direction for spec-driven development. Capture ideas, shape them into spec-ready briefs, and feed them into the claude-workflow SDD pipeline."
**Classification:** VISION
**Signal strength:** Moderate -- marketing-level description

---

### Finding 28: Plugin Description in marketplace.json

**File:** `.claude-plugin/marketplace.json`
**Lines:** 7-8
**Content:** "Lightweight product direction for spec-driven development. Inspired by Linear's fast capture and clean triage, arc helps shape ideas into spec-ready briefs."
**Classification:** VISION
**Signal strength:** Moderate -- marketplace description with Linear inspiration

---

### Finding 29: Research Report Vision Content

**File:** `docs/specs/01-spec-arc-plugin/research-arc-plugin.md`
**Lines:** 11-23
**Content:** Research summary describing Arc's extraction from Temper, the three-plugin pipeline, idea lifecycle model, and pipeline position. Includes: "Arc was extracted from the Focus/Temper plugin during the temper-split."
**Classification:** VISION (historical context)
**Signal strength:** Moderate -- historical origin story

---

### Finding 30: readme-author Integration Ideas

**File:** `docs/specs/04-spec-arc-readme/research-readme-author-integration.md`
**Lines:** 17-24
**Content:** 5 ranked integration ideas: Arc-managed README sections, new /arc-sync skill, README staleness check, Claude plugin README template, cross-plugin pipeline extension
**Classification:** BACKLOG (3 shipped: managed sections, /arc-sync, WA-7 check; 2 deferred: template contribution, full pipeline extension)
**Signal strength:** Strong -- concrete feature plans, partially implemented

---

### Finding 31: Stale Cross-References (arc-align > arc-assess)

**Files:** `skills/arc-assess/references/detection-patterns.md` (line 752), `skills/arc-assess/references/import-rules.md` (line 543)
**Content:** References to `skills/arc-align/references/import-rules.md` and `skills/arc-align/SKILL.md` -- stale path after rename from `arc-align` to `arc-assess`
**Classification:** N/A (bug -- stale references)
**Signal strength:** N/A

---

### Finding 32: EXAMPLE Content in Detection Patterns and Import Rules

**Files:** `skills/arc-assess/references/detection-patterns.md`, `skills/arc-assess/references/import-rules.md`
**Content:** Extensive example matches showing roadmap entries, todo lists, persona definitions, user stories, feature lists, code comments -- all documentation of what arc-assess detects, not actual product content
**Classification:** N/A (reference documentation, not product-direction content)

---

## Summary

### Project Type

Claude Code plugin -- pure markdown, no executable code. Distributed via Git, installed through Claude CLI plugin system.

### Architecture Patterns

- Plugin-based (SKILL.md skill definitions)
- File-based state machine (BACKLOG.md status transitions)
- Managed section injection (HTML comment markers)
- Phase-graduated templates (7 Temper maturity phases)
- Parallel subagent analysis (4 concurrent dimensions)
- Trust-signal validation (10 structural checks)

### Key Dependencies

- temper (engineering maturity -- read-only integration)
- claude-workflow (SDD pipeline -- brief handoff)
- readme-author (optional -- patterns absorbed into /arc-sync)

### Product-Direction Content Distribution

| Category | Count | Sources |
|----------|-------|---------|
| VISION content | 12 findings | README.md, CLAUDE.md, plugin.json, marketplace.json, all 7 specs, research reports |
| BACKLOG content (shipped) | 7 findings | All 7 spec user stories (all units implemented) |
| BACKLOG content (deferred/non-goals) | 4 findings | Specs 01, 02, 05, 07 non-goals sections |
| BACKLOG content (future work) | 1 finding | readme-author integration ideas (2 unimplemented) |
| CUSTOMER content (personas) | 1 finding | Persona patterns across all 7 specs (4 primary personas) |
| Stale references (bugs) | 1 finding | arc-align > arc-assess rename artifacts |

### Key Gaps

1. **No docs/VISION.md** -- Vision content is scattered across README.md (lines 1-5), CLAUDE.md (lines 1-7), plugin.json, marketplace.json, and 7 spec goals sections. No consolidated vision document exists.
2. **No docs/CUSTOMER.md** -- Four primary personas (Product Owner, Tech Lead, Developer, Stakeholder) appear consistently across specs but are not defined in a dedicated customer document.
3. **No docs/ROADMAP.md** -- No delivery roadmap exists. The 7 completed SDD cycles represent shipped waves but are not tracked in Arc's own roadmap format.
4. **No docs/BACKLOG.md** -- 7 specs worth of user stories (shipped), 22+ non-goals (deferred), and 2 unimplemented integration ideas are not captured in Arc's own backlog.
5. **Stale path references** -- 2 files still reference `skills/arc-align/` instead of `skills/arc-assess/` after the rename.
6. **Arc does not eat its own dog food** -- The plugin defines a complete product-direction management system but does not use it for its own development. Running `/arc-assess` on this repo would consolidate all scattered content into Arc-managed artifacts.

### Recommendations

1. Run `/arc-assess` against this repo to consolidate all product-direction content into `docs/VISION.md`, `docs/CUSTOMER.md`, `docs/BACKLOG.md`, and `docs/ROADMAP.md`.
2. Fix the 2 stale `arc-align` references in detection-patterns.md and import-rules.md.
3. After import, run `/arc-wave` to organize shipped features into completed waves and plan next work.
4. After wave planning, run `/arc-sync` to scaffold a product-direction-aware README for Arc itself.
