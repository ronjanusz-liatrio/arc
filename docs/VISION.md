# VISION

## Vision Summary

Lightweight product direction for spec-driven development — inspired by Linear's fast capture and clean triage, arc is the upstream companion to temper.

Arc manages the idea lifecycle from raw thought to spec-ready brief. It keeps product direction as plain markdown files in your repo (VISION, CUSTOMER, ROADMAP, BACKLOG) and feeds shaped ideas directly into the claude-workflow SDD pipeline. Where temper governs engineering maturity, arc governs what gets built and why.

## Problem Statement

Projects using the Temper + claude-workflow SDD pipeline lack a structured upstream process for product direction. Ideas enter `/cw-spec` as ad-hoc prompts without consistent problem framing, customer context, success criteria, or scope boundaries. Arc fills this gap with skills that manage product artifacts as markdown files in the repository, producing spec-ready briefs that feed directly into the SDD pipeline.

## Value Proposition

Arc is the upstream companion to Temper — it shapes what gets built before Temper governs how it gets built, feeding spec-ready briefs directly into the claude-workflow SDD pipeline. Arc provides fast idea capture, interactive shaping with parallel subagent analysis, and delivery cycle management that respects Temper phase constraints.

## Imported Content

<!-- aligned-from: README.md:1-5 -->

Lightweight product direction for spec-driven development — inspired by Linear's fast capture and clean triage, arc is the upstream companion to [temper](https://github.com/ronjanusz-liatrio/temper).

Arc manages the idea lifecycle from raw thought to spec-ready brief. It keeps product direction as plain markdown files in your repo (`VISION`, `CUSTOMER`, `ROADMAP`, `BACKLOG`) and feeds shaped ideas directly into the claude-workflow SDD pipeline. Where temper governs engineering maturity, arc governs what gets built and why.

<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:3-5 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->

Arc is a Claude Code plugin that manages the idea lifecycle from raw thought to spec-ready brief. It provides three skills (`/arc-capture`, `/arc-shape`, `/arc-wave`) and four product artifact templates (VISION, CUSTOMER, ROADMAP, BACKLOG) as markdown files tracked in the repository. Arc is the upstream companion to Temper — it shapes what gets built before Temper governs how it gets built, feeding spec-ready briefs directly into the claude-workflow SDD pipeline.

<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:7-13 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->

### Strategic Goals

1. **Fast idea capture** — Record a raw idea in under 30 seconds with `/arc-capture` (title, one-liner, priority → BACKLOG entry)
2. **Structured shaping** — Refine captured ideas into spec-ready briefs via `/arc-shape` using parallel subagent analysis across four dimensions
3. **Delivery cycle management** — Group spec-ready ideas into waves with `/arc-wave`, updating ROADMAP and injecting ARC: managed sections into project CLAUDE.md
4. **Temper integration** — Read Temper's management report when present to inform wave planning scope based on project phase and gate results
5. **Pipeline continuity** — Produce spec-ready briefs in a stable format consumable by `/cw-spec`, completing the arc → claude-workflow → temper pipeline

<!-- aligned-from: docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md:7-12 -->
<!-- aligned-from-spec: 02-spec-arc-plugin-enhancement -->

### Quality and Audit Goals

1. **Error-path coverage** — Add negative and edge-case Gherkin scenarios for `/arc-capture`, `/arc-shape`, and `/arc-wave`
2. **Pipeline audit skill** — Deliver `/arc-audit` for full pipeline health checks
3. **Interactive remediation** — `/arc-audit` produces a diagnostic report and offers to fix identified issues interactively
4. **Plugin continuity** — Update skill directory and README to reflect new capabilities

<!-- aligned-from: docs/specs/03-spec-arc-align/03-spec-arc-align.md:3-5 -->
<!-- aligned-from-spec: 03-spec-arc-align -->

