# Wave 0: Bootstrap

- **Theme:** Core skill suite
- **Goal:** Ship the foundational Arc skills — capture, shape, wave, sync, audit, assess, help
- **Target:** --
- **Completed:** 2026-04-15T00:00:00Z

## Shipped Ideas

### /arc-assess skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Captured:** 2026-04-12T18:00:00Z
- **Wave:** Wave 0: Bootstrap
- **Spec:** docs/specs/06-spec-arc-align-enhance/

Codebase discovery and migration. Scans the project for scattered product-direction content and imports them into Arc-managed artifacts.

#### User Stories

- As a product owner adopting Arc on an existing project, I want to consolidate scattered roadmap and backlog content into Arc's managed artifacts so that /arc-audit audits the full picture.
- As a developer who has been tracking TODOs in README files, I want those items migrated into docs/BACKLOG.md as captured stubs so they enter the idea lifecycle.
- As a team lead, I want confidence that running /arc-assess twice doesn't create duplicate entries so that the migration is safe to re-run after adding new content.
- As a product owner adopting Arc on a mature repo with existing specs, I want arc-assess to extract product-direction content from those specs so I don't manually re-enter goals and user stories into Arc artifacts.
- As a developer with scattered TODO/FIXME comments in source code, I want arc-assess to consolidate those into BACKLOG stubs so they enter the idea lifecycle alongside markdown-based discoveries.
- As a team lead running arc-assess for the first time, I want to see an analysis of what the codebase has vs. what it lacks so I can make informed decisions about what to import and what to create manually.
- As a developer on an unfamiliar codebase, I want arc-assess to leverage cw-research's deep exploration so the analysis is grounded in architecture and conventions, not just keyword matches.
- As a repo maintainer, I want Arc's internal reports and manifests stored separately from my product-direction artifacts so that docs/ isn't cluttered with operational files that only Arc reads.

### /arc-capture skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Captured:** 2026-04-12T18:00:00Z
- **Wave:** Wave 0: Bootstrap
- **Spec:** docs/specs/07-spec-capture-speedup/

Fast idea entry. Appends a structured stub to BACKLOG with minimal friction.

#### User Stories

- As a product owner, I want to capture ideas quickly so that I don't lose thoughts while context-switching
- As a user running /arc-capture mid-workflow, I want the idea recorded in one prompt so I can return to what I was doing without losing context.
- As a user providing an idea inline, I want to confirm what was parsed and set priority in a single interaction.
- As a user running /arc-capture without an inline idea, I want to describe my idea once in free text and then confirm + prioritize.

### /arc-shape skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Captured:** 2026-04-12T18:00:00Z
- **Wave:** Wave 0: Bootstrap
- **Spec:** docs/specs/01-spec-arc-plugin/

Interactive refinement. Turns a captured idea into a spec-ready brief using parallel subagent analysis across four dimensions.

#### User Stories

- As a product owner, I want to refine ideas interactively so that briefs entering the SDD pipeline have clear problem framing, success criteria, and scope boundaries

### /arc-wave skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Captured:** 2026-04-12T18:00:00Z
- **Wave:** Wave 0: Bootstrap
- **Spec:** docs/specs/01-spec-arc-plugin/

Delivery cycle management. Groups spec-ready ideas into a wave, updates ROADMAP, and prepares the handoff for /cw-spec.

#### User Stories

- As a tech lead, I want to organize spec-ready ideas into delivery waves so that engineering work is sequenced and scoped appropriately
- As a developer, I want product direction tracked as markdown in the repo so that I can read vision, customer, and roadmap context without leaving the terminal
- As a project stakeholder, I want the idea pipeline to respect Temper phase constraints so that we don't plan work the project can't absorb

### /arc-sync skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Captured:** 2026-04-12T18:00:00Z
- **Wave:** Wave 0: Bootstrap
- **Spec:** docs/specs/04-spec-arc-readme/

README synchronization. Scaffolds a complete README from Arc artifacts or selectively updates ARC: managed sections.

#### User Stories

- As a product owner, I want the README features section to reflect shipped BACKLOG items so that the README stays current without manual editing
- As a developer onboarding to a project, I want the README to show the current wave and roadmap so I understand where the project is headed
- As a project bootstrapper, I want /arc-sync to scaffold a complete README from my VISION and CUSTOMER docs so I don't start from a blank file
- As a product owner, I want structural validation that my README communicates trust without requiring subjective prose review

### /arc-audit skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Captured:** 2026-04-12T18:00:00Z
- **Wave:** Wave 0: Bootstrap
- **Spec:** docs/specs/02-spec-arc-plugin-enhancement/

Pipeline health audit. Checks backlog health, wave alignment, and cross-reference integrity across all product artifacts.

#### User Stories

- As a product owner, I want to audit my backlog health so that I can identify stale ideas, priority imbalances, and gaps before planning the next wave
- As a tech lead, I want to verify cross-reference integrity between BACKLOG, ROADMAP, VISION, and CUSTOMER so that broken links don't silently degrade product context
- As a developer, I want error-path scenarios documented so that skill behavior under edge cases is explicit and testable
- As a product owner, I want to fix identified issues interactively during the review so that audit findings become immediate action, not a separate task
- As a product owner running /arc-audit, I want to be warned when Arc-managed README sections are stale or structurally incomplete so I can run /arc-sync to fix it

### /arc-help skill

- **Status:** shipped
- **Priority:** P2-Medium
- **Captured:** 2026-04-12T18:00:00Z
- **Wave:** Wave 0: Bootstrap
- **Spec:** docs/specs/05-spec-arc-help/

Quick reference guide. Displays an overview of all Arc skills, artifacts, workflow order, and installation instructions.

#### User Stories

- As a new Arc user, I want to run /arc-help so that I can quickly understand what skills are available and how they fit together
- As an existing Arc user, I want a quick reference so that I can recall the workflow order and artifact purposes without leaving the terminal
- As a user installing Arc for the first time, I want to see install instructions so that I can set up Arc and its companion plugins correctly
