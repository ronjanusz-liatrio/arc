# BACKLOG

A triaged list of product ideas. Each idea progresses through the idea lifecycle
(Capture, Shape, Spec-Ready, Shipped) and is stored as a `## {Title}` section below.

| Priority | Label | When to Use |
|----------|-------|-------------|
| P0 | Critical | Blocks current wave or causes user-visible failure |
| P1 | High | Important for current or next wave; significant user impact |
| P2 | Medium | Valuable but not urgent; can wait 1-2 waves |
| P3 | Low | Nice to have; consider if capacity allows |

| Title | Status | Priority | Wave |
|-------|--------|----------|------|
| [(deferred) Multi-repo coordination](#deferred-multi-repo-coordination) | captured | P3-Low | -- |
| [(deferred) Automated triage](#deferred-automated-triage) | captured | P3-Low | -- |
| [(deferred) Proof execution for spec 01](#deferred-proof-execution-for-spec-01) | captured | P3-Low | -- |
| [(deferred) VISION or CUSTOMER content editing](#deferred-vision-or-customer-content-editing) | captured | P3-Low | -- |
| [(deferred) ROADMAP artifact population via assess](#deferred-roadmap-artifact-population-via-assess) | captured | P3-Low | -- |
| [(deferred) Automatic wave assignment](#deferred-automatic-wave-assignment) | captured | P3-Low | -- |
| [(deferred) Interactive research configuration](#deferred-interactive-research-configuration) | captured | P3-Low | -- |
| [(deferred) Batch capture](#deferred-batch-capture) | captured | P3-Low | -- |
| [Add rewrite mode to arc-sync injection prompt](#add-rewrite-mode-to-arc-sync-injection-prompt) | captured | P1-High | -- |
| [Fix stale arc-align path references](#fix-stale-arc-align-path-references) | captured | P2-Medium | -- |
| [(deferred) Triaging remaining captured priorities](#deferred-triaging-remaining-captured-priorities) | captured | P3-Low | -- |
| [(deferred) Creating ROADMAP.md](#deferred-creating-roadmapmd) | captured | P3-Low | -- |
| [(deferred) Modifying CUSTOMER.md](#deferred-modifying-customermd) | captured | P3-Low | -- |
| [(deferred) Running arc-sync to refresh README](#deferred-running-arc-sync-to-refresh-readme) | captured | P3-Low | -- |
| [(deferred) Resolving VISION README Linear messaging](#deferred-resolving-vision-readme-linear-messaging) | captured | P3-Low | -- |
| [(deferred) Replacing textual Process steps with diagrams](#deferred-replacing-textual-process-steps-with-diagrams) | captured | P3-Low | -- |
| [(deferred) Modifying README lifecycle or pipeline diagrams](#deferred-modifying-readme-lifecycle-or-pipeline-diagrams) | captured | P3-Low | -- |
| [(deferred) Updating detection-patterns or import-rules references](#deferred-updating-detection-patterns-or-import-rules-references) | captured | P3-Low | -- |
| [Remove time estimates from arc-wave](#remove-time-estimates-from-arc-wave) | captured | P1-High | -- |

## (deferred) Multi-repo coordination

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:173-180 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->

Arc manages a single BACKLOG per repository

## (deferred) Automated triage

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:173-180 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->

Arc is for intentional product thinking, not AI-automated prioritization

## (deferred) Proof execution for spec 01

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md:98-103 -->
<!-- aligned-from-spec: 02-spec-arc-plugin-enhancement -->

Proofs of the original spec are tracked separately

## (deferred) VISION or CUSTOMER content editing

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md:98-103 -->
<!-- aligned-from-spec: 02-spec-arc-plugin-enhancement -->

Review reports on their state but never modifies their content

## (deferred) ROADMAP artifact population via assess

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md:176-183 -->
<!-- aligned-from-spec: 06-spec-arc-align-enhance -->

The analysis flags ROADMAP gaps but arc-assess does not create or populate docs/ROADMAP.md

## (deferred) Automatic wave assignment

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md:176-183 -->
<!-- aligned-from-spec: 06-spec-arc-align-enhance -->

Theme analysis suggests wave groupings but does not assign items to waves

## (deferred) Interactive research configuration

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md:176-183 -->
<!-- aligned-from-spec: 06-spec-arc-align-enhance -->

The cw-research subagent runs with a standard prompt; custom research dimensions are not configurable

## (deferred) Batch capture

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: docs/specs/07-spec-capture-speedup/07-spec-capture-speedup.md:66-70 -->
<!-- aligned-from-spec: 07-spec-capture-speedup -->

Adding batch capture (multiple ideas at once)

## Add rewrite mode to arc-sync injection prompt

- **Status:** captured
- **Priority:** P1-High
- **Captured:** 2026-04-12T19:15:00Z

When arc-sync detects injection mode (existing README without ARC: markers), offer a "Rewrite" option that reads the existing README holistically, re-homes content into ARC:/TEMPER: managed sections, previews the diff, and validates trust signals — existing prose is relocated, never deleted.

## Fix stale arc-align path references

- **Status:** captured
- **Priority:** P2-Medium
- **Captured:** 2026-04-13T00:10:00Z
- **Context:** Surfaced during /arc-assess research pass on 2026-04-13.

Two reference files still point to the pre-rename `skills/arc-align/` path instead of `skills/arc-assess/`: `skills/arc-assess/references/detection-patterns.md:752` and `skills/arc-assess/references/import-rules.md:543`. Fix both references and grep for any other stragglers.

## (deferred) Triaging remaining captured priorities

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-13T00:00:00Z
<!-- aligned-from: docs/specs/08-spec-backlog-consistency/08-spec-backlog-consistency.md:114 -->
<!-- aligned-from-spec: 08-spec-backlog-consistency -->

Triaging priorities on the remaining captured items (all stay at their current P2/P3).

## (deferred) Creating ROADMAP.md

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-13T00:00:00Z
<!-- aligned-from: docs/specs/08-spec-backlog-consistency/08-spec-backlog-consistency.md:115 -->
<!-- aligned-from-spec: 08-spec-backlog-consistency -->

Creating ROADMAP.md or populating the `ARC:roadmap` section.

## (deferred) Modifying CUSTOMER.md

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-13T00:00:00Z
<!-- aligned-from: docs/specs/08-spec-backlog-consistency/08-spec-backlog-consistency.md:116 -->
<!-- aligned-from-spec: 08-spec-backlog-consistency -->

Modifying CUSTOMER.md as part of backlog consistency cleanup.

## (deferred) Running arc-sync to refresh README

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-13T00:00:00Z
<!-- aligned-from: docs/specs/08-spec-backlog-consistency/08-spec-backlog-consistency.md:117 -->
<!-- aligned-from-spec: 08-spec-backlog-consistency -->

Running `/arc-sync` to refresh other README sections (can be done separately).

## (deferred) Resolving VISION README Linear messaging

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-13T00:00:00Z
<!-- aligned-from: docs/specs/08-spec-backlog-consistency/08-spec-backlog-consistency.md:118 -->
<!-- aligned-from-spec: 08-spec-backlog-consistency -->

Resolving the VISION/README "Linear inspiration" messaging difference (editorial choice).

## (deferred) Replacing textual Process steps with diagrams

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-13T00:00:00Z
<!-- aligned-from: docs/specs/09-spec-command-walkthrough-diagrams/09-spec-command-walkthrough-diagrams.md:78 -->
<!-- aligned-from-spec: 09-spec-command-walkthrough-diagrams -->

Replacing existing textual Process steps with diagrams — the walkthrough is additive.

## (deferred) Modifying README lifecycle or pipeline diagrams

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-13T00:00:00Z
<!-- aligned-from: docs/specs/09-spec-command-walkthrough-diagrams/09-spec-command-walkthrough-diagrams.md:82 -->
<!-- aligned-from-spec: 09-spec-command-walkthrough-diagrams -->

Modifying the README.md lifecycle or pipeline diagrams.

## (deferred) Updating detection-patterns or import-rules references

- **Status:** captured
- **Priority:** P3-Low
- **Captured:** 2026-04-13T00:00:00Z
<!-- aligned-from: docs/specs/01-spec-align-ignore-dirs/01-spec-align-ignore-dirs.md:62 -->
<!-- aligned-from-spec: 01-spec-align-ignore-dirs -->

Updating the detection-patterns.md or import-rules.md references (they don't enumerate the full hardcoded list).

## Remove time estimates from arc-wave

- **Status:** captured
- **Priority:** P1-High
- **Captured:** 2026-04-14T00:00:00Z

Strip time/effort estimates from the arc-wave workflow to simplify wave planning.

