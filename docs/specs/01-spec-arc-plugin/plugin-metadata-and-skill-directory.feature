# Source: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md
# Pattern: State (file content updates)
# Recommended test type: Integration

Feature: Plugin Metadata and Skill Directory

  Scenario: Plugin JSON version is updated to 0.2.0
    Given the arc plugin has all three skills implemented
    When the user inspects .claude-plugin/plugin.json
    Then the version field is set to "0.2.0"

  Scenario: Marketplace JSON version and descriptions are accurate
    Given the arc plugin has all three skills implemented
    When the user inspects .claude-plugin/marketplace.json
    Then the version field is set to "0.2.0"
    And the skill descriptions accurately reflect arc-capture, arc-shape, and arc-wave functionality

  Scenario: Skills README serves as a directory hub
    Given the arc plugin has all three skills implemented
    When the user reads skills/README.md
    Then the document lists arc-capture with a one-line description and invocation syntax
    And the document lists arc-shape with a one-line description and invocation syntax
    And the document lists arc-wave with a one-line description and invocation syntax
    And each skill entry links to its respective SKILL.md file
