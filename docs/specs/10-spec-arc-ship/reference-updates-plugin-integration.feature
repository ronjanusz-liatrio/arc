# Source: docs/specs/10-spec-arc-ship/10-spec-arc-ship.md
# Pattern: State
# Recommended test type: Integration

Feature: Reference Updates + Plugin Integration

  Scenario: idea-lifecycle.md documents arc-ship as the shipped transition mechanism
    Given the /arc-ship skill has been implemented
    When the user reads references/idea-lifecycle.md
    Then the Shipped stage's Entry Criteria section references "/arc-ship" as the mechanism for the Spec-Ready to Shipped transition
    And the Shipped data fields section documents that "- **Spec:**" and "- **Shipped:**" are added by /arc-ship
    And the lifecycle diagram's SpecReady to Shipped transition label reads "SDD pipeline + /arc-ship"

  Scenario: Plugin version is bumped to 0.13.0
    Given .claude-plugin/plugin.json currently reads version "0.12.0"
    When the /arc-ship implementation is complete
    Then .claude-plugin/plugin.json reads version "0.13.0"

  Scenario: README.md references arc-ship in multiple locations
    Given README.md exists in the project root
    When the /arc-ship implementation is complete
    Then README.md contains "/arc-ship" in at least 2 distinct locations
    And /arc-ship appears in the skills summary or skills list
    And /arc-ship appears in a lifecycle or pipeline diagram or description

  Scenario: skills/README.md includes arc-ship in the skills table
    Given skills/README.md exists
    When the /arc-ship implementation is complete
    Then skills/README.md contains an entry for "/arc-ship" in the skills table
    And the entry includes a description of the ship skill's purpose
