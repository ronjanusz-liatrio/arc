# Cross-Plugin Contract

What Arc reads from Temper and when. Arc never writes to Temper artifacts — all access is read-only with graceful degradation.

## Temper Artifacts Read by Arc

| Temper Artifact | Read By | Purpose |
|----------------|---------|---------|
| `docs/ARCHITECTURE.md` | `/arc-shape` (feasibility), `/arc-assess` (context) | System boundaries, constraints, technical debt |
| `docs/TESTING.md` | `/arc-shape` (scope boundaries) | Test strategy, what's hard to test |
| `docs/DEPLOYMENT.md` | `/arc-shape` (feasibility), `/arc-wave` (delivery risk) | Deployment complexity, environment count |
| `docs/TECH_STACK.md` | `/arc-shape` (feasibility) | Current stack, framework constraints |
| `docs/skill/temper/management-report.md` | `/arc-wave` (phase-based sizing), `/arc-audit` (combined health) | Current phase and gate status |
| `TEMPER:project-context` in CLAUDE.md | `/arc-wave` (phase, ecosystem) | Phase, ecosystem context |

## Graceful Degradation

All Temper reads are conditional:
- If the file exists, read it for context
- If the file does not exist, proceed without it — Temper may not be installed
- Never error or warn on missing Temper artifacts unless explicitly checking for engineering readiness

## Directionality

Arc → Temper access is strictly **read-only**. Arc never creates, modifies, or deletes Temper-managed artifacts. This ensures both plugins can operate independently and compose without conflict.

## Related Specifications

For marker format and artifact registry details, see:
- `temper/references/marker-specification.md` — HTML comment marker format
- `temper/references/artifact-registry.md` — artifact ownership and maturity definitions
