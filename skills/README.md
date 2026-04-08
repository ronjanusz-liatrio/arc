# Skills

Arc provides three skills for managing the product idea lifecycle.

| Skill | Description | Invocation |
|-------|-------------|------------|
| [arc-capture](arc-capture/SKILL.md) | Fast idea entry — record a raw idea to the backlog in under 30 seconds | `/arc-capture` |
| [arc-shape](arc-shape/SKILL.md) | Interactive refinement — transform a captured idea into a spec-ready brief using parallel subagent analysis | `/arc-shape` or `/arc-shape "Idea Title"` |
| [arc-wave](arc-wave/SKILL.md) | Delivery cycle management — group shaped ideas into a wave, update the roadmap, and prepare handoff to the SDD pipeline | `/arc-wave` |

## Workflow

```
/arc-capture → /arc-shape → /arc-wave → /cw-spec → /cw-plan → /cw-dispatch
```

1. **Capture** ideas quickly as they come to mind
2. **Shape** captured ideas into structured briefs with problem framing, customer fit, and scope boundaries
3. **Wave** groups shaped ideas into themed delivery cycles and hands off to the SDD pipeline
