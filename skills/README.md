# Skills

Arc provides six skills for managing the product idea lifecycle.

| Skill | Description | Invocation |
|-------|-------------|------------|
| [arc-align](arc-align/SKILL.md) | Codebase discovery and migration — scan the project for scattered product-direction content and import into Arc-managed artifacts | `/arc-align` |
| [arc-capture](arc-capture/SKILL.md) | Fast idea entry — record a raw idea to the backlog in under 30 seconds | `/arc-capture` |
| [arc-shape](arc-shape/SKILL.md) | Interactive refinement — transform a captured idea into a spec-ready brief using parallel subagent analysis | `/arc-shape` or `/arc-shape "Idea Title"` |
| [arc-wave](arc-wave/SKILL.md) | Delivery cycle management — group shaped ideas into a wave, update the roadmap, and prepare handoff to the SDD pipeline | `/arc-wave` |
| [arc-readme](arc-readme/SKILL.md) | README lifecycle management — scaffold or update README.md with Arc-managed sections synced to product direction artifacts | `/arc-readme` |
| [arc-review](arc-review/SKILL.md) | Pipeline health audit — check backlog health, wave alignment, and cross-reference integrity across all product artifacts | `/arc-review` |

## Workflow

```
/arc-align → /arc-capture → /arc-shape → /arc-wave → /arc-readme → /cw-spec → /cw-plan → /cw-dispatch
                                                  ↑
                                            /arc-review (audit at any time)
```

1. **Align** scans the codebase for scattered product-direction content and imports it into Arc-managed artifacts
2. **Capture** ideas quickly as they come to mind
3. **Shape** captured ideas into structured briefs with problem framing, customer fit, and scope boundaries
4. **Wave** groups shaped ideas into themed delivery cycles and hands off to the SDD pipeline
5. **Readme** scaffolds or updates README.md with sections synced to product direction artifacts
6. **Review** audits pipeline health at any point in the cycle — check backlog health, wave alignment, and cross-reference integrity
