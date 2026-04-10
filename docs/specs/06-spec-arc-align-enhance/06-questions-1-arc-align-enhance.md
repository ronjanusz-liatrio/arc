# Clarifying Questions — Round 1

## Feature: arc-assess Enhancement (Spec Scanning, Analysis Phase, cw-research Integration)

### Context
The current arc-assess skill scans for scattered product-direction content (keywords + structural patterns in markdown files) and imports into BACKLOG/VISION/CUSTOMER. The user wants three enhancements:

1. **Spec scanning** — Scan `docs/specs/` (currently hardcoded-excluded) to extract product-direction content from existing specifications
2. **Analysis/thinking phase** — After discovery but before user prompts, synthesize findings into intelligent suggestions
3. **cw-research integration** — Use deeper codebase exploration (grep through code, not just markdown) to inform the analysis

### Questions

1. **Spec scanning scope:** What should be extracted from specs? (backlog items from non-goals/open questions, vision from goals/overview, customer from user stories?)
2. **Analysis phase output:** Should the "thinking" produce a written analysis artifact, or just inline recommendations before the import prompt?
3. **cw-research integration:** Should arc-assess invoke cw-research as a subagent, or borrow its exploration patterns (grep through code comments, README, etc.) directly?
4. **Code scanning:** Should arc-assess also grep through source code (e.g., TODO comments in `.py`, `.ts`, `.go` files), or stay limited to markdown/text files?
