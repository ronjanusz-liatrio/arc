# T04.5 — scripts/state.sh proof summary

- **Task:** T04.5 (native task #22) — Implement `scripts/state.sh` (state vector emitter)
- **Spec:** `docs/specs/15-spec-agent-utilization-upgrade/15-spec-agent-utilization-upgrade.md` (Unit 4)
- **Feature:** `docs/specs/15-spec-agent-utilization-upgrade/schemas-validators-and-state-predicate.feature`
- **Artifact under test:** `scripts/state.sh`

## What the script does

`scripts/state.sh` emits the current Arc project state vector as JSON on stdout.
It is non-interactive, depends only on `jq` + `awk` (no network, no writes), and
reads only `docs/BACKLOG.md`, `docs/ROADMAP.md`, and
`docs/specs/NN-spec-*/NN-validation-*.md`.

### Output shape

```
{
  "idea_status_counts": {
    "captured":   <int>,
    "shaped":     <int>,
    "spec_ready": <int>,
    "shipped":    <int>
  },
  "wave_active":       <bool>,
  "current_wave":      <string | null>,
  "validation_status": "PASS" | "PENDING" | "FAIL" | "N/A",
  "gaps": [
    { "type": <string>, "idea": <string>, "remediation": <string> }, ...
  ],
  "timestamp": "<ISO 8601 UTC>"
}
```

This shape matches the task's stated fields (`idea_status_counts`, `wave_active`,
`current_wave`, `validation_status`, `gaps`, `timestamp`) and preserves the
semantics defined in `references/skill-orchestration.md` (State Vector section).

### Exit codes

| Code | Meaning |
|------|---------|
| 0 | success |
| 1 | `docs/BACKLOG.md` or `docs/ROADMAP.md` unreadable |

### Gap taxonomy

Gaps are advisory (matching the "descriptive guidance, not enforcement" stance
of `references/skill-orchestration.md`). Three shallow gap types are surfaced:

| Gap type | Trigger | Remediation |
|----------|---------|-------------|
| `shaped_no_spec` | `Status: shaped` idea with no matching `docs/specs/NN-spec-<slug>/` | `write a spec with /cw-spec` |
| `captured_high_pri` | `Status: captured` idea at `P0` or `P1` priority | `shape with /arc-shape` |
| `spec_ready_no_pass` | `Status: spec-ready` idea and no `**Overall**: PASS` validation | `validate with /cw-validate` |

## Proof artifacts

| # | File | Type | Status |
|---|------|------|--------|
| 1 | `T22-01-shellcheck.txt` | cli | PASS |
| 2 | `T22-02-live-run.txt` | cli | PASS |
| 3 | `T22-03-perf-and-exitcodes.txt` | cli | PASS |
| 4 | `T22-04-output-shape.txt` | cli | PASS |

### 1. Static analysis — `T22-01-shellcheck.txt`

Runs `shellcheck --severity=style scripts/state.sh`. Clean at the `style`
level (the strictest severity), so the script is also clean at `warning`,
`info`, and `error` levels.

### 2. Live-repo execution — `T22-02-live-run.txt`

Runs `scripts/state.sh` against the current Arc repository and verifies:

- Exit code 0.
- `idea_status_counts` is a non-null object.
- Keys `captured`, `shaped`, `spec_ready`, `shipped` are all present.
- All four values are of JSON type `number` (integers).

These four checks directly satisfy the feature scenario
"state.sh emits a non-null state vector as JSON".

### 3. Performance & exit codes — `T22-03-perf-and-exitcodes.txt`

Builds a 50-idea synthetic repo in `$TMPDIR` and runs the script three times.
Max wall-clock was **17 ms** in the captured run — 29× under the 500 ms
budget. Then removes BACKLOG (expect exit 1), removes ROADMAP (expect exit
1), and re-creates both (expect exit 0). All three cases pass.

These checks satisfy the feature scenarios "state.sh completes within the
performance budget on a 50-idea repository" and the task's exit-code
requirement.

### 4. Output shape — `T22-04-output-shape.txt`

Exercises the full output surface:

- Fixture 1 (shaped + spec-ready + shipped idea; Active + Planned waves;
  PENDING validation file): all six fields present with the correct types,
  gaps populated for both the `shaped_no_spec` case and the
  `spec_ready_no_pass` case.
- Fixture 2 (no ROADMAP data rows): `wave_active` → `false`, `current_wave`
  → `null`.
- Fixture 3 (FAIL validation): `validation_status` → `"FAIL"` (FAIL dominates
  when any validation file reports it).

Explicit type checks via `jq` confirm:
- `idea_status_counts` is an `object`.
- `wave_active` is a `boolean`.
- `current_wave` is a `string` when a wave exists (and `null` otherwise).
- `validation_status` is a `string`.
- `gaps` is an `array`.
- `timestamp` matches `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$`.

## Cross-reference against task constraints

| Constraint | Evidence |
|------------|----------|
| Emit required JSON fields | `T22-02-live-run.txt`, `T22-04-output-shape.txt` |
| Read-only — BACKLOG, ROADMAP, specs | Source review + `T22-02`; no network calls |
| < 500 ms on 50-idea repo | `T22-03-perf-and-exitcodes.txt` (17 ms max) |
| Exit 0 success, 1 on unreadable BACKLOG/ROADMAP | `T22-03-perf-and-exitcodes.txt` |
| Executable (`chmod 0755`) | `ls -la scripts/state.sh` → `-rwxr-xr-x` |
| ShellCheck clean (severity style) | `T22-01-shellcheck.txt` |
| Non-interactive | No `read` calls; `T22-02` runs with stdin closed |
| Aligns with `references/skill-orchestration.md` state vector | Output preserves `captured/shaped/spec_ready/shipped` counts, `wave_active`, and `validation_status` with matching enums |

## Files created

- `scripts/state.sh` (new, executable)
- `docs/specs/15-spec-agent-utilization-upgrade/04-proofs/T22-01-shellcheck.txt`
- `docs/specs/15-spec-agent-utilization-upgrade/04-proofs/T22-02-live-run.txt`
- `docs/specs/15-spec-agent-utilization-upgrade/04-proofs/T22-03-perf-and-exitcodes.txt`
- `docs/specs/15-spec-agent-utilization-upgrade/04-proofs/T22-04-output-shape.txt`
- `docs/specs/15-spec-agent-utilization-upgrade/04-proofs/T22-proofs.md`
