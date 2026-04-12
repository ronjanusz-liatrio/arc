# Source: docs/specs/08-spec-backlog-consistency/08-spec-backlog-consistency.md
# Pattern: State
# Recommended test type: Integration

Feature: Fix README.md Inconsistencies

  Scenario: Pipeline diagram label is corrected from shaped brief to spec-ready brief
    Given a README.md with a Mermaid pipeline diagram containing the edge label "shaped brief" on the AW to CS line
    When the README fix operation is executed
    Then the pipeline diagram edge label reads "spec-ready brief"
    And the string "shaped brief" does not appear anywhere in README.md

  Scenario: Lifecycle diagram Captured count matches post-cleanup BACKLOG state
    Given a README.md with an ARC:lifecycle-diagram containing a Captured state label
    And a BACKLOG.md that has been cleaned up with 28 captured stubs removed
    When the README fix operation is executed
    Then the lifecycle diagram Captured count in README.md equals the number of remaining captured items in BACKLOG.md
    And the Shipped count in the lifecycle diagram reads "Shipped(7)"
