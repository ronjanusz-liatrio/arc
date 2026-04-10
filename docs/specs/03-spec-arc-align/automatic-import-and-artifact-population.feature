# Source: docs/specs/03-spec-arc-assess/03-spec-arc-assess.md
# Pattern: State + CLI/Process
# Recommended test type: Integration

Feature: Automatic Import and Artifact Population

  Scenario: Missing BACKLOG.md is created from template before import
    Given a repository with no "docs/BACKLOG.md" file
    And a discovery list containing BACKLOG-targeted items
    When the user confirms the import
    Then "docs/BACKLOG.md" is created from "templates/BACKLOG.tmpl.md"
    And the imported captured stubs appear in the newly created file

  Scenario: Missing VISION.md is created from template before import
    Given a repository with no "docs/VISION.md" file
    And a discovery list containing VISION-targeted content
    When the user confirms the import
    Then "docs/VISION.md" is created from "templates/VISION.tmpl.md"
    And the imported content appears under an "## Imported Content" section

  Scenario: Missing CUSTOMER.md is created from template before import
    Given a repository with no "docs/CUSTOMER.md" file
    And a discovery list containing CUSTOMER-targeted persona content
    When the user confirms the import
    Then "docs/CUSTOMER.md" is created from "templates/CUSTOMER.tmpl.md"
    And the imported persona content appears under an "## Imported Content" section

  Scenario: BACKLOG-targeted items are imported as captured stubs with correct fields
    Given a repository with "docs/BACKLOG.md" already present
    And a discovery of a task item "Add dark mode support" from "TODO.md" line 5
    When the user confirms the import
    Then "docs/BACKLOG.md" contains a new captured stub titled "Add dark mode support"
    And the stub has priority "P2-Medium"
    And the stub has status "captured"
    And the stub has a captured timestamp in ISO 8601 format
    And the stub contains the comment "<!-- aligned-from: TODO.md:5 -->"

  Scenario: VISION-targeted content is appended with source attribution
    Given a repository with "docs/VISION.md" already present
    And a discovery of mission content from "ABOUT.md" lines 10-20
    When the user confirms the import
    Then "docs/VISION.md" contains the imported content under "## Imported Content"
    And the imported section includes attribution referencing "ABOUT.md" lines 10-20

  Scenario: CUSTOMER-targeted content is appended with source attribution
    Given a repository with "docs/CUSTOMER.md" already present
    And a discovery of persona content from "PERSONAS.md" lines 1-30
    When the user confirms the import
    Then "docs/CUSTOMER.md" contains the imported persona content under "## Imported Content"
    And the imported section includes attribution referencing "PERSONAS.md" lines 1-30

  Scenario: Entire file is deleted when all content is product-direction
    Given a "TODO.md" file containing only task list items classified as BACKLOG content
    When the user confirms the import
    Then all items from "TODO.md" are imported as captured stubs in "docs/BACKLOG.md"
    And "TODO.md" no longer exists in the repository

  Scenario: Only product-direction section is removed from mixed-content file
    Given a "README.md" containing a "## Roadmap" section at lines 50-70 and other non-product content
    When the user confirms the import
    Then the "## Roadmap" content from "README.md" is imported into "docs/BACKLOG.md"
    And "README.md" still exists in the repository
    And "README.md" no longer contains the "## Roadmap" section
    And the surrounding content in "README.md" is preserved intact

  Scenario: Align manifest is updated with import mappings
    Given a successful import of 3 items from 2 source files
    When the import completes
    Then "docs/align-manifest.md" contains 3 rows
    And each row includes the source path, line range, target artifact, imported title, and timestamp

  Scenario: BACKLOG summary table is updated with new rows
    Given "docs/BACKLOG.md" has an existing summary table with 2 entries
    And 3 new BACKLOG-targeted items are imported
    When the import completes
    Then the BACKLOG summary table contains 5 total rows
    And each new row corresponds to one of the imported captured stubs

  Scenario: Ambiguous content is imported inclusively rather than skipped
    Given a "notes.md" file containing a section with weak product-direction signals
    And the content could be either a feature idea or a general note
    When the user confirms the import
    Then the ambiguous content is imported as a captured stub in "docs/BACKLOG.md"
    And the stub includes the original text for manual review
