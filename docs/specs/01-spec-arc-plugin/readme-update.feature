# Source: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md
# Pattern: State (file content update)
# Recommended test type: Integration

Feature: README Update

  Scenario: README reflects implemented skills without Planned labels
    Given the arc plugin has all three skills implemented
    When the user reads README.md
    Then the skills section lists arc-capture, arc-shape, and arc-wave
    And none of the skill entries contain the word "Planned"

  Scenario: README plugin structure matches actual file tree
    Given the arc plugin has all files implemented
    When the user compares the plugin structure diagram in README.md to the actual file tree
    Then every directory and file shown in the diagram exists on disk
    And no implemented files are missing from the diagram

  Scenario: README internal links and cross-references are valid
    Given the arc plugin has all files implemented
    When the user follows each internal link in README.md
    Then every linked file or section target resolves to an existing resource
