# T21 Proof Summary — validate-brief.sh + validate-roadmap.sh

**Task:** T04.4: Implement scripts/validate-brief.sh and scripts/validate-roadmap.sh
**Status:** PASS
**Timestamp:** 2026-04-23T10:25:00Z
**Model:** sonnet

## Artifacts Created

| File | Description |
|------|-------------|
| `scripts/validate-brief.sh` | Validates a named idea is shaped and its brief fields are present/schema-valid |
| `scripts/validate-roadmap.sh` | Validates ROADMAP Wave Summary Table rows against schema + BACKLOG cross-references |

## Proof Files

| File | Type | Status | Description |
|------|------|--------|-------------|
| `T21-01-shellcheck.txt` | cli | PASS | Both scripts pass `shellcheck --severity=style` with no diagnostics |
| `T21-02-runtime.txt` | cli | PASS | Runtime behavior verified: empty ROADMAP exits 0; captured/missing ideas exit 1 |

## Verification Summary

- Both scripts are chmod 0755 (executable)
- Both pass ShellCheck at `--severity=style` (no warnings)
- `validate-roadmap.sh docs/ROADMAP.md docs/BACKLOG.md` exits 0 (empty table is valid)
- `validate-brief.sh "Add rewrite mode to arc-sync injection prompt" docs/BACKLOG.md` exits 1 (status=captured, not shaped)
- `validate-brief.sh "Nonexistent Idea" docs/BACKLOG.md` exits 1 (idea not in BACKLOG)
- Exit code contract: 0=pass, 1=fail, 2=recoverable (missing schema/tooling)
- Both scripts are non-interactive and chainable

## Implementation Notes

- `validate-brief.sh` supports two brief forms: JSON code fence (Form B, preferred for schema validation) and prose `- **field:** value` list items (Form A, current BACKLOG format)
- `validate-roadmap.sh` enforces invariant I4 from `references/skill-orchestration.md`: at most 1 Active wave at a time
- Both scripts use the canonical ajv-cli invocation from `references/schema-tooling.md`
- Cross-reference check in `validate-roadmap.sh` emits exit 2 (recoverable) when a wave is in ROADMAP but no BACKLOG ideas are assigned to it
