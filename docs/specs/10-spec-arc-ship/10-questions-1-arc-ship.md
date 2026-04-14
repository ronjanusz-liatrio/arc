# Questions — Round 1: /arc-ship

## Context

The shaped brief in BACKLOG.md specifies requiring a cw-validate report with `**Overall**: PASS` before allowing the shipped transition. However, only 1 of 9 shipped specs (spec 03) has a validation report. The other 8 specs have proof artifacts (`*-proofs.md`) but no `*-validation-*.md` file.

## Questions

1. **Validation report availability**: Only spec 03 has a `*-validation-*.md` file. For future shipping, should /arc-ship strictly require it, or should it accept proof files as a fallback when no validation report exists?
2. **CLAUDE.md product-context update**: When an idea ships, the BACKLOG counts change. Should /arc-ship also refresh the `ARC:product-context` managed section in CLAUDE.md?
3. **Lifecycle reference update**: Should the spec include updating `references/idea-lifecycle.md` to reference `/arc-ship` as the mechanism for the shipped transition?
4. **Walkthrough diagram**: Following the spec-09 pattern, should the new SKILL.md include a `## Walkthrough` mermaid flowchart?
