# Source: docs/specs/10-spec-arc-ship/10-spec-arc-ship.md
# Pattern: CLI/Process + State + Error handling
# Recommended test type: Integration

Feature: Batch Mode + ROADMAP Rollup + CLAUDE.md Update

  Scenario: User batch-ships multiple spec-ready ideas from the same wave
    Given docs/BACKLOG.md contains 3 spec-ready ideas in Wave 2: "Feature A", "Feature B", and "Feature C"
    And each idea has a passing validation report in its spec directory
    When the user invokes /arc-ship and selects all 3 ideas via multi-select
    Then the BACKLOG summary table shows "shipped" status for all 3 ideas
    And each idea's detail section contains "- **Shipped:**" with an ISO 8601 timestamp
    And a summary message is displayed: "3 ideas shipped, 0 failed verification."

  Scenario: Partial batch success when one idea fails validation
    Given docs/BACKLOG.md contains 3 spec-ready ideas in Wave 2: "Feature A", "Feature B", and "Feature C"
    And "Feature A" and "Feature C" have passing validation reports
    And "Feature B" has no validation report in its spec directory
    When the user invokes /arc-ship and selects all 3 ideas via multi-select
    Then the BACKLOG shows "shipped" status for "Feature A" and "Feature C"
    And the BACKLOG shows "spec-ready" status for "Feature B" (unchanged)
    And the system reports the failure for "Feature B": no cw-validate report found
    And a summary message is displayed: "2 ideas shipped, 1 failed verification. Wave 'Wave 2': In Progress."

  Scenario: ROADMAP wave status updates to Completed when all wave items are shipped
    Given docs/BACKLOG.md contains 2 ideas in Wave 3: "Feature X" (already shipped) and "Feature Y" (spec-ready)
    And docs/ROADMAP.md exists with Wave 3 status "Active"
    And "Feature Y" has a passing validation report
    When the user invokes /arc-ship and ships "Feature Y"
    Then the BACKLOG shows "shipped" status for "Feature Y"
    And docs/ROADMAP.md Wave 3 status field reads "Completed"

  Scenario: ROADMAP rollup is skipped when ROADMAP.md does not exist
    Given docs/BACKLOG.md contains a spec-ready idea with a passing validation report
    And docs/ROADMAP.md does not exist
    When the user invokes /arc-ship and ships the idea
    Then the BACKLOG is updated to "shipped" status
    And no error is raised about the missing ROADMAP.md

  Scenario: ARC product-context in CLAUDE.md is refreshed after shipping
    Given docs/BACKLOG.md contains 5 ideas: 2 shipped, 2 spec-ready, 1 shaped
    And CLAUDE.md exists with an ARC:product-context section showing "Backlog: 2 shipped, 2 spec-ready, 1 shaped"
    And one of the spec-ready ideas has a passing validation report
    When the user invokes /arc-ship and ships that idea
    Then the ARC:product-context section in CLAUDE.md shows "3 shipped, 1 spec-ready, 1 shaped"

  Scenario: CLAUDE.md refresh is skipped when CLAUDE.md does not exist
    Given docs/BACKLOG.md contains a spec-ready idea with a passing validation report
    And CLAUDE.md does not exist in the project root
    When the user invokes /arc-ship and ships the idea
    Then the BACKLOG is updated to "shipped" status
    And no error is raised about the missing CLAUDE.md
