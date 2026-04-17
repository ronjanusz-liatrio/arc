# Clarifying Questions — Round 1

## Q1. When no time estimate is captured, how should the `Target:` field render in ROADMAP.md and the wave report?

**Answer:** Show `TBD (use /arc-wave to add)` — placeholder that hints at the action to capture one.

## Q2. How should the reminder appear after the wave is created?

**Answer:** Plain-text note in summary only — a one-line inline tip, no prompt, no action.

## Q3. Should existing waves that already have a Target timeframe be left untouched, or should the spec include a back-compat rule?

**Answer:** Leave existing waves untouched — the new default applies only to newly created waves.

## Q4. Should the `Target timeframe?` question be fully removed from Step 4, or kept as an opt-in user-invocable prompt?

**Answer:** Remove from Step 4 by default — the question disappears from the default flow; the reminder in Step 11 is the only path to capture one.
