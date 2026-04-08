# Reference Documentation

This directory contains the authoritative definitions and models used by `/arc-capture`, `/arc-shape`, and `/arc-wave` to manage the idea lifecycle. These are the shared references that all three skills rely on.

## References

| Document | Purpose |
|----------|---------|
| [`idea-lifecycle.md`](idea-lifecycle.md) | Four-stage idea progression (Capture → Shape → Spec-Ready → Shipped) with forward and backward transition rules. |
| [`brief-format.md`](brief-format.md) | Spec-ready brief structure — the exact template, field descriptions, validation checklist, and examples for the artifact consumed by `/cw-spec`. |
| [`wave-planning.md`](wave-planning.md) | Wave organization principles: capacity constraints by Temper phase, precedence rules for idea ordering, theme grouping guidance, and Temper phase compatibility. |

## How They Are Used

### In `/arc-capture`
- **idea-lifecycle.md** — Defines the Capture stage: what fields are required, what status to set, where the idea is stored.

### In `/arc-shape`
- **idea-lifecycle.md** — Defines the Shape stage: entry criteria (status `captured`), exit criteria (all brief fields populated), and backward transition to Capture.
- **brief-format.md** — Provides the target structure for the shaped brief and the validation checklist used to confirm readiness.

### In `/arc-wave`
- **idea-lifecycle.md** — Defines the Spec-Ready stage: entry criteria (status `shaped`), wave assignment, and backward transition to Shape.
- **wave-planning.md** — Guides wave sizing, idea selection, theme coherence, and Temper phase compatibility.
- **brief-format.md** — Referenced when preparing handoff briefs for `/cw-spec`.
