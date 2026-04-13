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

<!-- aligned-from: docs/specs/08-spec-backlog-consistency/08-spec-backlog-consistency.md:15-19 -->
<!-- aligned-from-spec: 08-spec-backlog-consistency -->

### Reader

Appears in spec 08 as a consumer of the README lifecycle and pipeline diagrams.

**Goals observed in stories:**
- Each capability represented once in the backlog so captured/shipped counts reflect reality
- Clean VISION.md without repeated content blocks
- README lifecycle diagram counts and pipeline labels accurate

<!-- aligned-from: docs/specs/09-spec-command-walkthrough-diagrams/09-spec-command-walkthrough-diagrams.md:17-21 -->
<!-- aligned-from-spec: 09-spec-command-walkthrough-diagrams -->

### New Arc User

Appears in spec 09 as a first-time reader of SKILL.md files.

**Goals observed in stories:**
- Visual walkthrough at the top of each SKILL.md to understand the command's typical flow before reading the full procedure
- CI-style local mermaid lint feedback to avoid shipping broken diagrams (developer sub-goal)
- Consistent Arc brand rendering across every diagram (product owner sub-goal)

<!-- aligned-from: docs/specs/01-spec-align-ignore-dirs/01-spec-align-ignore-dirs.md:13-17 -->
<!-- aligned-from-spec: 01-spec-align-ignore-dirs -->

### Multi-Language Developer Sub-Personas

Appears in spec 01-align-ignore-dirs as three language-specific sub-personas of the Developer.

**Goals observed in stories:**
- Python developer: `.venv/`, `__pycache__/`, and tool caches excluded automatically
- Rust or Java developer: `target/` excluded by default so build output doesn't slow the scan
- Next.js developer: `.next/` excluded automatically so build artifacts aren't scanned
