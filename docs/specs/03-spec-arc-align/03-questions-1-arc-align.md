# Questions — Round 1: /arc-assess

**Date:** 2026-04-08

## Q1: Scan Scope

**Question:** What patterns should /arc-assess scan for?

**Answer:** Broad scan — keywords (roadmap, backlog, TODO, planned, upcoming) + structural patterns (numbered feature lists, markdown task lists, kanban columns).

## Q2: Import Strategy

**Question:** How should discovered items be imported into Arc's BACKLOG.md?

**Answer:** Capture as stubs. Be as inclusive as possible with consolidating information at the first pass. Wholistically capture as much as we can at first — refining happens after cleanup.

## Q3: Cleanup Strategy

**Question:** What should happen to the original sources after import?

**Answer:** Delete originals after successful import.

## Q4: Artifact Scope

**Question:** Should /arc-assess also discover VISION or CUSTOMER-like content?

**Answer:** Full artifact scan — also detect vision/mission statements and persona/user descriptions for import into VISION.md and CUSTOMER.md.

## Q5: Exclusion Patterns

**Question:** Should /arc-assess exclude certain paths from scanning?

**Answer:** Pre-apply smart defaults (.git, node_modules, vendor, dist, etc.). Run a quick folder/filename scan to identify large directories. Present recommended exclusions for user confirmation and ask for additional excludes. Always exclude Arc-managed files (docs/BACKLOG.md, docs/ROADMAP.md, docs/VISION.md, docs/CUSTOMER.md) from discovery.

## Q6: Idempotency

**Question:** Should /arc-assess be idempotent?

**Answer:** Yes — maintain a manifest (docs/align-manifest.md) tracking source→BACKLOG mappings to prevent duplicate imports.

## Q7: Review UX

**Question:** How should /arc-assess present discovered items before import?

**Answer:** Fully automatic import, then a verbose summary showing what was captured and what was left behind, grouped by logical sections. Show both imported and skipped items.
