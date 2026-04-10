# Source: docs/specs/05-spec-arc-help/05-spec-arc-help.md
# Pattern: CLI/Process
# Recommended test type: Integration

Feature: SKILL.md with Static Help Content

  Scenario: arc-help skill has valid frontmatter with required fields
    Given the Arc plugin is installed locally
    When the user invokes /arc-help
    Then the skill executes without a frontmatter or registration error
    And the output begins with "**ARC-HELP**"

  Scenario: Help output includes an overview of what Arc is
    Given the Arc plugin is installed locally
    When the user invokes /arc-help
    Then the output contains a section explaining what Arc is
    And the section mentions the relationship to temper and claude-workflow

  Scenario: Help output lists all seven skills with descriptions
    Given the Arc plugin is installed locally
    When the user invokes /arc-help
    Then the output contains a skill table with seven rows
    And each row includes the skill name, a one-line description, and invocation syntax
    And the table includes arc-help itself

  Scenario: Help output shows the recommended workflow order
    Given the Arc plugin is installed locally
    When the user invokes /arc-help
    Then the output contains a workflow section
    And the workflow lists skills in order: /arc-assess, /arc-capture, /arc-shape, /arc-wave, /arc-sync
    And /arc-audit is noted as available at any time

  Scenario: Help output describes all four managed artifacts
    Given the Arc plugin is installed locally
    When the user invokes /arc-help
    Then the output contains an artifacts section
    And the section describes VISION, CUSTOMER, ROADMAP, and BACKLOG
    And each artifact entry includes its purpose and file path

  Scenario: Help output includes installation instructions
    Given the Arc plugin is installed locally
    When the user invokes /arc-help
    Then the output contains an installation section
    And the section includes install commands for Arc, temper, and claude-workflow

  Scenario: Help output links to the project README
    Given the Arc plugin is installed locally
    When the user invokes /arc-help
    Then the output contains a link to the project README for full documentation

  Scenario: arc-help accepts no arguments and always outputs the full guide
    Given the Arc plugin is installed locally
    When the user invokes /arc-help with no arguments
    Then the full help guide is displayed
    And the output includes overview, skills, workflow, artifacts, and installation sections
