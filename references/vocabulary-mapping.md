# Vocabulary Mapping

Explicit mapping between Arc and Temper terminology. These terms exist in different domains and should not be used interchangeably.

## Lifecycle vs Maturity

| Arc (Product Lifecycle) | Temper (Document Maturity) | Relationship |
|------------------------|---------------------------|--------------|
| captured | notes | Different axes — not synonyms |
| shaped | sketch / draft | A shaped idea may reference draft-level artifacts |
| spec-ready | stub / full | Spec-ready ideas feed into Temper-tracked artifacts |
| shipped | full / gate / ongoing | Shipped ideas produce artifacts at mature levels |

These are **different axes**: idea lifecycle tracks product readiness, document maturity tracks artifact completeness. A "shaped" idea does not imply "draft" artifacts — the two progress independently.

## Quality Checks

| Arc Term | Temper Term | Umbrella Term |
|----------|------------|---------------|
| Trust signals | Gates | Quality checks |

- **Trust signals** = product documentation quality checks (README coherence, backlog integrity, wave alignment)
- **Gates** = engineering maturity checkpoints (artifact existence, CI/CD, test coverage, security posture)
- When referring to both systems together, use **"quality checks"**

## Delivery Cycles

| Arc Term | Temper Term | Relationship |
|----------|------------|--------------|
| Wave | Phase | Waves happen within phases |

- **Wave** = a themed batch of spec-ready ideas selected for delivery (Arc's delivery cycle)
- **Phase** = a maturity stage in the project lifecycle: spike → poc → vertical-slice → foundation → mvp → growth → maturity
- Waves happen **within** phases. Multiple waves can occur during a single phase.
- Phase advancement is **orthogonal** to wave completion — completing a wave does not automatically advance the phase.

## Shared Verbs

Arc and Temper use the same three verbs with the same intent but different scope:

| Verb | Arc Command | Temper Command | Shared Intent |
|------|-------------|----------------|---------------|
| assess | `/arc-assess` | `/temper-assess` | Bootstrap / discover existing content |
| sync | `/arc-sync` | `/temper-sync` | Bring documentation up to date |
| audit | `/arc-audit` | `/temper-audit` | Check health and surface issues |
