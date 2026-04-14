# Ship Criteria

Readiness criteria for promoting a spec-ready idea to shipped status via `/arc-ship`. An idea that passes all criteria is eligible for the `spec-ready → shipped` lifecycle transition and will be marked as shipped in `docs/BACKLOG.md`.

## Eligible Statuses

| Status | Eligible to Ship | Reason |
|--------|------------------|--------|
| `spec-ready` | ✓ Yes | Idea has completed the SDD pipeline and is ready for marking as shipped |
| `shaped` | ✗ No | Still in design phase; must be promoted to spec-ready first via `/arc-wave` |
| `captured` | ✗ No | Still in capture phase; must be shaped and spec-ready before shipping |
| `shipped` | ✗ No | Already shipped; no transition required |
| `deferred` | ✗ No | Deferred ideas are not eligible for the current ship operation |

**Error Behavior:** If an idea is not in `spec-ready` status, `/arc-ship` shall report the ineligibility and refuse the transition.

## Proof Verification Rules

### Validation Report Discovery

1. **Required:** A validation report MUST exist in the spec directory matching the pattern `*-validation-*.md`
   - Example: `docs/specs/10-spec-arc-ship/10-validation-arc-ship.md`
   - Example: `docs/specs/08-spec-arc-shape/08-validation-shape.md`

2. **Content Requirement:** The validation report MUST contain a line matching `**Overall**: PASS` (case-sensitive)
   - ✓ Pass: `**Overall**: PASS`
   - ✗ Fail: `**Overall**: FAIL`
   - ✗ Fail: `**Overall**: pass` (case mismatch)

### Verification Procedure

| Step | Action | Tool | Outcome |
|------|--------|------|---------|
| 1 | Resolve spec directory path | Read `- **Spec:**` field from BACKLOG idea detail section | Path to `docs/specs/NN-spec-name/` |
| 2 | Locate validation report | `Glob` pattern: `{spec-dir}/*-validation-*.md` | Single file or none found |
| 3 | Check Overall status | `Grep` for `**Overall**: PASS` in validation report | Match found or not found |

### Failure Scenarios

#### Scenario 1: No Validation Report Found

**Condition:** `Glob {spec-dir}/*-validation-*.md` returns no files

**Response:** Report failure and refuse transition
```
No cw-validate report found in `{spec-dir}/`. Run `/cw-validate` first.
```

**User Action:** Run `/cw-validate` on the spec to generate the validation report, then retry `/arc-ship`.

#### Scenario 2: Validation Report Found But Overall ≠ PASS

**Condition:** Validation report exists but `**Overall**: PASS` is not found (or value is FAIL, BLOCKED, etc.)

**Response:** Report the actual status and refuse transition
```
Validation report found but status is `{actual-status}`, not PASS. Resolve validation failures before shipping.
```

**User Action:** Review the validation report, fix the failing gates, re-run `/cw-validate`, then retry `/arc-ship`.

#### Scenario 3: Spec Field Missing

**Condition:** BACKLOG idea detail section lacks `- **Spec:**` field

**Response:** Prompt user to provide or select the correct spec directory
```
The Spec field is not set for this idea. Please select the correct spec directory:
[List of available spec directories from docs/specs/]
```

**User Action:** Select the correct spec directory from the list. The field will be backfilled during the ship operation.

## BACKLOG Fields Added During Shipping

When an idea is successfully shipped, `/arc-ship` adds or updates the following fields in the BACKLOG idea detail section:

### Summary Table Update

The BACKLOG summary table row for the shipped idea is updated:
- **Status Column:** Changed from `spec-ready` to `shipped`
- **Wave Column:** Preserved (no change)
- **Example:**
  ```
  | Wave 2 | Integrate with Spec Framework | shipped |
  ```

### Detail Section Fields

Three fields are added to the idea's detail markdown section:

#### 1. Spec Field (`- **Spec:**`)

**Populated With:** Spec directory path (e.g., `docs/specs/10-spec-arc-ship/`)

**Timing:** 
- Set by `/arc-wave` at promotion time to `(set during /cw-spec)` (placeholder)
- Updated by `/cw-spec` when spec directory is created (advisory; not enforced)
- Confirmed or backfilled by `/arc-ship` during shipping (required for verification)

**Example:**
```markdown
- **Spec:** docs/specs/10-spec-arc-ship/
```

#### 2. Shipped Timestamp Field (`- **Shipped:**`)

**Populated With:** ISO 8601 timestamp at shipping time (UTC)

**Format:** `YYYY-MM-DDTHH:mm:ssZ`

**Example:**
```markdown
- **Shipped:** 2026-04-13T15:30:45Z
```

#### 3. Status Field (Updated)

**Populated With:** Changed from `spec-ready` to `shipped`

**Example Before:**
```markdown
- **Status:** spec-ready
```

**Example After:**
```markdown
- **Status:** shipped
```

### Complete Detail Section After Shipping

```markdown
### Idea Title

- **Status:** shipped
- **Wave:** 2
- **Spec:** docs/specs/10-spec-arc-ship/
- **Shipped:** 2026-04-13T15:30:45Z
- **Problem:** ...
- **Solution:** ...
- **Success Criteria:** ...
```

## Verification Outcome

**Ship Approved:** All verification steps pass:
1. Idea status is `spec-ready`
2. Spec directory path is resolvable from `- **Spec:**` field (or backfilled by user)
3. Validation report matching `*-validation-*.md` exists
4. Validation report contains `**Overall**: PASS`

**Ship Approved, Partial:** (Batch mode only)
- Some ideas pass verification and are shipped
- Other ideas fail verification and are not shipped
- User is presented with a summary of pass/fail outcomes

**Ship Refused:** One or more verification steps fail:
- Idea is not `spec-ready` status
- No validation report found in spec directory
- Validation report exists but `**Overall**` is not `PASS`
- Spec directory path cannot be resolved

## Common Failure Patterns

| Pattern | Symptom | Fix |
|---------|---------|-----|
| Missing Spec field | `/arc-ship` asks for spec directory selection | User selects from list; field is backfilled |
| Validation not run | "No cw-validate report found" | Run `/cw-validate` on the spec, then retry `/arc-ship` |
| Validation failed | "Validation report found but status is `FAIL`" | Fix the failing gates in the spec, re-run `/cw-validate`, retry `/arc-ship` |
| Wrong spec path | Validation report not found even though it exists | User selects correct spec directory during backfill prompt |
| Status mismatch | "Status is `spec-ready`" but BACKLOG shows `captured` | Promote idea via `/arc-wave` first, then ship |

## Cross-References

- `references/idea-lifecycle.md` — Lifecycle stages and the `spec-ready → shipped` transition
- `references/cross-plugin-contract.md` — Claude-Workflow artifacts that Arc reads
- `docs/BACKLOG.md` — The BACKLOG document format and field definitions
- `docs/specs/NN-spec-name/NN-validation-*.md` — Cw-validate report format and Overall status field
