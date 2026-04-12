# Source: docs/specs/08-spec-backlog-consistency/08-spec-backlog-consistency.md
# Pattern: State
# Recommended test type: Integration

Feature: Merge Captured User Stories into Shipped Skill Entries

  Scenario: Captured user-story text is appended under the corresponding shipped skill entry
    Given a BACKLOG.md with 7 shipped skill entries and 28 captured stub sections that duplicate shipped capabilities
    When the merge operation is executed
    Then each shipped skill entry contains a "### User Stories" subsection
    And the user-story text from each captured stub appears under its mapped shipped skill entry

  Scenario: Aligned-from provenance comments are preserved during merge
    Given a captured stub section with an "<!-- aligned-from -->" comment
    When that stub is merged into its corresponding shipped skill entry
    Then the "<!-- aligned-from -->" comment from the captured stub appears within the merged "### User Stories" subsection

  Scenario: Merged captured stub sections are removed from BACKLOG.md
    Given a BACKLOG.md containing 28 captured stub sections that map to shipped skills
    When the merge operation is executed
    Then none of the 28 captured stub "## {Title}" sections remain in BACKLOG.md

  Scenario: Merged captured rows are removed from the summary table
    Given a BACKLOG.md summary table containing rows for 28 captured items that map to shipped skills
    When the merge operation is executed
    Then the summary table no longer contains rows for any of the 28 merged items

  Scenario: Shipped skill entries are assigned to Wave 0 Bootstrap
    Given 7 shipped skill entries in BACKLOG.md with wave field set to "--"
    When the merge operation is executed
    Then each shipped skill entry's wave field reads "Wave 0: Bootstrap"

  Scenario: Summary table reflects Wave 0 Bootstrap for all shipped items
    Given a BACKLOG.md summary table with 7 shipped rows showing "--" in the Wave column
    When the merge operation is executed
    Then all 7 shipped rows in the summary table show "Wave 0: Bootstrap" in the Wave column

  Scenario: Non-duplicate captured items are not modified
    Given a BACKLOG.md with captured items that are NOT duplicates of shipped capabilities such as "Add rewrite mode"
    When the merge operation is executed
    Then those non-duplicate captured items remain in BACKLOG.md with their original content unchanged
    And those non-duplicate captured items remain in the summary table
