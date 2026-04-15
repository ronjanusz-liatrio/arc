# Source: docs/specs/12-spec-arc-status/12-spec-arc-status.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Lifecycle Gap Detection

  Scenario: Captured-to-Shaped gap is detected
    Given docs/BACKLOG.md contains an idea with Status captured and no Shaped timestamp
    When the user invokes /arc-status
    Then the "Lifecycle Gaps" section reports a "Captured -> Shaped" gap for that idea
    And the gap entry includes the idea title and a remediation hint mentioning /arc-shape

  Scenario: Shaped-to-Spec gap is detected for missing spec field
    Given docs/BACKLOG.md contains an idea with Status shaped and no Spec field
    When the user invokes /arc-status
    Then the "Lifecycle Gaps" section reports a "Shaped -> Spec" gap for that idea
    And the gap entry includes the idea title and a remediation hint mentioning /cw-spec

  Scenario: Shaped-to-Spec gap is detected for non-existent spec directory
    Given docs/BACKLOG.md contains an idea with Status shaped and a Spec field pointing to a non-existent directory
    When the user invokes /arc-status
    Then the "Lifecycle Gaps" section reports a "Shaped -> Spec" gap for that idea
    And the remediation hint mentions /cw-spec

  Scenario: Spec-to-Plan gap is detected
    Given a spec directory exists containing a spec file but no plan artifacts or task board references
    When the user invokes /arc-status
    Then the "Lifecycle Gaps" section reports a "Spec -> Plan" gap for that spec
    And the gap entry includes the spec name and a remediation hint mentioning /cw-plan

  Scenario: Plan-to-Validation gap is detected
    Given a spec directory contains planned task artifacts but no validation report file matching NN-validation-*.md
    When the user invokes /arc-status
    Then the "Lifecycle Gaps" section reports a "Plan -> Validation" gap for that spec
    And the gap entry includes the spec name and a remediation hint mentioning /cw-validate

  Scenario: Validation-to-Shipped gap is detected
    Given a spec directory contains a validation report with "**Overall**: PASS"
    And the linked BACKLOG idea still has Status spec-ready
    When the user invokes /arc-status
    Then the "Lifecycle Gaps" section reports a "Validation -> Shipped" gap for that idea
    And the gap entry includes the idea title and a remediation hint mentioning /arc-ship

  Scenario: No lifecycle gaps are reported when all stages are in sync
    Given every idea in BACKLOG.md has progressed through all applicable lifecycle stages
    And every spec directory has matching plan artifacts and validation reports
    When the user invokes /arc-status
    Then the "Lifecycle Gaps" section displays "No lifecycle gaps detected"

  Scenario: Unreadable spec file produces a warning instead of a hard error
    Given a spec directory exists but its spec file cannot be parsed
    When the user invokes /arc-status
    Then that spec is listed as a skipped check with a warning message
    And the remaining lifecycle gap checks continue to execute
    And the skill does not terminate with an error
