# Source: docs/specs/13-spec-wave-archive/13-spec-wave-archive.md
# Pattern: State + CLI/Process + Error Handling
# Recommended test type: Integration

Feature: Wave archive schema + /arc-sync migration

  Scenario: Migration creates per-wave archive files from shipped BACKLOG items and completed ROADMAP waves
    Given docs/BACKLOG.md contains 10 rows with "Status: shipped" across 3 waves
    And docs/ROADMAP.md contains 3 waves with "Status: Completed"
    And the directory docs/skill/arc/waves/ does not exist
    When the user runs /arc-sync
    Then docs/skill/arc/waves/ contains exactly 3 archive files
    And each archive file is named with the pattern "NN-kebab-slug.md" matching its wave number and name
    And /arc-sync reports "Migrated 10 shipped ideas and 3 completed waves to docs/skill/arc/waves/"

  Scenario: Archive file contains wave heading, metadata block, and full idea details
    Given docs/BACKLOG.md contains a shipped idea "Capture Skill" with brief fields (Problem, Proposed Solution, Success Criteria, Constraints, Assumptions, Open Questions) and ship metadata
    And docs/ROADMAP.md contains "Wave 0: Bootstrap" with Theme, Goal, and Target fields
    When the user runs /arc-sync
    Then docs/skill/arc/waves/00-bootstrap.md starts with "# Wave 0: Bootstrap"
    And the file contains a metadata block with Theme, Goal, Target, and Completed timestamp
    And the file contains a "## Shipped Ideas" section
    And the "### Capture Skill" subsection includes Problem, Proposed Solution, Success Criteria, Constraints, Assumptions, Open Questions, Priority, Captured, Shaped, Shipped, and Spec fields

  Scenario: Shipped items are removed from BACKLOG after migration
    Given docs/BACKLOG.md contains 10 rows with "Status: shipped" and 8 rows with other statuses
    When the user runs /arc-sync
    Then docs/BACKLOG.md contains 0 rows with "Status: shipped"
    And docs/BACKLOG.md still contains 8 rows with non-shipped statuses
    And the detail sections for each of the 10 shipped ideas are no longer present in docs/BACKLOG.md

  Scenario: Completed waves are removed from ROADMAP after migration
    Given docs/ROADMAP.md contains 3 waves with "Status: Completed" and 1 wave with "Status: active"
    When the user runs /arc-sync
    Then docs/ROADMAP.md contains 0 waves with "Status: Completed"
    And docs/ROADMAP.md still contains the wave with "Status: active"
    And the "## Wave NN: Name" sections for the 3 completed waves are no longer present in docs/ROADMAP.md

  Scenario: Migration is idempotent on second run
    Given /arc-sync has already been run and all shipped items and completed waves have been migrated
    And docs/BACKLOG.md contains 0 rows with "Status: shipped"
    And docs/ROADMAP.md contains 0 waves with "Status: Completed"
    When the user runs /arc-sync again
    Then /arc-sync reports "0 migrations"
    And no files in docs/skill/arc/waves/ are modified
    And docs/BACKLOG.md content is unchanged
    And docs/ROADMAP.md content is unchanged

  Scenario: Orphaned shipped items are migrated to uncategorized archive
    Given docs/BACKLOG.md contains a shipped idea "Orphan Feature" whose Wave field references "Wave 99: Missing" which does not exist in ROADMAP.md
    When the user runs /arc-sync
    Then docs/skill/arc/waves/00-uncategorized.md is created
    And the "### Orphan Feature" subsection exists in 00-uncategorized.md with full detail
    And /arc-sync reports the orphaned item separately in its output
    And the "Orphan Feature" row and detail section are removed from docs/BACKLOG.md
