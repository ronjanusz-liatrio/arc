# Source: docs/specs/03-spec-arc-align/03-spec-arc-align.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Codebase Discovery Engine

  Scenario: Hardcoded directories and Arc-managed files are excluded from scanning
    Given a repository containing a "node_modules/" directory with 500 files
    And a ".git/" directory with internal objects
    And a "docs/BACKLOG.md" file managed by Arc
    When the user runs "/arc-align"
    Then the discovery list contains zero matches from "node_modules/"
    And the discovery list contains zero matches from ".git/"
    And the discovery list contains zero matches from "docs/BACKLOG.md"

  Scenario: Large directories are recommended for exclusion
    Given a repository containing a "data/" directory with 150 files
    And a "src/" directory with 20 files
    When the user runs "/arc-align"
    Then the exclusion confirmation prompt recommends "data/" for exclusion
    And "src/" is not listed in the exclusion recommendations

  Scenario: User selects custom exclusion patterns via multi-select
    Given a repository containing product-direction content in "legacy/" and "src/"
    When the user runs "/arc-align"
    And the exclusion prompt is presented with defaults and large-directory recommendations
    And the user adds a custom exclusion pattern "legacy/"
    Then files in "legacy/" are not scanned
    And files in "src/" are scanned for product-direction content

  Scenario: Keyword matching detects roadmap content in markdown files
    Given a repository with a "README.md" containing a "## Roadmap" section with 3 planned features
    And a "CONTRIBUTING.md" with no product-direction content
    When the user runs "/arc-align"
    Then the discovery list includes "README.md" with detection method "keyword"
    And the discovery list does not include "CONTRIBUTING.md"

  Scenario: Structural matching detects task lists as backlog items
    Given a repository with a "TODO.md" containing 5 markdown task list items ("- [ ] ...")
    When the user runs "/arc-align"
    Then the discovery list includes "TODO.md" with detection method "structural"
    And each task list item is recorded as a separate discovery

  Scenario: Discoveries are classified into correct artifact targets
    Given a repository with a "PERSONAS.md" containing user persona descriptions
    And a "VISION.md" containing a mission statement with the term "north star"
    And a "features.md" containing a numbered feature list
    When the user runs "/arc-align"
    Then "PERSONAS.md" is classified with target artifact "CUSTOMER"
    And "VISION.md" is classified with target artifact "VISION"
    And "features.md" is classified with target artifact "BACKLOG"

  Scenario: Previously imported sources are skipped on re-run
    Given a repository with a "TODO.md" containing 3 task items
    And a "docs/align-manifest.md" recording "TODO.md" lines 1-10 as already imported
    When the user runs "/arc-align"
    Then the discovery list does not include "TODO.md" lines 1-10
    And the inline output indicates items were skipped due to prior import

  Scenario: Discovery list records complete metadata for each match
    Given a repository with a "README.md" containing a "## Planned Features" section at lines 20-35
    When the user runs "/arc-align"
    Then the discovery list entry for "README.md" includes the source file path "README.md"
    And the entry includes the line range "20-35"
    And the entry includes a content snippet from the matched section
    And the entry includes the detection method
    And the entry includes the target artifact classification
