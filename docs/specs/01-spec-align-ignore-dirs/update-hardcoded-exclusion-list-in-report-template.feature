# Source: docs/specs/01-spec-align-ignore-dirs/01-spec-align-ignore-dirs.md
# Pattern: Configuration + Consistency
# Recommended test type: Unit

Feature: Update hardcoded exclusion list in align-report-template.md

  Background:
    Given the file skills/arc-assess/references/align-report-template.md exists
    And it contains a Hardcoded Exclusions table

  Scenario: All 12 new directory patterns are present in the report template
    When the user inspects the Hardcoded Exclusions table in align-report-template.md
    Then it includes ".venv/" as a Directory entry
    And it includes "__pycache__/" as a Directory entry
    And it includes ".mypy_cache/" as a Directory entry
    And it includes ".pytest_cache/" as a Directory entry
    And it includes ".ruff_cache/" as a Directory entry
    And it includes ".tox/" as a Directory entry
    And it includes "*.egg-info/" as a Directory entry
    And it includes "target/" as a Directory entry
    And it includes ".gradle/" as a Directory entry
    And it includes ".next/" as a Directory entry
    And it includes ".nuxt/" as a Directory entry
    And it includes "coverage/" as a Directory entry

  Scenario: New entries use the standard table format
    When the user inspects the Hardcoded Exclusions table in align-report-template.md
    Then each new directory entry follows the "| {pattern} | Directory |" format
    And no trailing whitespace exists in any table row

  Scenario: Entries are grouped by category for readability
    When the user inspects the Hardcoded Exclusions table in align-report-template.md
    Then existing entries appear first
    Then Python entries (.venv/, __pycache__/, .mypy_cache/, .pytest_cache/, .ruff_cache/, .tox/, *.egg-info/) appear as a group
    Then Rust/Java entries (target/, .gradle/) appear as a group
    Then JS framework entries (.next/, .nuxt/) appear as a group
    Then Testing entries (coverage/) appear last among directory entries

  Scenario: Existing exclusion entries are preserved
    When the user inspects the Hardcoded Exclusions table in align-report-template.md
    Then it still includes ".git/" as a Directory entry
    And it still includes "node_modules/" as a Directory entry
    And it still includes "vendor/" as a Directory entry
    And it still includes "dist/" as a Directory entry
    And it still includes "build/" as a Directory entry

  Scenario: Report template directory list matches SKILL.md report section
    When the user compares the Hardcoded Exclusions table in align-report-template.md with the report template section in SKILL.md
    Then both files list the same set of directory exclusion patterns in the same order
