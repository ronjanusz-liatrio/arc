# Source: docs/specs/05-spec-arc-help/05-spec-arc-help.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Plugin Registration and Skill Index Update

  Scenario: skills/README.md contains an arc-help row in the skill table
    Given the arc-help skill has been created at skills/arc-help/SKILL.md
    When a contributor opens skills/README.md
    Then the skill table contains a row for arc-help
    And the row includes a description and invocation syntax

  Scenario: arc-help is positioned after arc-audit in the skill table
    Given the arc-help skill has been registered in skills/README.md
    When a contributor reads the skill table
    Then the arc-help row appears after the arc-audit row
    And arc-help is categorized as a meta/utility skill

  Scenario: skills/README.md workflow section notes arc-help as available anytime
    Given the arc-help skill has been registered in skills/README.md
    When a contributor reads the workflow section
    Then /arc-help is listed alongside /arc-audit as available at any time
    And /arc-help is not part of the sequential workflow order

  Scenario: Root README.md skill table includes arc-help
    Given the arc-help skill has been created at skills/arc-help/SKILL.md
    When a contributor opens README.md at the project root
    Then the skill table contains a row for arc-help with its description

  Scenario: Root README.md Plugin Structure tree includes arc-help
    Given the arc-help skill has been created at skills/arc-help/SKILL.md
    When a contributor reads the Plugin Structure section in README.md
    Then the directory tree lists skills/arc-help/SKILL.md
