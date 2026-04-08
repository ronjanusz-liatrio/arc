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

```markdown
<!--# BEGIN ARC:product-context -->
## Product Context

- **Vision:** {one-line vision summary from docs/VISION.md, or "Not yet defined"}
- **Current Wave:** {wave name from docs/ROADMAP.md, or "No active wave"}
- **Primary Personas:** {comma-separated persona names from docs/CUSTOMER.md, or "Not yet defined"}
- **Backlog:** {N} captured, {N} shaped, {N} spec-ready, {N} shipped
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

1. **After the last `TEMPER:` section end marker** — If any `<!--# END TEMPER:... -->` markers exist, insert after the last one (with one blank line separator)
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
- Warn the user: "No CLAUDE.md found. Run `/temper-incept` to bootstrap the project, then re-run `/arc-wave` to inject product context."
- Continue wave creation without CLAUDE.md injection

## Update Behavior

Each `/arc-wave` invocation updates the `ARC:product-context` section with current values:

| Field | Source | Fallback |
|-------|--------|----------|
| Vision | First sentence of `docs/VISION.md` Summary section | "Not yet defined" |
| Current Wave | Most recent active wave from `docs/ROADMAP.md` | "No active wave" |
| Primary Personas | Primary persona names from `docs/CUSTOMER.md` | "Not yet defined" |
| Backlog | Status counts from `docs/BACKLOG.md` summary table | "0 captured, 0 shaped, 0 spec-ready, 0 shipped" |

The section is idempotent — running `/arc-wave` multiple times produces the same result for the same underlying state.

## Cross-References

- Temper's bootstrap-protocol.md — The original managed section protocol that this document extends
- `references/wave-planning.md` — Wave creation triggers the CLAUDE.md injection
- `references/idea-lifecycle.md` — Status counts in the managed section reflect lifecycle stages
