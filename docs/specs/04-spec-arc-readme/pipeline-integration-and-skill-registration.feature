# Source: docs/specs/04-spec-arc-sync/04-spec-arc-sync.md
# Pattern: State
# Recommended test type: Integration

Feature: Pipeline Integration and Skill Registration

  Scenario: arc-sync appears in the skill hub
    Given the Arc plugin skills/README.md
    When a user reads the skill directory
    Then /arc-sync is listed in the skill table with description and invocation syntax
    And the workflow diagram shows /arc-sync between /arc-wave and /cw-spec

  Scenario: arc-sync registered in marketplace manifest
    Given the Arc plugin .claude-plugin/marketplace.json
    When a user reads the marketplace description
    Then the description mentions /arc-sync alongside other skills

  Scenario: Plugin version bumped to 0.5.0
    Given the Arc plugin .claude-plugin/plugin.json
    When a user reads the version field
    Then the version is 0.5.0

  Scenario: arc-wave offers arc-sync as next step
    Given a user has completed /arc-wave and reached the next steps prompt
    When the next step options are presented
    Then /arc-sync is listed as an option alongside /cw-spec

  Scenario: arc-audit offers arc-sync when WA-7 triggers
    Given a user has completed /arc-audit and WA-7 detected staleness
    When the next step options are presented
    Then "Run /arc-sync" appears as a recommended action

  Scenario: Arc own README lists arc-sync in skills section
    Given the Arc plugin README.md
    When a user reads the Skills section
    Then /arc-sync appears in the skills table with its role description
    And the Two-Plugin Pipeline diagram includes /arc-sync after /arc-wave
