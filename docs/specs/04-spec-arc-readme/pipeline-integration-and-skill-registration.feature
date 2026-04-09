# Source: docs/specs/04-spec-arc-readme/04-spec-arc-readme.md
# Pattern: State
# Recommended test type: Integration

Feature: Pipeline Integration and Skill Registration

  Scenario: arc-readme appears in the skill hub
    Given the Arc plugin skills/README.md
    When a user reads the skill directory
    Then /arc-readme is listed in the skill table with description and invocation syntax
    And the workflow diagram shows /arc-readme between /arc-wave and /cw-spec

  Scenario: arc-readme registered in marketplace manifest
    Given the Arc plugin .claude-plugin/marketplace.json
    When a user reads the marketplace description
    Then the description mentions /arc-readme alongside other skills

  Scenario: Plugin version bumped to 0.5.0
    Given the Arc plugin .claude-plugin/plugin.json
    When a user reads the version field
    Then the version is 0.5.0

  Scenario: arc-wave offers arc-readme as next step
    Given a user has completed /arc-wave and reached the next steps prompt
    When the next step options are presented
    Then /arc-readme is listed as an option alongside /cw-spec

  Scenario: arc-review offers arc-readme when WA-7 triggers
    Given a user has completed /arc-review and WA-7 detected staleness
    When the next step options are presented
    Then "Run /arc-readme" appears as a recommended action

  Scenario: Arc own README lists arc-readme in skills section
    Given the Arc plugin README.md
    When a user reads the Skills section
    Then /arc-readme appears in the skills table with its role description
    And the Two-Plugin Pipeline diagram includes /arc-readme after /arc-wave
