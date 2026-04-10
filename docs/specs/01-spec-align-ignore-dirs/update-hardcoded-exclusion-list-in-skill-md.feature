# Source: docs/specs/01-spec-align-ignore-dirs/01-spec-align-ignore-dirs.md
# Pattern: Configuration + Consistency
# Recommended test type: Unit

Feature: Update hardcoded exclusion list in SKILL.md

  Background:
    Given the file skills/arc-assess/SKILL.md exists
    And it contains a hardcoded exclusion table in Step 1a

  Scenario: Python directories are added to the Step 1a exclusion table
    When the user inspects the Step 1a hardcoded exclusion table
    Then the Directories row includes ".venv/"
    And the Directories row includes "__pycache__/"
    And the Directories row includes ".mypy_cache/"
    And the Directories row includes ".pytest_cache/"
    And the Directories row includes ".ruff_cache/"
    And the Directories row includes ".tox/"
    And the Directories row includes "*.egg-info/"

  Scenario: Rust and Java directories are added to the Step 1a exclusion table
    When the user inspects the Step 1a hardcoded exclusion table
    Then the Directories row includes "target/"
    And the Directories row includes ".gradle/"

  Scenario: JS framework directories are added to the Step 1a exclusion table
    When the user inspects the Step 1a hardcoded exclusion table
    Then the Directories row includes ".next/"
    And the Directories row includes ".nuxt/"

  Scenario: Testing directories are added to the Step 1a exclusion table
    When the user inspects the Step 1a hardcoded exclusion table
    Then the Directories row includes "coverage/"

  Scenario: Existing exclusion entries are preserved
    When the user inspects the Step 1a hardcoded exclusion table
    Then the Directories row still includes ".git/"
    And the Directories row still includes "node_modules/"
    And the Directories row still includes "vendor/"
    And the Directories row still includes "dist/"
    And the Directories row still includes "build/"

  Scenario: Step 2c inline exclusion reference includes new directories
    When the user inspects the Step 2c code comment scanning section
    Then the inline exclusion reference includes all 12 new directory patterns

  Scenario: Code comment patterns intro includes new directories
    When the user inspects the code comment patterns intro section
    Then the inline exclusion reference includes all 12 new directory patterns

  Scenario: Report template section in SKILL.md includes new directories
    When the user inspects the report template section in SKILL.md
    Then the Hardcoded Exclusions table includes all 12 new directory patterns
    And each new entry uses the "| {pattern} | Directory |" format

  Scenario: All four locations in SKILL.md list identical directory sets
    When the user compares all four exclusion references in SKILL.md
    Then the Step 1a table, Step 2c reference, code comment intro, and report template section all contain the same set of directory exclusion patterns
