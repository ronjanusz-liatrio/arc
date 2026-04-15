# Wave Archive

The wave archive stores the complete record of shipped ideas and completed waves. Each completed wave gets its own file at `docs/skill/arc/waves/NN-wave-name.md`, preserving the wave definition and full detail of every idea it delivered.

## Location

```
docs/skill/arc/waves/
├── 00-uncategorized.md     # Fallback for orphaned shipped items
├── 00-bootstrap.md         # Wave 0: Bootstrap
├── 01-lifecycle-closure.md # Wave 1: Lifecycle Closure
├── 02-shaping-intelligence.md
└── ...
```

## File Naming

- **NN** — Zero-padded wave number (two digits).
- **wave-name** — Kebab-case slug derived from the wave name.

### Slug Derivation

1. Lowercase the wave name.
2. Replace spaces with `-`.
3. Strip non-alphanumeric-hyphen characters.
4. Collapse consecutive hyphens into a single hyphen.

**Example:** `Wave 2: Shaping Intelligence` produces `02-shaping-intelligence.md`.

## Archive File Schema

Each archive file follows this structure:

```markdown
# Wave NN: {Name}

- **Theme:** {theme}
- **Goal:** {goal}
- **Target:** {target}
- **Completed:** {ISO 8601 timestamp}

## Shipped Ideas

### {Idea Title}

- **Status:** shipped
- **Priority:** {priority}
- **Captured:** {timestamp}
- **Shaped:** {timestamp}
- **Shipped:** {timestamp}
- **Spec:** {path}
- **Wave:** {wave reference}

#### Problem

{1-3 sentences}

#### Proposed Solution

{1-2 sentences}

#### Success Criteria

- {criterion}

#### Constraints

- {constraint}

#### Assumptions

- {assumption}

#### Open Questions

- {question or "None"}
```

### Field Reference

| Field | Source | Required |
|-------|--------|----------|
| Theme | ROADMAP wave definition | Yes |
| Goal | ROADMAP wave definition | Yes |
| Target | ROADMAP wave definition | Yes |
| Completed | Set by `/arc-ship` (wave completion) or `/arc-sync` (migration) | Yes |
| Status | Always `shipped` | Yes |
| Priority | BACKLOG idea metadata | Yes |
| Captured | BACKLOG idea metadata | Yes |
| Shaped | BACKLOG idea metadata | Yes |
| Shipped | Set by `/arc-ship` at transition time | Yes |
| Spec | Path to the spec that implemented the idea | When available |
| Wave | ROADMAP wave reference | Yes |

## Fallback File

`docs/skill/arc/waves/00-uncategorized.md` collects shipped ideas that cannot be matched to a ROADMAP wave. This happens when:

- The idea's wave field references a wave that no longer exists in ROADMAP.
- The idea has no wave assignment.
- The ROADMAP wave section was already removed (partial migration state).

The uncategorized file uses the same schema but with a synthetic wave header:

```markdown
# Wave 00: Uncategorized

- **Theme:** Orphaned shipped items
- **Goal:** N/A
- **Target:** N/A
- **Completed:** N/A

## Shipped Ideas

### {Idea Title}
...
```

## Lifecycle

### Writers

| Skill | Action |
|-------|--------|
| `/arc-sync` | **Migration:** On each run, scans BACKLOG for `Status: shipped` rows and ROADMAP for `Status: Completed` waves. Creates or updates archive files, removes migrated items from BACKLOG and ROADMAP. |
| `/arc-ship` | **Incremental:** After shipping an idea, appends it to the appropriate archive file and removes it from BACKLOG. When a wave's last idea ships, archives the wave and removes it from ROADMAP. |

### Readers

| Skill | What It Reads |
|-------|---------------|
| `/arc-status` | Counts `### {Title}` subsections across all archive files to derive the Shipped count in the Backlog Snapshot. |
| `/arc-audit` | Reads archive files for status distribution checks (BH-3) and cross-reference integrity (WA-6). Shipped ideas are excluded from BACKLOG-only validations. |
| `/arc-sync` | Reads archive files to populate the `ARC:features` list, lifecycle diagram Shipped count, and trust-signal evaluability (TS-3, TS-6). |

## Idempotency Rules

1. **Migration is idempotent.** Running `/arc-sync` repeatedly after migration produces no writes when no new candidates exist. Detection is based on the presence of `Status: shipped` rows in BACKLOG and `Status: Completed` waves in ROADMAP.
2. **Append is idempotent.** `/arc-ship` checks whether the idea already exists in the target archive file (by matching `### {Title}`) before appending. Duplicate ideas are skipped with a warning.
3. **Wave completion is idempotent.** If a wave archive file already has a `**Completed:**` timestamp, `/arc-ship` does not overwrite it.
4. **Reader tolerance.** If `docs/skill/arc/waves/` does not exist or is empty, all readers treat the Shipped count as `0` and proceed without error.

## Cross-References

- [idea-lifecycle.md](idea-lifecycle.md) — The Shipped stage is terminal; archived ideas are the durable record of that stage.
- [wave-planning.md](wave-planning.md) — Waves are planned in ROADMAP and archived here upon completion.
- [brief-format.md](brief-format.md) — Archive files preserve the full brief fields from the spec-ready brief.
