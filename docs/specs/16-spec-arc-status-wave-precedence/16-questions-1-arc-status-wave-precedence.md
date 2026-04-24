# Clarifying Questions — Round 1: arc-status Wave Precedence

## Problem Framing

User reported that `/arc-status` on a project with an active wave recommended
backlog refinement (e.g., `/arc-shape` an unshaped captured idea) instead of
prioritizing the wave. Stated principle:

> "If a wave is being setup/planned/in progress, the priority should be getting
> it defined/started/finished/deleted before trying to make other changes.
> Backlog, docs — those are static things that can exist outside the wave.
> A wave means something is in motion."

## Current Behavior (Step 7 precedence)

1. LG-5 Validation → Shipped  (→ `/arc-ship`)
2. LG-4 Plan → Validation     (→ `/cw-validate`)
3. LG-3 Spec → Plan           (→ `/cw-plan`)
4. LG-2 Shaped → Spec         (→ `/cw-spec`)
5. LG-1 Captured → Shaped (P0/P1 only)  (→ `/arc-shape`)
6. No gaps + wave in progress → `/arc-wave` or `/arc-audit`
7. No gaps + no wave          → `/arc-wave`

Gaps dominate regardless of wave state. Wave state only surfaces when there
are zero gaps anywhere.

## Questions

1. **Wave-linked vs. non-wave gaps** — When an active wave exists, should gaps
   on ideas linked to that wave (`Wave:` field matches) still drive the
   recommendation, while gaps on non-wave ideas are deprioritized?

2. **Wave status vocabulary** — ROADMAP wave statuses are `planned | active`.
   Should the recommendation change based on which?

3. **What "start/finish/delete the wave" means in skill terms** — which
   existing skills handle each wave-level action?

4. **Empty wave (no ideas linked)** — if an active wave exists but has no
   ideas assigned in the backlog, what should the recommendation be?
