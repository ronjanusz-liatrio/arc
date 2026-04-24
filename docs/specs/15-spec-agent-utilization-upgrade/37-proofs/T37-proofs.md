# T37 Proof Summary — validate-brief.sh empty-array detection fix

## Task
FIX-REVIEW: validate-brief.sh empty-array detection unreachable

## Fix Applied
`scripts/validate-brief.sh` lines 182-185: changed `jq -s '.'` to `jq -s 'map(select(. != ""))'`
for all four array fields (sc, con, ass, oq). This filters the spurious `""` element produced by
`printf '%s\n' ""` when the input variable is empty, so the length guard now correctly fires.

Also extended the pre-schema check (step 3) to explicitly test array fields for `length == 0`,
providing a named diagnostic before AJV is invoked.

## Proof Artifacts

| File | Type | Status |
|------|------|--------|
| T37-01-shellcheck.txt | cli | PASS |
| T37-02-empty-array-fix.txt | cli | PASS |
| T37-03-e2e-validation.txt | cli | PASS |

## Summary

- ShellCheck at severity=style: clean (no warnings, no errors)
- Empty pipeline produces length 0 after fix (was 1 before fix)
- Populated arrays still produce correct length
- Empty Success Criteria section exits 1 with "FAIL: missing or empty brief fields: success_criteria"
- Populated Success Criteria section passes and exits 0
- Exit codes 0/1/2 semantics preserved
