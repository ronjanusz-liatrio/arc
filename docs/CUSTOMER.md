# CUSTOMER

## Initial Audience Notes

Arc is designed for engineering teams using Claude Code with the Temper + claude-workflow SDD pipeline. It serves anyone involved in product direction — from capturing raw ideas to organizing delivery waves.

## Imported Content

<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:15-21 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->

### Product Owner

Primary persona — appears in 5 of 7 specs (01, 02, 03, 04, 06).

**Goals observed in stories:**
- Capture ideas quickly without losing thoughts while context-switching
- Refine ideas interactively so briefs have clear problem framing, success criteria, and scope boundaries
- Audit backlog health to identify stale ideas, priority imbalances, and gaps before planning
- Fix identified issues interactively during review so findings become immediate action
- Consolidate scattered roadmap and backlog content into Arc's managed artifacts
- Keep README features section reflecting shipped BACKLOG items without manual editing
- Be warned when Arc-managed README sections are stale or structurally incomplete
- Have structural validation that README communicates trust

<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:15-21 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->

### Developer

Appears in 4 of 7 specs (01, 02, 04, 06).

**Goals observed in stories:**
- Product direction tracked as markdown in the repo so context is accessible without leaving the terminal
- Error-path scenarios documented so skill behavior under edge cases is explicit and testable
- README shows the current wave and roadmap for onboarding context
- Scattered TODO/FIXME comments consolidated into BACKLOG stubs entering the idea lifecycle

<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:15-21 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->

### Tech Lead

Appears in 3 of 7 specs (01, 02, 03).

**Goals observed in stories:**
- Organize spec-ready ideas into delivery waves so engineering work is sequenced and scoped appropriately
- Verify cross-reference integrity between BACKLOG, ROADMAP, VISION, and CUSTOMER so broken links don't silently degrade product context
- Confidence that running `/arc-assess` twice doesn't create duplicate entries so migration is safe to re-run

<!-- aligned-from: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md:15-21 -->
<!-- aligned-from-spec: 01-spec-arc-plugin -->

### Project Stakeholder

Appears in 1 spec (01).

**Goals observed in stories:**
- Idea pipeline respects Temper phase constraints so work is not planned beyond what the project can absorb
