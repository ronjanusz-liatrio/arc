# Research Report: Arc Codebase — Product-Direction Discovery

**Topic:** Product-direction discovery for `/arc-assess` re-scan (specs 08, 09, 01-align-ignore-dirs)
**Date:** 2026-04-13
**Working Directory:** /Users/ron/dev/arc
**Arc Version:** 0.12.0

---

## Architecture & Module Structure

### Plugin Identity

| Field | Value |
|-------|-------|
| Name | arc |
| Version | 0.12.0 |
| Owner | ronjanusz-liatrio |
| Type | Pure markdown Claude Code plugin (no executable code) |
| Strict mode | true |
| Required companions | temper, claude-workflow |
| Optional companions | readme-author |

### Directory Layout

```
arc/
  .claude-plugin/
    plugin.json                             # Plugin identity: name, version, companions
    marketplace.json                        # Marketplace: owner, metadata, source
  .claude/
    settings.local.json                     # Local dev permissions (gitignored)
  skills/
    README.md                               # Skill directory hub (7 skills listed)
    arc-assess/SKILL.md                     # Codebase discovery and migration (~1400 lines)
      references/
        align-report-template.md            # Alignment report format
        detection-patterns.md               # 22 keyword + 4 structural + 4 code comment patterns
        import-rules.md                     # Classification, stub generation, cleanup, manifest
    arc-capture/SKILL.md                    # Fast idea entry (~155 lines)
    arc-shape/SKILL.md                      # Interactive refinement with parallel subagents (~379 lines)
      references/
        shaping-dimensions.md               # Four analysis dimensions
        brief-validation.md                 # 19-criterion readiness checklist
    arc-wave/SKILL.md                       # Delivery cycle management (~357 lines)
      references/
        wave-report-template.md             # Wave report format
        bootstrap-protocol.md               # ARC: namespace CLAUDE.md injection rules
    arc-sync/SKILL.md                       # README lifecycle management (~762 lines)
      references/
        trust-signals.md                    # 10 structural trust-signal definitions
        readme-mapping.md                   # Artifact-to-section extraction rules
        readme-quality-rules.md             # Quality gates
    arc-audit/SKILL.md                      # Pipeline health audit (~390 lines)
      references/
        audit-dimensions.md                 # 5 backlog health + 10 wave alignment checks
        review-report-template.md           # Report format
    arc-help/SKILL.md                       # Quick reference guide (~112 lines)
  templates/
    VISION.tmpl.md                          # Phase-graduated (Spike-Maturity)
    CUSTOMER.tmpl.md                        # Phase-graduated
    ROADMAP.tmpl.md                         # Phase-graduated
    BACKLOG.tmpl.md                         # Phase-graduated
  references/
    README.md                               # Reference directory hub
    idea-lifecycle.md                       # 4-stage model
    brief-format.md                         # 7-section spec-ready brief specification
    wave-planning.md                        # Wave sizing, precedence, theme grouping
    cross-plugin-contract.md                # What Arc reads from Temper (read-only)
    vocabulary-mapping.md                   # Arc vs Temper terminology disambiguation
  docs/
    BACKLOG.md                              # 42 items (35 deferred-captured, 7 shipped, 2 new P1 captured)
    VISION.md                               # Consolidated vision with aligned-from provenance
    CUSTOMER.md                             # 4 personas extracted from specs
    specs/
      01-spec-arc-plugin/                   # Initial 7-unit plugin spec (v0.2.0)
      02-spec-arc-plugin-enhancement/       # /arc-audit + error-path Gherkin (v0.3.0)
      03-spec-arc-align/                    # /arc-assess codebase discovery (v0.4.0)
      04-spec-arc-readme/                   # /arc-sync README management (v0.5.0)
      05-spec-arc-help/                     # /arc-help quick reference (v0.6.0)
      06-spec-arc-align-enhance/            # arc-assess enhancements (v0.7.0)
      07-spec-capture-speedup/              # Capture flow consolidation (v0.8.0)
      08-spec-backlog-consistency/          # *** NEW — Backlog dedup + VISION cleanup + README fixes
      09-spec-command-walkthrough-diagrams/ # *** NEW — Mermaid walkthroughs for 3 core skills + lint script
      01-spec-align-ignore-dirs/            # *** NEW — Expand arc-assess hardcoded exclusion list
    skill/arc/
      align-manifest.md                     # Import history (93 rows from specs 01-07 + README)
      align-report.md                       # Alignment report from prior run
      align-analysis.md                     # Gap analysis from prior run
    research-align/
      research-align.md                     # This report
  scripts/
    lint-mermaid.sh                         # Mermaid fence validator (spec 09 artifact)
  CLAUDE.md                                 # Project instructions
  README.md                                 # Full project docs with Mermaid diagrams
  .gitignore                                # OS, editor, Claude, Node, Python exclusions
```

### Key Architectural Patterns

