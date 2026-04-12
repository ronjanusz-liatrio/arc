# T03 Proof Summary

## Task
Fix README.md lifecycle count and pipeline diagram label

## Results

| # | Type | File | Status |
|---|------|------|--------|
| 1 | cli | T03-01-cli.txt | PASS |
| 2 | cli | T03-02-cli.txt | PASS |
| 3 | file | T03-03-file.txt | PASS |

## Scenario Coverage

### Pipeline diagram label corrected
- Verified "shaped brief" no longer appears anywhere in README.md
- Confirmed line 125 now reads `AW -->|"spec-ready brief"| CS`

### Lifecycle diagram Captured count matches BACKLOG state
- BACKLOG.md contains 36 captured items (confirmed via grep -c '| captured |')
- README.md lifecycle diagram now reads `Captured(36)` (was `Captured(63)`)
- Shipped count confirmed as `Shipped(7)` (unchanged)

## Overall: PASS (3/3)