`/arc-assess` is a codebase discovery and migration skill that scans a project for product-direction content scattered outside Arc's managed artifacts — roadmap entries, backlog items, TODO lists, feature plans, vision statements, and persona descriptions — then automatically imports them into `docs/BACKLOG.md`, `docs/VISION.md`, and `docs/CUSTOMER.md`.

<!-- aligned-from: docs/specs/03-spec-arc-align/03-spec-arc-align.md:7-13 -->
<!-- aligned-from-spec: 03-spec-arc-align -->

### Discovery and Migration Goals

1. Discover all product-direction content in a codebase that is not already managed by Arc
2. Automatically import discovered items as captured stubs into the appropriate Arc artifact
3. Delete original sources after successful import to eliminate drift
4. Maintain a manifest that tracks source→artifact mappings for idempotent re-runs
5. Produce a verbose summary report showing what was imported, skipped, and left behind

<!-- aligned-from: docs/specs/04-spec-arc-readme/04-spec-arc-readme.md:3-7 -->
<!-- aligned-from-spec: 04-spec-arc-readme -->

`/arc-sync` keeps project README.md and Arc-relevant diagrams in sync with product direction artifacts. It scaffolds a full README for new projects and selectively injects `ARC:` managed sections into existing READMEs as ideas ship and waves progress. A companion WA-7 audit check flags when Arc-managed README sections are stale or structurally incomplete.

The skill uses a structural trust-signal framework to validate that Arc-managed sections communicate product direction credibility.

<!-- aligned-from: docs/specs/04-spec-arc-readme/04-spec-arc-readme.md:9-16 -->
<!-- aligned-from-spec: 04-spec-arc-readme -->

### README Lifecycle Goals

1. Eliminate README drift by propagating VISION, CUSTOMER, BACKLOG, and ROADMAP data into README managed sections
2. Scaffold a complete README structure for new projects using Arc artifacts as the content source
3. Keep Arc-relevant mermaid diagrams updated with live status counts
4. Add WA-7 README trust-signal audit to `/arc-audit`
5. Maintain clean namespace separation — `/arc-sync` owns `ARC:` sections only
6. Define and enforce a structural trust-signal framework

<!-- aligned-from: docs/specs/05-spec-arc-help/05-spec-arc-help.md:7-13 -->
<!-- aligned-from-spec: 05-spec-arc-help -->

### Quick Reference Goals

1. Give users a single command (`/arc-help`) to understand what Arc does
2. Cover all skills with descriptions and recommended workflow order
3. Describe the four managed artifacts
4. Include installation instructions
5. Link to the full README

<!-- aligned-from: docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md:3-5 -->
<!-- aligned-from-spec: 06-spec-arc-align-enhance -->

Enhance `/arc-assess` with five new capabilities: a cw-research subagent pre-scan, spec-directory scanning, source-code comment scanning, an analysis artifact, and relocation of operational artifacts to `docs/skill/arc/`.

<!-- aligned-from: docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md:7-14 -->
<!-- aligned-from-spec: 06-spec-arc-align-enhance -->

### Assessment Enhancement Goals

1. Invoke `/cw-research` as a subagent before the main scan
2. Scan `docs/specs/` for product-direction content embedded in existing specifications
3. Scan source code files for TODO, FIXME, HACK, and XXX comment markers
4. Generate `docs/skill/arc/align-analysis.md` with structured findings and gap analysis
5. Relocate all Arc operational artifacts from `docs/` to `docs/skill/arc/`

<!-- aligned-from: docs/specs/07-spec-capture-speedup/07-spec-capture-speedup.md:7-13 -->
<!-- aligned-from-spec: 07-spec-capture-speedup -->

### Capture Speedup Goals

1. Reduce inline capture to exactly 1 interactive prompt
2. Reduce full interactive capture to exactly 2 interactive prompts
3. Collect priority as part of the confirmation prompt
4. Eliminate the post-capture "next steps" menu entirely
5. Preserve all existing backlog data fields
