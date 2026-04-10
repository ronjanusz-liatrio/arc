# Source: docs/specs/06-spec-arc-assess-enhance/06-spec-arc-assess-enhance.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Source Code Comment Scanning

  Scenario: TODO comments in Python files produce BACKLOG discoveries
    Given a repository with a .py file containing "# TODO: refactor this module" on line 42
    When the user runs /arc-assess and completes the discovery phase
    Then the discovery list includes an item titled "Refactor this module"
    And the item summary references the originating file and line number
    And the item is tagged as "[code]" in the discovery list

  Scenario: FIXME comments are classified as high priority
    Given a repository with a .ts file containing "// FIXME: race condition in auth handler"
    When the user runs /arc-assess and confirms the import
    Then docs/BACKLOG.md contains a stub titled "Race condition in auth handler"
    And the stub has P1-High priority
    And the stub includes an "<!-- aligned-from-code: {file}:{line} -->" comment

  Scenario: HACK comments are classified as high priority
    Given a repository with a .go file containing "// HACK: temporary workaround for API timeout"
    When the user runs /arc-assess and confirms the import
    Then docs/BACKLOG.md contains a stub titled "Temporary workaround for API timeout"
    And the stub has P1-High priority

  Scenario: XXX comments are classified as medium priority
    Given a repository with a .js file containing "// XXX: needs review before release"
    When the user runs /arc-assess and confirms the import
    Then docs/BACKLOG.md contains a stub titled "Needs review before release"
    And the stub has P2-Medium priority

  Scenario: TODO comments are classified as medium priority
    Given a repository with a .rb file containing "# TODO: add pagination support"
    When the user runs /arc-assess and confirms the import
    Then docs/BACKLOG.md contains a stub titled "Add pagination support"
    And the stub has P2-Medium priority

  Scenario: Comment prefixes are stripped from extracted text
    Given a repository with source files containing comments in various syntaxes
    And a .py file has "# TODO: clean up logging"
    And a .ts file has "// TODO: clean up logging"
    And a .java file has "/* TODO: clean up logging */"
    When the user runs /arc-assess and completes the discovery phase
    Then each discovered item title is "Clean up logging" without comment prefix characters

  Scenario: Duplicate TODO text across files produces a single stub
    Given a repository where three .ts files contain the identical text "// TODO: implement retry logic"
    When the user runs /arc-assess and confirms the import
    Then docs/BACKLOG.md contains exactly one stub for "Implement retry logic"
    And the stub summary notes the additional file locations where the duplicate appeared

  Scenario: Comments in excluded directories are not scanned
    Given a repository with "// TODO: vendor code task" in a file under node_modules/
    And "// TODO: build artifact task" in a file under dist/
    When the user runs /arc-assess and completes the discovery phase
    Then no discoveries originate from node_modules/ or dist/ directories

  Scenario: Case-insensitive matching catches variant markers
    Given a repository with a .py file containing "# todo: lowercase marker"
    And a .ts file containing "// Todo: mixed case marker"
    When the user runs /arc-assess and completes the discovery phase
    Then both comments are discovered as BACKLOG items

  Scenario: All supported file extensions are scanned
    Given a repository with TODO comments in files with extensions .py, .ts, .tsx, .js, .jsx, .go, .rs, .java, .kt, .rb, .sh, .bash, .zsh, .swift, .c, .cpp, .h, .hpp, and .cs
    When the user runs /arc-assess and completes the discovery phase
    Then discoveries include items from all supported file extensions

  Scenario: Detection patterns document includes CC-1 through CC-4 entries
    Given the arc-assess detection-patterns.md has been updated for code comment scanning
    When the user reviews detection-patterns.md
    Then it documents CC-1 (TODO), CC-2 (FIXME), CC-3 (HACK), and CC-4 (XXX) patterns with descriptions and priority mappings
