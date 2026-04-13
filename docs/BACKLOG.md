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
| [/arc-assess skill](#arc-assess-skill) | shipped | P2-Medium | Wave 0: Bootstrap |
| [/arc-capture skill](#arc-capture-skill) | shipped | P2-Medium | Wave 0: Bootstrap |
| [/arc-shape skill](#arc-shape-skill) | shipped | P2-Medium | Wave 0: Bootstrap |
| [/arc-wave skill](#arc-wave-skill) | shipped | P2-Medium | Wave 0: Bootstrap |
| [/arc-sync skill](#arc-sync-skill) | shipped | P2-Medium | Wave 0: Bootstrap |
| [/arc-audit skill](#arc-audit-skill) | shipped | P2-Medium | Wave 0: Bootstrap |
| [/arc-help skill](#arc-help-skill) | shipped | P2-Medium | Wave 0: Bootstrap |
| [Add rewrite mode to arc-sync injection prompt](#add-rewrite-mode-to-arc-sync-injection-prompt) | captured | P1-High | -- |
| [/arc-ship skill](#arc-ship-skill) | captured | P1-High | -- |
| [Fix stale arc-align path references](#fix-stale-arc-align-path-references) | captured | P2-Medium | -- |
| [Classify shipped-spec user stories as merge candidates in arc-assess](#classify-shipped-spec-user-stories-as-merge-candidates-in-arc-assess) | captured | P2-Medium | -- |
| [(deferred) Triaging remaining captured priorities](#deferred-triaging-remaining-captured-priorities) | captured | P3-Low | -- |
| [(deferred) Creating ROADMAP.md](#deferred-creating-roadmapmd) | captured | P3-Low | -- |
| [(deferred) Modifying CUSTOMER.md](#deferred-modifying-customermd) | captured | P3-Low | -- |
| [(deferred) Running arc-sync to refresh README](#deferred-running-arc-sync-to-refresh-readme) | captured | P3-Low | -- |
| [(deferred) Resolving VISION README Linear messaging](#deferred-resolving-vision-readme-linear-messaging) | captured | P3-Low | -- |
| [(deferred) Replacing textual Process steps with diagrams](#deferred-replacing-textual-process-steps-with-diagrams) | captured | P3-Low | -- |
| [(deferred) Modifying README lifecycle or pipeline diagrams](#deferred-modifying-readme-lifecycle-or-pipeline-diagrams) | captured | P3-Low | -- |
| [(deferred) Updating detection-patterns or import-rules references](#deferred-updating-detection-patterns-or-import-rules-references) | captured | P3-Low | -- |

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

## /arc-assess skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Wave:** Wave 0: Bootstrap
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: README.md:96-102 -->

Codebase discovery and migration. Scans the project for scattered product-direction content and imports them into Arc-managed artifacts.

### User Stories

<!-- aligned-from: docs/specs/03-spec-arc-align/03-spec-arc-align.md:17-19 -->
<!-- aligned-from-spec: 03-spec-arc-align -->
- As a product owner adopting Arc on an existing project, I want to consolidate scattered roadmap and backlog content into Arc's managed artifacts so that /arc-audit audits the full picture.

<!-- aligned-from: docs/specs/03-spec-arc-align/03-spec-arc-align.md:17-19 -->
<!-- aligned-from-spec: 03-spec-arc-align -->
- As a developer who has been tracking TODOs in README files, I want those items migrated into docs/BACKLOG.md as captured stubs so they enter the idea lifecycle.

<!-- aligned-from: docs/specs/03-spec-arc-align/03-spec-arc-align.md:17-19 -->
<!-- aligned-from-spec: 03-spec-arc-align -->
- As a team lead, I want confidence that running /arc-assess twice doesn't create duplicate entries so that the migration is safe to re-run after adding new content.

<!-- aligned-from: docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md:17-21 -->
<!-- aligned-from-spec: 06-spec-arc-align-enhance -->
- As a product owner adopting Arc on a mature repo with existing specs, I want arc-assess to extract product-direction content from those specs so I don't manually re-enter goals and user stories into Arc artifacts.

<!-- aligned-from: docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md:17-21 -->
<!-- aligned-from-spec: 06-spec-arc-align-enhance -->
- As a developer with scattered TODO/FIXME comments in source code, I want arc-assess to consolidate those into BACKLOG stubs so they enter the idea lifecycle alongside markdown-based discoveries.

<!-- aligned-from: docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md:17-21 -->
<!-- aligned-from-spec: 06-spec-arc-align-enhance -->
- As a team lead running arc-assess for the first time, I want to see an analysis of what the codebase has vs. what it lacks so I can make informed decisions about what to import and what to create manually.

<!-- aligned-from: docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md:17-21 -->
<!-- aligned-from-spec: 06-spec-arc-align-enhance -->
- As a developer on an unfamiliar codebase, I want arc-assess to leverage cw-research's deep exploration so the analysis is grounded in architecture and conventions, not just keyword matches.

<!-- aligned-from: docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md:17-21 -->
<!-- aligned-from-spec: 06-spec-arc-align-enhance -->
- As a repo maintainer, I want Arc's internal reports and manifests stored separately from my product-direction artifacts so that docs/ isn't cluttered with operational files that only Arc reads.

## /arc-capture skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Wave:** Wave 0: Bootstrap
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: README.md:96-102 -->

Fast idea entry. Appends a structured stub to BACKLOG with minimal friction.

### User Stories

<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:17-21 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->
- As a product owner, I want to capture ideas quickly so that I don't lose thoughts while context-switching

<!-- aligned-from: docs/specs/07-spec-capture-speedup/07-spec-capture-speedup.md:17-19 -->
<!-- aligned-from-spec: 07-spec-capture-speedup -->
- As a user running /arc-capture mid-workflow, I want the idea recorded in one prompt so I can return to what I was doing without losing context.

<!-- aligned-from: docs/specs/07-spec-capture-speedup/07-spec-capture-speedup.md:17-19 -->
<!-- aligned-from-spec: 07-spec-capture-speedup -->
- As a user providing an idea inline, I want to confirm what was parsed and set priority in a single interaction.

<!-- aligned-from: docs/specs/07-spec-capture-speedup/07-spec-capture-speedup.md:17-19 -->
<!-- aligned-from-spec: 07-spec-capture-speedup -->
- As a user running /arc-capture without an inline idea, I want to describe my idea once in free text and then confirm + prioritize.

## /arc-shape skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Wave:** Wave 0: Bootstrap
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: README.md:96-102 -->

Interactive refinement. Turns a captured idea into a spec-ready brief using parallel subagent analysis across four dimensions.

### User Stories

<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:17-21 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->
- As a product owner, I want to refine ideas interactively so that briefs entering the SDD pipeline have clear problem framing, success criteria, and scope boundaries

## /arc-wave skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Wave:** Wave 0: Bootstrap
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: README.md:96-102 -->

Delivery cycle management. Groups spec-ready ideas into a wave, updates ROADMAP, and prepares the handoff for /cw-spec.

### User Stories

<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:17-21 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->
- As a tech lead, I want to organize spec-ready ideas into delivery waves so that engineering work is sequenced and scoped appropriately

<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:17-21 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->
- As a developer, I want product direction tracked as markdown in the repo so that I can read vision, customer, and roadmap context without leaving the terminal

<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:17-21 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->
- As a project stakeholder, I want the idea pipeline to respect Temper phase constraints so that we don't plan work the project can't absorb

## /arc-sync skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Wave:** Wave 0: Bootstrap
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: README.md:96-102 -->

README synchronization. Scaffolds a complete README from Arc artifacts or selectively updates ARC: managed sections.

### User Stories

<!-- aligned-from: docs/specs/04-spec-arc-readme/04-spec-arc-readme.md:20-24 -->
<!-- aligned-from-spec: 04-spec-arc-readme -->
- As a product owner, I want the README features section to reflect shipped BACKLOG items so that the README stays current without manual editing

<!-- aligned-from: docs/specs/04-spec-arc-readme/04-spec-arc-readme.md:20-24 -->
<!-- aligned-from-spec: 04-spec-arc-readme -->
- As a developer onboarding to a project, I want the README to show the current wave and roadmap so I understand where the project is headed

<!-- aligned-from: docs/specs/04-spec-arc-readme/04-spec-arc-readme.md:20-24 -->
<!-- aligned-from-spec: 04-spec-arc-readme -->
- As a project bootstrapper, I want /arc-sync to scaffold a complete README from my VISION and CUSTOMER docs so I don't start from a blank file

<!-- aligned-from: docs/specs/04-spec-arc-readme/04-spec-arc-readme.md:20-24 -->
<!-- aligned-from-spec: 04-spec-arc-readme -->
- As a product owner, I want structural validation that my README communicates trust without requiring subjective prose review

## /arc-audit skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Wave:** Wave 0: Bootstrap
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: README.md:96-102 -->

Pipeline health audit. Checks backlog health, wave alignment, and cross-reference integrity across all product artifacts.

### User Stories

<!-- aligned-from: docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md:16-19 -->
<!-- aligned-from-spec: 02-spec-arc-plugin-enhancement -->
- As a product owner, I want to audit my backlog health so that I can identify stale ideas, priority imbalances, and gaps before planning the next wave

<!-- aligned-from: docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md:16-19 -->
<!-- aligned-from-spec: 02-spec-arc-plugin-enhancement -->
- As a tech lead, I want to verify cross-reference integrity between BACKLOG, ROADMAP, VISION, and CUSTOMER so that broken links don't silently degrade product context

<!-- aligned-from: docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md:16-19 -->
<!-- aligned-from-spec: 02-spec-arc-plugin-enhancement -->
- As a developer, I want error-path scenarios documented so that skill behavior under edge cases is explicit and testable

<!-- aligned-from: docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md:16-19 -->
<!-- aligned-from-spec: 02-spec-arc-plugin-enhancement -->
- As a product owner, I want to fix identified issues interactively during the review so that audit findings become immediate action, not a separate task

<!-- aligned-from: docs/specs/04-spec-arc-readme/04-spec-arc-readme.md:20-24 -->
<!-- aligned-from-spec: 04-spec-arc-readme -->
- As a product owner running /arc-audit, I want to be warned when Arc-managed README sections are stale or structurally incomplete so I can run /arc-sync to fix it

## /arc-help skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Wave:** Wave 0: Bootstrap
- **Captured:** 2026-04-12T18:00:00Z
<!-- aligned-from: README.md:96-102 -->

Quick reference guide. Displays an overview of all Arc skills, artifacts, workflow order, and installation instructions.

### User Stories

<!-- aligned-from: docs/specs/05-spec-arc-help/05-spec-arc-help.md:17-19 -->
<!-- aligned-from-spec: 05-spec-arc-help -->
- As a new Arc user, I want to run /arc-help so that I can quickly understand what skills are available and how they fit together

<!-- aligned-from: docs/specs/05-spec-arc-help/05-spec-arc-help.md:17-19 -->
<!-- aligned-from-spec: 05-spec-arc-help -->
- As an existing Arc user, I want a quick reference so that I can recall the workflow order and artifact purposes without leaving the terminal

<!-- aligned-from: docs/specs/05-spec-arc-help/05-spec-arc-help.md:17-19 -->
<!-- aligned-from-spec: 05-spec-arc-help -->
- As a user installing Arc for the first time, I want to see install instructions so that I can set up Arc and its companion plugins correctly

## Add rewrite mode to arc-sync injection prompt

- **Status:** captured
- **Priority:** P1-High
- **Captured:** 2026-04-12T19:15:00Z

When arc-sync detects injection mode (existing README without ARC: markers), offer a "Rewrite" option that reads the existing README holistically, re-homes content into ARC:/TEMPER: managed sections, previews the diff, and validates trust signals — existing prose is relocated, never deleted.

## /arc-ship skill

- **Status:** captured
- **Priority:** P1-High
- **Captured:** 2026-04-13T00:00:00Z
- **Context:** Raised after spec 09 (walkthrough diagrams) shipped — shipped state is currently updated manually in BACKLOG, creating drift risk.

New skill to mark in-progress ideas as `shipped` in docs/BACKLOG.md after verifying corresponding claude-workflow proof artifacts (cw-validate report, coverage matrix, completed task board entries) — automates the lifecycle transition that closes the loop from `/cw-validate` back to Arc.

## Fix stale arc-align path references

- **Status:** captured
- **Priority:** P2-Medium
- **Captured:** 2026-04-13T00:10:00Z
- **Context:** Surfaced during /arc-assess research pass on 2026-04-13.

Two reference files still point to the pre-rename `skills/arc-align/` path instead of `skills/arc-assess/`: `skills/arc-assess/references/detection-patterns.md:752` and `skills/arc-assess/references/import-rules.md:543`. Fix both references and grep for any other stragglers.

## Classify shipped-spec user stories as merge candidates in arc-assess

- **Status:** captured
- **Priority:** P2-Medium
- **Captured:** 2026-04-13T00:10:00Z
- **Context:** Arc-assess re-run on 2026-04-13 re-surfaced the exact class of duplication that spec 08 was designed to fix. Nine user stories from shipped specs (08, 09, 01-align-ignore-dirs) classified as new `captured` BACKLOG stubs; only a manual user decision prevented the re-duplication.

Enhance `/arc-assess` classification rules to detect when a KW-19 user story originates from a spec with `status: shipped` (via BACKLOG summary table or spec metadata). Instead of creating a new captured stub, flag the story as a merge candidate for the corresponding shipped skill entry's `### User Stories` subsection — automating what spec 08 did manually.

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
