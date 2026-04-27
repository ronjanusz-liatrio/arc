# ARC: Bootstrap Protocol

Rules for injecting and maintaining `ARC:` managed sections in the project CLAUDE.md. This protocol ensures coexistence with Temper's `TEMPER:` namespace and any other managed section namespaces.

## Managed Section Format

### Markers

```html
<!--# BEGIN ARC:product-context -->
{managed content}
<!--# END ARC:product-context -->
```

**Conventions:**
- Markers use HTML comments with `#` prefix: `<!--# BEGIN ... -->` / `<!--# END ... -->`
- Section names are lowercase kebab-case within the `ARC:` namespace
- Content between markers is fully managed — replaced on each update

### ARC:product-context Content

The block content is **static** — a fixed navigation aid pointing to the live source artifacts. It contains no counts, statuses, names, phase, or vision summary. The exact bytes between the BEGIN/END markers are:

```markdown
<!--# BEGIN ARC:product-context -->
## Product Context

For live product status, see the source artifacts. This section intentionally contains no counts, statuses, or names — those drift; the linked files are authoritative.

- [docs/BACKLOG.md](docs/BACKLOG.md) — current ideas with their lifecycle status (captured, shaped, spec-ready, shipped). Read before suggesting new ideas or proposing scope changes.
- [docs/ROADMAP.md](docs/ROADMAP.md) — active and planned waves with goals and targets. Read when deciding what to work on next or to understand the current delivery cycle.
- [docs/VISION.md](docs/VISION.md) — product vision, north-star problem, and strategic boundaries. Read when shaping new ideas or evaluating fit.
- [docs/CUSTOMER.md](docs/CUSTOMER.md) — primary personas and their jobs-to-be-done. Read when scoping a feature or assessing customer fit.
<!--# END ARC:product-context -->
```

## Insertion Algorithm

When injecting `ARC:product-context` into a project's CLAUDE.md:

### 1. Check for Existing Section

Search for `<!--# BEGIN ARC:product-context -->` in the file.

**If found:** Replace everything between the BEGIN and END markers (inclusive of content, exclusive of markers) with updated content. Do not move the section's position.

**If not found:** Insert at the appropriate position per the insertion priority below.

### 2. Insertion Priority

When inserting a new `ARC:product-context` section, choose the first matching position:

1. **Before the first `TEMPER:` section begin marker** — If any `<!--# BEGIN TEMPER:... -->` markers exist, insert before the first one (with one blank line separator). ARC:product-context provides product context that TEMPER sections build upon, so it appears first.
2. **Before the Snyk block** — If a Snyk-related section exists (identifiable by `snyk` or `Snyk` in a marker or heading), insert before it
3. **At EOF** — Append to the end of the file with one blank line separator

### 3. Validate Insertion

After insertion, verify:
- The new section is not nested inside any other managed section
- No other managed section's markers are inside the new section
- The file still parses as valid markdown

## Coexistence Rules

### Namespace Independence

| Rule | Description |
|------|-------------|
| **Never modify** | Do not read, write, or delete content inside `TEMPER:` or `MM:` managed sections |
| **Never nest** | ARC markers must not appear inside TEMPER/MM blocks, and vice versa |
| **Interleave freely** | Independent namespaces can appear in any order in the file |
| **Own namespace only** | `/arc-wave` only manages `ARC:` sections — it does not create, modify, or remove sections in other namespaces |

### Conflict Resolution

If the insertion algorithm detects that the insertion point would place the ARC section inside another namespace's markers:
1. Skip that insertion point
2. Try the next priority position
3. If all positions conflict, append at EOF

### CLAUDE.md Creation

If no CLAUDE.md exists in the project root:
- Do **not** create one solely for ARC sections
- Warn the user: "No CLAUDE.md found. Run `/temper-assess` to bootstrap the project, then re-run `/arc-wave` to inject product context."
- Continue wave creation without CLAUDE.md injection

## Migration and Idempotency

Running the bootstrap protocol replaces **all** content between `<!--# BEGIN ARC:product-context -->` and `<!--# END ARC:product-context -->` with the static template above, regardless of what the prior content was — live counts from a legacy install, an already-migrated static block, hand-edited text, or anything else. Migration and routine writes share one code path: the algorithm always overwrites the marker-bounded region with the current template bytes. There is no "detect legacy format" branch and no opt-in to preserve prior content.

The protocol is idempotent. Because the template is fixed (no derived values, no timestamps, no environment-dependent data), running the protocol twice in succession on the same file produces byte-identical bytes between the marker positions. The first run migrates or refreshes; the second run is a no-op diff.

## Cross-References

- Temper's bootstrap-protocol.md — The original managed section protocol that this document extends
- `references/wave-planning.md` — Wave creation triggers the CLAUDE.md injection
- `references/idea-lifecycle.md` — Status counts in the managed section reflect lifecycle stages