1. **Skill-based architecture:** Self-contained SKILL.md files with YAML frontmatter, context marker, critical constraints, numbered process steps, and references.
2. **File-based state machine:** All state in `docs/BACKLOG.md` with status transitions (`captured` > `shaped` > `spec-ready` > `shipped`) and two backward transitions.
3. **Managed section protocol:** HTML comment markers (`<!--# BEGIN ARC:{section} -->` / `<!--# END ARC:{section} -->`) for content injection in CLAUDE.md and README.md.
4. **Phase-graduated templates:** Artifact templates scale across 7 Temper maturity phases.
5. **Parallel subagent analysis:** `/arc-shape` launches 4 concurrent subagents.
6. **Trust-signal framework:** 10 structural signals (TS-1 to TS-10) for README validation.
7. **Audit dimensions:** 5 backlog health checks + 10 wave alignment checks with severity-based ratings.
8. **Mermaid lint infrastructure:** `scripts/lint-mermaid.sh` validates all mermaid fences outside `docs/specs/` (new since spec 09).

---

## Conventions & Naming Patterns

### Spec Numbering

| Spec | Feature | Status |
|------|---------|--------|
| 01 | Initial plugin (7 units) | shipped |
| 02 | /arc-audit + error paths | shipped |
| 03 | /arc-assess discovery | shipped |
| 04 | /arc-sync README management | shipped |
| 05 | /arc-help quick reference | shipped |
| 06 | arc-assess enhancements | shipped |
| 07 | Capture speedup | shipped |
| 08 | Backlog consistency cleanup | shipped |
| 09 | Command walkthrough diagrams | shipped |
| 01-align-ignore-dirs | Exclusion list expansion | shipped (non-sequential numbering) |

### SKILL.md Structure

YAML frontmatter > Context Marker > Overview > Walkthrough (new in spec 09 for capture/shape/wave) > Critical Constraints > Process (numbered steps) > References.

### File Conventions

- Spec directories: `docs/specs/{NN}-spec-{feature}/`
- Spec files: `{NN}-spec-{feature}.md`
- Proof artifacts: `{NN}-proofs/T{NN}-proofs.md`
- Question files: `{NN}-questions-{N}-{feature}.md`
- Lint scripts: `scripts/{tool}.sh` (bash, set -euo pipefail, shellcheck-clean)
- Conventional commits: `type(scope): description`

### Branding

Liatrio brand in Mermaid diagrams: teal `#11B5A4`, orange `#E8662F`, navy `#1B2A3D`, font Inter.

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

Arc > Temper access is strictly read-only. Arc never creates, modifies, or deletes Temper-managed artifacts. See `references/cross-plugin-contract.md` for the full read matrix.

---

## Product-Direction Content Findings

### What the Prior Scan Imported

The 2026-04-12 `/arc-assess` run imported content from specs 01-07 and README.md into:
- `docs/VISION.md` — 12 vision blocks with aligned-from provenance
- `docs/CUSTOMER.md` — 4 personas (Product Owner, Developer, Tech Lead, Stakeholder)
- `docs/BACKLOG.md` — 70 stubs (28 user stories, 35 deferred non-goals, 7 shipped skills)

The align-manifest (`docs/skill/arc/align-manifest.md`) has 93 rows, all from specs 01-07 and README.md.

### What the Prior Scan Did Not Cover

The following specs and artifacts are **not in the manifest** and will be new discoveries for a re-scan:

#### Spec 08: Backlog Consistency (`docs/specs/08-spec-backlog-consistency/`)

**Files:**
- `08-spec-backlog-consistency.md`
- `08-questions-1-backlog-consistency.md`
- `01-proofs/T01-proofs.md`, `02-proofs/T02-proofs.md`, `03-proofs/T03-proofs.md`

**Product-direction content:**

| Location | Lines | Classification | Content |
|----------|-------|---------------|---------|
| 08-spec:8-12 | Goals | VISION | 5 goals: eliminate duplicates, enrich shipped entries, Wave 0 retroactive, VISION dedup, README fixes |
| 08-spec:16-18 | User Stories | BACKLOG + CUSTOMER | 3 stories: product owner, developer, reader (BACKLOG dedup, VISION cleanup, README accuracy) |
| 08-spec:112-118 | Non-Goals | BACKLOG (deferred) | 5 items: triage priorities, ROADMAP creation, CUSTOMER modification, arc-sync refresh, VISION/README messaging |

#### Spec 09: Command Walkthrough Diagrams (`docs/specs/09-spec-command-walkthrough-diagrams/`)

**Files:**
- `09-spec-command-walkthrough-diagrams.md`
- `09-proofs/T01.1-proofs.md`, `T01.2-proofs.md`, `T02.1-proofs.md`, `T02.2-proofs.md`, `T02.3-proofs.md`, `T02.4-proofs.md`

**Product-direction content:**

| Location | Lines | Classification | Content |
|----------|-------|---------------|---------|
| 09-spec:9-15 | Goals | VISION | 5 goals: mermaid flowcharts for 3 core skills, placement after Overview, brand consistency, lint script, 15-node limit |
| 09-spec:17-21 | User Stories | BACKLOG + CUSTOMER | 3 stories: new Arc user (visual walkthrough), developer (CI-style lint), product owner (brand polish) |
| 09-spec:75-83 | Non-Goals | BACKLOG (deferred) | 7 items: walkthroughs for sync/audit/assess/help, replacing textual steps, error paths, committed PNGs, CI integration, README diagram changes, Node package.json |

