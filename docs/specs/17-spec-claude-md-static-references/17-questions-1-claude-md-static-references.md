# 17-questions-1-claude-md-static-references

## Round 1

### Q1: Section type — managed block or plain prose?
**Answer:** Managed block (BEGIN/END markers preserved, content becomes static)

### Q2: Which artifacts should the static block link to?
**Answer:** BACKLOG.md, ROADMAP.md, VISION.md, CUSTOMER.md

### Q3: Should the block include guidance text on WHEN to consult these artifacts?
**Answer:** Yes — short usage hint per link (one-line per link)

### Q4: What should /arc-wave and /arc-ship do with CLAUDE.md?
**Answer:** Migrate-on-detect only — neither skill writes content; only triggered migrators do

### Q5: Which skill performs the migrate-on-detect?
**Answer:** /arc-sync only — /arc-wave and /arc-ship stop touching CLAUDE.md

### Q6: Greenfield projects — should the static block ever be created from scratch?
**Answer:** Yes — /arc-sync injects when CLAUDE.md exists but lacks ARC:product-context

### Q7: Does /arc-shape still read CLAUDE.md?
**Answer:** Yes — unchanged. Cross-plugin TEMPER: reads remain valid; only Arc-owned live status is affected

### Q8: Should the spec dogfood-migrate this repo's CLAUDE.md as proof?
**Answer:** Yes — running /arc-sync against arc/ produces the new static block as a proof artifact
