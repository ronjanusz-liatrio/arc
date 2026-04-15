# ROADMAP

Arc's delivery roadmap organizes spec-ready ideas from the BACKLOG into themed waves. Each wave groups ideas by strategic intent and feeds them into the SDD pipeline via `/cw-spec`.

| Wave | Goal | Status | Target | Ideas |
|------|------|--------|--------|-------|
| Wave 0: Bootstrap | Ship the core Arc skill suite | Completed | -- | 7 |
| Wave 1: Lifecycle Closure | Close the automation loop from cw-validate back to Arc | Completed | 1-2 weeks | 1 |
| Wave 2: Shaping Intelligence | Make arc-shape smarter with external skill awareness | Completed | 1-2 weeks | 1 |

## Wave 0: Bootstrap

**Theme:** Core skill suite
**Goal:** Ship the foundational Arc skills — capture, shape, wave, sync, audit, assess, help
**Target:** --
**Status:** Completed

### Selected Ideas

| Title | Priority | Summary |
|-------|----------|---------|
| [/arc-assess skill](docs/BACKLOG.md#arc-assess-skill) | P2-Medium | Codebase discovery and migration |
| [/arc-capture skill](docs/BACKLOG.md#arc-capture-skill) | P2-Medium | Fast idea entry |
| [/arc-shape skill](docs/BACKLOG.md#arc-shape-skill) | P2-Medium | Interactive idea refinement |
| [/arc-wave skill](docs/BACKLOG.md#arc-wave-skill) | P2-Medium | Delivery cycle management |
| [/arc-sync skill](docs/BACKLOG.md#arc-sync-skill) | P2-Medium | README synchronization |
| [/arc-audit skill](docs/BACKLOG.md#arc-audit-skill) | P2-Medium | Pipeline health audit |
| [/arc-help skill](docs/BACKLOG.md#arc-help-skill) | P2-Medium | Quick reference guide |

### Dependencies

- None — bootstrap wave had no external dependencies

## Wave 1: Lifecycle Closure

**Theme:** Complete the Arc idea lifecycle by automating the shipped transition
**Goal:** Close the automation loop from `/cw-validate` back to Arc by shipping `/arc-ship` — the only unautomated lifecycle transition
**Target:** 1-2 weeks
**Status:** Completed

### Selected Ideas

| Title | Priority | Summary |
|-------|----------|---------|
| [/arc-ship skill](docs/BACKLOG.md#arc-ship-skill) | P1-High | Automates the final lifecycle transition — verifies proof artifacts and marks ideas as shipped |

### Dependencies

- None identified

## Wave 2: Shaping Intelligence

**Theme:** Make arc-shape smarter with external skill awareness
**Goal:** Enrich `/arc-shape`'s feasibility analysis with `/skillz` skill discovery so shaped briefs account for available tooling before entering `/cw-spec`
**Target:** 1-2 weeks
**Status:** Completed

### Selected Ideas

| Title | Priority | Summary |
|-------|----------|---------|
| [Skill discovery via /skillz during shaping](docs/BACKLOG.md#skill-discovery-via-skillz-during-shaping) | P1-High | Enrich feasibility dimension with /skillz marketplace discovery |

### Dependencies

- None identified