#### Spec 01-align-ignore-dirs (`docs/specs/01-spec-align-ignore-dirs/`)

**Files:**
- `01-spec-align-ignore-dirs.md`
- `01-questions-1-align-ignore-dirs.md`
- `02-proofs/T01-proofs.md`, `T02-proofs.md`

**Product-direction content:**

| Location | Lines | Classification | Content |
|----------|-------|---------------|---------|
| 01-align-ignore-dirs:8-11 | Goals | VISION | 3 goals: expand exclusion list for Python/Rust/Java/JS, consistent 5-location sync, silent behavior |
| 01-align-ignore-dirs:14-17 | User Stories | BACKLOG + CUSTOMER | 3 stories: Python developer, Rust/Java developer, Next.js developer (auto-exclusion) |
| 01-align-ignore-dirs:57-62 | Non-Goals | BACKLOG (deferred) | 4 items: IDE dirs, infra-tool dirs, heuristic changes, detection-patterns update |

#### New BACKLOG Items (Not From Specs)

Two new captured items in `docs/BACKLOG.md` that were **not** imported from specs (created manually post-assess):

| Item | Priority | Source |
|------|----------|--------|
| Add rewrite mode to arc-sync injection prompt | P1-High | Manual capture, 2026-04-12T19:15:00Z |
| /arc-ship skill | P1-High | Manual capture, 2026-04-13T00:00:00Z |

These already exist in BACKLOG.md and do not need import, but they represent active product direction: the /arc-ship skill closes the lifecycle loop from `/cw-validate` back to Arc.

#### New Script Artifact

`scripts/lint-mermaid.sh` — introduced by spec 09. Bash script (shellcheck-clean, set -euo pipefail) that validates mermaid fences via `npx @mermaid-js/mermaid-cli`. Not product-direction content, but is a new build infrastructure artifact.

#### Stale References (Bugs)

Two files still reference `skills/arc-align/` instead of `skills/arc-assess/` after the rename:
- `skills/arc-assess/references/detection-patterns.md:752` — references `skills/arc-align/references/import-rules.md`
- `skills/arc-assess/references/import-rules.md:543` — references `skills/arc-align/SKILL.md`

### Candidate Locations for Re-Scan

The following files contain product-direction content not yet in the align-manifest:

| File | Content Type | Items |
|------|-------------|-------|
| `docs/specs/08-spec-backlog-consistency/08-spec-backlog-consistency.md` | Goals, User Stories, Non-Goals | 5 VISION, 3 BACKLOG+CUSTOMER, 5 deferred BACKLOG |
| `docs/specs/09-spec-command-walkthrough-diagrams/09-spec-command-walkthrough-diagrams.md` | Goals, User Stories, Non-Goals | 5 VISION, 3 BACKLOG+CUSTOMER, 7 deferred BACKLOG |
| `docs/specs/01-spec-align-ignore-dirs/01-spec-align-ignore-dirs.md` | Goals, User Stories, Non-Goals | 3 VISION, 3 BACKLOG+CUSTOMER, 4 deferred BACKLOG |
| `docs/BACKLOG.md` (lines 606-622) | Manual captures | 2 new P1-High items (already in BACKLOG, no import needed) |

**Expected new manifest rows:** ~38 total (13 VISION blocks + 9 BACKLOG user stories + 16 deferred BACKLOG non-goals + 3 CUSTOMER persona refs from 3 new specs minus items already in BACKLOG).

---

## Summary

### project_type

Claude Code plugin — pure markdown, no executable code. Distributed via Git, installed through Claude CLI plugin system.

### architecture_patterns

- Plugin-based (SKILL.md skill definitions)
- File-based state machine (BACKLOG.md status transitions)
- Managed section injection (HTML comment markers)
- Phase-graduated templates (7 Temper maturity phases)
- Parallel subagent analysis (4 concurrent dimensions)
- Trust-signal validation (10 structural checks)
- Mermaid lint infrastructure (scripts/lint-mermaid.sh)

### key_dependencies

- temper (engineering maturity — read-only integration)
- claude-workflow (SDD pipeline — brief handoff)
- readme-author (optional — patterns absorbed into /arc-sync)
- @mermaid-js/mermaid-cli (dev-only — lint script via npx)

### product_direction_signals

- Goals in spec 08 (backlog consistency: dedup, Wave 0 assignment, VISION/README cleanup)
- Goals in spec 09 (walkthrough diagrams: visual flowcharts for 3 core skills, mermaid lint)
- Goals in 01-align-ignore-dirs (exclusion list expansion for Python/Rust/Java/JS)
- User stories in specs 08, 09, 01-align-ignore-dirs (9 new stories with 3 new persona references)
- Non-goals in specs 08, 09, 01-align-ignore-dirs (16 new deferred items)
- New P1-High captured ideas: /arc-ship skill (lifecycle close), arc-sync rewrite mode
- Stale references: 2 files reference old arc-align path
