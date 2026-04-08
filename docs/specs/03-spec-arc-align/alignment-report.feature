# Source: docs/specs/03-spec-arc-align/03-spec-arc-align.md
# Pattern: CLI/Process
# Recommended test type: Integration

Feature: Alignment Report

  Scenario: Report file is generated with run metadata section
    Given a completed "/arc-align" run that scanned 50 files with 2 exclusion patterns
    When the report is generated
    Then "docs/align-report.md" contains a "Run metadata" section
    And the section includes a timestamp, the exclusion patterns applied, total files scanned as 50, and total discoveries count

  Scenario: Report groups imported items by target artifact
    Given an "/arc-align" run that imported 3 BACKLOG items, 1 VISION item, and 2 CUSTOMER items
    When the report is generated
    Then "docs/align-report.md" contains an "Imported items by artifact" section
    And the BACKLOG group lists 3 entries with source path, imported title, and detection method
    And the VISION group lists 1 entry
    And the CUSTOMER group lists 2 entries

  Scenario: Report lists skipped items from prior manifest entries
    Given a "docs/align-manifest.md" with 2 previously imported entries
    And those same source locations are detected again during scanning
    When the report is generated
    Then "docs/align-report.md" contains a "Skipped items" section listing the 2 entries
    And each entry shows the source path and original import date

  Scenario: Report lists excluded files and directories
    Given an "/arc-align" run that excluded "node_modules/", "vendor/", and "data/"
    When the report is generated
    Then "docs/align-report.md" contains an "Unmatched exclusions" section
    And the section lists "node_modules/", "vendor/", and "data/" so the user knows what was not scanned

  Scenario: Report shows remaining unmanaged content below confidence threshold
    Given an "/arc-align" run that detected 2 content blocks with ambiguous product-direction signals
    And those blocks fell below the confidence threshold for automatic import
    When the report is generated
    Then "docs/align-report.md" contains a "Remaining unmanaged content" section
    And each entry shows the source path and a content snippet for manual review

  Scenario: Inline summary presents correct counts as a markdown table
    Given an "/arc-align" run that imported 4 items, skipped 2 items, and left 1 item behind
    And 1 file was fully deleted and 1 file had a section trimmed
    When the run completes and the inline summary is presented
    Then the inline summary displays a markdown table with 4 imported, 2 skipped, and 1 left behind
    And the summary notes 1 file deleted and 1 section trimmed

  Scenario: Next steps are offered after the report is presented
    Given a completed "/arc-align" run with the inline summary displayed
    When the user views the summary
    Then the skill offers next-step options to the user
