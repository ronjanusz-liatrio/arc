# Source: docs/specs/18-spec-arc-status-spec-completion/18-spec-arc-status-spec-completion.md
# Pattern: CLI/Process
# Recommended test type: Integration

Feature: Add LG-6 (Orphan Spec) Detection

  Scenario: Orphan spec with PASS validation surfaces as an LG-6 row
    Given a repo with a spec directory "docs/specs/17-spec-claude-md-static-references/"
    And that directory contains a validation report matching "*-validation-*.md" with the literal line "**Overall**: PASS"
    And "docs/BACKLOG.md" contains no idea entry whose "Spec:" field equals "docs/specs/17-spec-claude-md-static-references"
    When the user runs the "/arc-status" skill against the repo
    Then the rendered Lifecycle Gaps table contains a row with the cells "Orphan Spec", "17-spec-claude-md-static-references", and "Run /arc-capture"
    And the row appears under the LG-6 detection pass

  Scenario: Spec with PASS validation that is linked to a BACKLOG idea is not flagged as LG-6
    Given a spec directory "docs/specs/12-spec-arc-status/" with a validation report containing "**Overall**: PASS"
    And "docs/BACKLOG.md" contains an idea entry whose "Spec:" field value, after trailing-slash normalization, equals "docs/specs/12-spec-arc-status"
    When the user runs the "/arc-status" skill against the repo
    Then the rendered Lifecycle Gaps table contains no row whose first cell is "Orphan Spec" and whose second cell is "12-spec-arc-status"

  Scenario: Spec with no PASS validation report is not flagged as LG-6
    Given a spec directory "docs/specs/19-spec-draft-feature/" exists
    And no file matching "docs/specs/19-spec-draft-feature/*-validation-*.md" contains the literal line "**Overall**: PASS"
    When the user runs the "/arc-status" skill against the repo
    Then the rendered Lifecycle Gaps table contains no row whose first cell is "Orphan Spec" and whose second cell is "19-spec-draft-feature"

  Scenario: Trailing slash on a BACKLOG Spec field still matches the spec directory and prevents an LG-6 flag
    Given a spec directory "docs/specs/14-spec-example/" with a PASS validation report
    And "docs/BACKLOG.md" contains an idea entry whose "Spec:" field value is "docs/specs/14-spec-example/" with a trailing slash
    When the user runs the "/arc-status" skill against the repo
    Then the rendered Lifecycle Gaps table contains no row for "14-spec-example" under "Orphan Spec"

  Scenario: An unreadable validation report does not abort the lifecycle gap pass
    Given a spec directory "docs/specs/20-spec-example/" exists
    And the validation report inside that directory is unreadable due to permissions
    When the user runs the "/arc-status" skill against the repo
    Then the command emits a skipped-check warning naming "20-spec-example"
    And the Lifecycle Gaps table is still rendered
    And LG-1 through LG-5 rows for unaffected specs still appear in the table

  Scenario: LG-6 gaps are tagged "backlog-only" by Step 6.6 scope tagging
    Given an LG-6 orphan-spec gap was detected for "17-spec-claude-md-static-references"
    And no active wave is in progress
    When the user runs the "/arc-status" skill against the repo
    Then Step 6.6 evaluates the orphan-spec gap to scope "backlog-only"
    And the rendered Lifecycle Gaps table shows the orphan row in three-column form: "| Orphan Spec | 17-spec-claude-md-static-references | Run /arc-capture |"

  Scenario: LG-6 gap renders in four-column form with "Backlog (outside wave)" when an active wave exists
    Given an active wave is in progress in "docs/skill/arc/waves/wave-N.md"
    And an LG-6 orphan-spec gap was detected for "17-spec-claude-md-static-references"
    When the user runs the "/arc-status" skill against the repo
    Then the rendered Lifecycle Gaps table contains a four-column row: "| Orphan Spec | 17-spec-claude-md-static-references | Run /arc-capture | Backlog (outside wave) |"

  Scenario: No-wave LG-6 priority recommends /arc-capture before falling through to the empty-state recommendation
    Given no active wave is in progress
    And no LG-1 P0/P1 gaps exist
    And an LG-6 orphan-spec gap exists for "17-spec-claude-md-static-references"
    When the user runs the "/arc-status" skill against the repo
    Then the recommended next skill emitted by the skill is "/arc-capture"
    And the recommendation reason text reads "17-spec-claude-md-static-references has a PASS validation report but no BACKLOG idea — capture it?"
    And the empty-state "no wave, no gaps" recommendation is not emitted

  Scenario: No-wave LG-6 priority offers /arc-audit as the alternative skill
    Given no active wave is in progress
    And the no-wave LG-6 priority is the active recommendation
    When the user requests an alternative skill via the Alternative Skill Selection rule
    Then the emitted alternative skill is "/arc-audit"

  Scenario: LG-1 through LG-5 detection text remains byte-identical after the LG-6 addition
    Given the parent commit of the spec-18 implementation
    When a byte-for-byte diff is run on the LG-1, LG-2, LG-3, LG-4, and LG-5 subsections of "skills/arc-status/SKILL.md" between the working tree and the parent commit
    Then the diff reports zero changed bytes inside those subsections

  Scenario: Existing precedence rows 1 through 13 remain byte-identical after the new no-wave LG-6 row is inserted
    Given the parent commit of the spec-18 implementation
    When a byte-for-byte diff is run on rows 1 through 13 of Step 7's precedence table between the working tree and the parent commit
    Then the diff reports zero changed bytes for those rows
    And a new row labeled with priority 14 referencing "/arc-capture" exists between the previous priority 13 row and the renumbered priority 15 "no wave, no gaps" row
