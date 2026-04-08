# T31 Proof Summary

## Task
FIX-REVIEW #31: Heading placement inside/outside ARC markers contradicts between docs

## Issue
readme-mapping.md placed `## Heading` INSIDE ARC markers (after BEGIN), while SKILL.md placed them OUTSIDE (before BEGIN). This inconsistency would cause headings to be replaced on update in one convention but not the other.

## Fix Applied
Updated all five ARC section output templates in `readme-mapping.md` to place headings OUTSIDE markers, matching the canonical SKILL.md convention.

## Proof Artifacts

| # | File | Type | Status |
|---|------|------|--------|
| 1 | T31-01-file.txt | file | PASS |
| 2 | T31-02-file.txt | file | PASS |

## Details

- **T31-01-file.txt**: Verifies all five sections in readme-mapping.md now have headings before BEGIN markers
- **T31-02-file.txt**: Cross-document comparison confirming SKILL.md and readme-mapping.md use identical heading placement convention

## Sections Fixed
1. ARC:overview — `## Overview` moved before `<!--# BEGIN ARC:overview -->`
2. ARC:audience — `## Who This Is For` moved before `<!--# BEGIN ARC:audience -->`
3. ARC:features — `## Features` moved before `<!--# BEGIN ARC:features -->`
4. ARC:roadmap — `## Roadmap` moved before `<!--# BEGIN ARC:roadmap -->`
5. ARC:lifecycle-diagram — `## Idea Lifecycle` moved before `<!--# BEGIN ARC:lifecycle-diagram -->`

## Result
2/2 proofs PASS
