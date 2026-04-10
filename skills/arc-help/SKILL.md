---
name: arc-help
description: "Quick reference guide — overview of all Arc skills, artifacts, workflow, and installation"
user-invocable: true
allowed-tools: []
---

# /arc-help — Quick Reference Guide

## Context Marker

Always begin your response with: **ARC-HELP**

## Overview

Arc is a Claude Code plugin for lightweight product direction. It manages the idea lifecycle from raw thought to spec-ready brief, keeping product direction as plain markdown files in your repo (`VISION`, `CUSTOMER`, `ROADMAP`, `BACKLOG`).

Arc is the upstream companion to [temper](https://github.com/ronjanusz-liatrio/temper) (engineering maturity) and [claude-workflow](https://github.com/ronjanusz-liatrio/claude-workflow) (spec-driven development). Arc shapes **what** gets built before temper governs **how** it gets built. Shaped ideas flow from Arc into the claude-workflow SDD pipeline (`/cw-spec` -> `/cw-plan` -> `/cw-dispatch`).

## Skills

Arc provides seven skills for managing the product idea lifecycle:

| Skill | Description | Invocation |
|-------|-------------|------------|
| `/arc-assess` | Codebase discovery and migration -- scan for scattered product-direction content and import into Arc artifacts | `/arc-assess` |
| `/arc-capture` | Fast idea entry -- record a raw idea to the backlog in under 30 seconds | `/arc-capture` |
| `/arc-shape` | Interactive refinement -- transform a captured idea into a spec-ready brief using parallel analysis | `/arc-shape` or `/arc-shape "Idea Title"` |
| `/arc-wave` | Delivery cycle management -- group shaped ideas into a wave and hand off to the SDD pipeline | `/arc-wave` |
| `/arc-sync` | README synchronization -- scaffold or update README.md with sections synced to product direction | `/arc-sync` |
| `/arc-audit` | Pipeline health audit -- check backlog health, wave alignment, and cross-reference integrity | `/arc-audit` |
| `/arc-help` | Quick reference guide -- this help output | `/arc-help` |

## Workflow

The recommended skill execution order:

```
/arc-assess -> /arc-capture -> /arc-shape -> /arc-wave -> /arc-sync -> /cw-spec -> /cw-plan -> /cw-dispatch
                                                    ^
                                              /arc-audit (audit at any time)
                                              /arc-help (reference at any time)
```

1. **Align** -- Scan the codebase for scattered product-direction content and import into Arc-managed artifacts
2. **Capture** -- Record ideas quickly as they come to mind
3. **Shape** -- Refine captured ideas into structured briefs with problem framing, customer fit, and scope
4. **Wave** -- Group shaped ideas into themed delivery cycles and hand off to the SDD pipeline
5. **Readme** -- Scaffold or update README.md with sections synced to product direction artifacts

`/arc-audit` and `/arc-help` are utility skills available at any point in the cycle.

## Artifacts

Arc manages four product direction files in your repository:

| Artifact | File Path | Purpose |
|----------|-----------|---------|
| **VISION** | `docs/VISION.md` | Product vision, strategic direction, and north star metrics |
| **CUSTOMER** | `docs/CUSTOMER.md` | Personas, jobs-to-be-done, and success metrics |
| **ROADMAP** | `docs/ROADMAP.md` | Phased delivery plan with themes and milestones |
| **BACKLOG** | `docs/BACKLOG.md` | Triaged idea list with status, priority, and brief summaries |

These files live in your project repo alongside engineering docs -- no separate product tool to sync.

## Installation

### Arc

```bash
# From Git
claude plugin marketplace add https://github.com/ronjanusz-liatrio/arc.git
claude plugin install arc@arc --scope user

# From local filesystem (development)
claude plugin marketplace add /path/to/arc
claude plugin install arc@arc --scope project
```

### Temper (engineering maturity)

```bash
claude plugin marketplace add https://github.com/ronjanusz-liatrio/temper.git
claude plugin install temper@temper --scope user
```

### Claude Workflow (spec-driven development)

```bash
claude plugin marketplace add https://github.com/ronjanusz-liatrio/claude-workflow.git
claude plugin install claude-workflow@claude-workflow --scope user
```

## More Information

See [README.md](../../README.md) for full documentation, lifecycle diagrams, and plugin structure.

## Instructions

When invoked, output the full content of this guide starting from the Overview section. Do not accept arguments -- always display the complete reference.
