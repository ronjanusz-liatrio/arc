# Source: docs/specs/08-spec-backlog-consistency/08-spec-backlog-consistency.md
# Pattern: State
# Recommended test type: Integration

Feature: Deduplicate VISION.md

  Scenario: Clean summary sections are retained
    Given a VISION.md with Vision Summary, Problem Statement, and Value Proposition sections in lines 1-16
    When the deduplication operation is executed on VISION.md
    Then the Vision Summary section is present and unchanged
    And the Problem Statement section is present and unchanged
    And the Value Proposition section is present and unchanged

  Scenario: Imported Content heading and redundant aligned-from blocks are removed
    Given a VISION.md with an "## Imported Content" heading followed by aligned-from blocks that duplicate content from the summary sections
    When the deduplication operation is executed on VISION.md
    Then VISION.md does not contain an "## Imported Content" heading
    And the aligned-from blocks that duplicated summary content are no longer present

  Scenario: Non-redundant aligned-from blocks with unique content are retained
    Given a VISION.md with aligned-from blocks containing strategic goals, quality goals, discovery goals, and other content not present in the summary sections
    When the deduplication operation is executed on VISION.md
    Then those aligned-from blocks with unique content remain in VISION.md
    And their associated headings and content are preserved

  Scenario: Heading hierarchy and readability are maintained after deduplication
    Given a VISION.md with a mix of redundant and non-redundant content
    When the deduplication operation is executed on VISION.md
    Then the resulting document has a coherent heading hierarchy with no orphaned subsections
    And no consecutive blank lines exceed two
