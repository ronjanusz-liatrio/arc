# Source: docs/specs/13-spec-wave-archive/13-spec-wave-archive.md
# Pattern: State + CLI/Process + Error Handling
# Recommended test type: Integration

Feature: /arc-ship writes to wave archive

  Scenario: Shipping an idea creates archive file and removes idea from BACKLOG
    Given docs/BACKLOG.md contains a spec-ready idea "New Widget" assigned to "Wave 3: Polish"
    And docs/ROADMAP.md contains "Wave 3: Polish" with Theme, Goal, and Target fields
    And a cw-validate report for "New Widget" shows "Overall: PASS"
    When the user runs /arc-ship for "New Widget"
    Then docs/skill/arc/waves/03-polish.md is created with "# Wave 3: Polish" heading and metadata block
    And the "### New Widget" subsection exists under "## Shipped Ideas" with full brief fields, "Shipped" timestamp, and "Spec" path
    And the "New Widget" row is removed from the docs/BACKLOG.md summary table
    And the "## New Widget" detail section is removed from docs/BACKLOG.md

  Scenario: Shipping appends to existing archive file when wave already has archived ideas
    Given docs/skill/arc/waves/03-polish.md already exists with one shipped idea "Old Widget"
    And docs/BACKLOG.md contains a spec-ready idea "Another Widget" assigned to "Wave 3: Polish"
    And a cw-validate report for "Another Widget" shows "Overall: PASS"
    When the user runs /arc-ship for "Another Widget"
    Then docs/skill/arc/waves/03-polish.md contains both "### Old Widget" and "### Another Widget" subsections
    And the "Another Widget" row and detail section are removed from docs/BACKLOG.md

  Scenario: Shipping the final idea in a wave archives the wave and removes it from ROADMAP
    Given "Wave 3: Polish" has 2 ideas in its ROADMAP Selected Ideas table
    And 1 of those ideas is already archived in docs/skill/arc/waves/03-polish.md
    And docs/BACKLOG.md contains the remaining spec-ready idea "Last Widget"
    And a cw-validate report for "Last Widget" shows "Overall: PASS"
    When the user runs /arc-ship for "Last Widget"
    Then docs/skill/arc/waves/03-polish.md contains both ideas under "## Shipped Ideas"
    And the metadata block in 03-polish.md includes a "Completed" timestamp in ISO 8601 format
    And the "Wave 3: Polish" row is removed from the docs/ROADMAP.md summary table
    And the "## Wave 3: Polish" section is removed from docs/ROADMAP.md

  Scenario: Batch shipping multiple ideas that together complete a wave
    Given "Wave 3: Polish" has 2 ideas in its ROADMAP Selected Ideas table
    And docs/BACKLOG.md contains both spec-ready ideas "Widget A" and "Widget B"
    And cw-validate reports for both ideas show "Overall: PASS"
    When the user runs /arc-ship in batch mode selecting both "Widget A" and "Widget B"
    Then docs/skill/arc/waves/03-polish.md contains both "### Widget A" and "### Widget B" subsections
    And the metadata block includes a "Completed" timestamp
    And only one ROADMAP wave deletion occurs for "Wave 3: Polish"
    And both "Widget A" and "Widget B" rows and detail sections are removed from docs/BACKLOG.md

  Scenario: Shipped count in CLAUDE.md product-context is derived from wave archive
    Given docs/skill/arc/waves/ contains archive files with a total of 12 "### " subsections across all files
    When /arc-ship completes and refreshes the ARC:product-context block in CLAUDE.md
    Then the "Backlog:" line in CLAUDE.md contains "12 shipped"
    And the shipped count matches the total number of "### " subsections in docs/skill/arc/waves/*.md

  Scenario: Shipping an idea whose wave section is missing falls back to uncategorized archive
    Given docs/BACKLOG.md contains a shipped-eligible idea "Stray Item" with Wave field "Wave 5: Gone"
    And docs/ROADMAP.md does not contain a "Wave 5: Gone" section
    And a cw-validate report for "Stray Item" shows "Overall: PASS"
    When the user runs /arc-ship for "Stray Item"
    Then docs/skill/arc/waves/00-uncategorized.md is created or updated with "### Stray Item"
    And /arc-ship emits a warning that the wave section for "Wave 5: Gone" was not found
    And no ROADMAP cleanup is performed for that idea
    And the "Stray Item" row and detail section are removed from docs/BACKLOG.md

  Scenario: Archive appends are ordered before BACKLOG removals to maintain consistency
    Given docs/BACKLOG.md contains a spec-ready idea "Ordered Item" assigned to "Wave 3: Polish"
    And a cw-validate report for "Ordered Item" shows "Overall: PASS"
    When the user runs /arc-ship for "Ordered Item"
    Then the archive file docs/skill/arc/waves/03-polish.md contains "### Ordered Item" before the row is removed from docs/BACKLOG.md
    And at no point during the operation is the idea absent from both BACKLOG and the archive
