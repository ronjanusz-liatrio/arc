# Source: docs/specs/03-spec-arc-align/03-spec-arc-align.md
# Pattern: CLI/Process
# Recommended test type: Integration

Feature: SKILL.md and Plugin Integration

  Scenario: SKILL.md is created with valid frontmatter matching Arc conventions
    Given the Arc plugin repository with existing skills "arc-capture", "arc-shape", "arc-wave", and "arc-review"
    When the "/arc-align" skill files are created
    Then "skills/arc-align/SKILL.md" exists
    And the file contains frontmatter with "name: arc-align"
    And the file contains frontmatter with "user-invocable: true"
    And the file contains an "allowed-tools" field listing "Glob, Grep, Read, Write, Edit, AskUserQuestion"

  Scenario: SKILL.md contains the complete process protocol
    Given the "/arc-align" skill definition is created
    When a user reads "skills/arc-align/SKILL.md"
    Then the file documents the exclusion confirmation step
    And the file documents the keyword and structural detection strategies
    And the file documents the artifact classification and import process
    And the file documents the report generation step

  Scenario: Detection patterns reference document is created
    Given the "/arc-align" skill files are created
    When a user reads "skills/arc-align/references/detection-patterns.md"
    Then the document lists all keyword patterns with examples including "roadmap", "backlog", "todo", and "north star"
    And the document lists all structural patterns with examples including markdown task lists and heading patterns

  Scenario: Import rules reference document is created
    Given the "/arc-align" skill files are created
    When a user reads "skills/arc-align/references/import-rules.md"
    Then the document describes the BACKLOG, VISION, and CUSTOMER classification rules
    And the document describes the captured stub generation logic with default fields
    And the document describes the cleanup behavior for full-file and partial-file deletion

  Scenario: Plugin manifest includes arc-align and has incremented version
    Given ".claude-plugin/plugin.json" with a current version and skills list
    When the "/arc-align" skill is integrated into the plugin
    Then ".claude-plugin/plugin.json" includes "arc-align" in the skills list
    And the patch version number is incremented by 1 compared to the previous version

  Scenario: README.md references arc-align in all required locations
    Given "README.md" with existing skills table and pipeline diagram sections
    When the "/arc-align" skill is integrated into documentation
    Then "README.md" contains "/arc-align" in the skills table
    And "README.md" contains "/arc-align" in the pipeline diagram
    And "README.md" contains "/arc-align" in the relationship section

  Scenario: Skills directory README includes arc-align
    Given "skills/README.md" exists listing current skills
    When the "/arc-align" skill is integrated into documentation
    Then "skills/README.md" includes an entry for "/arc-align"
