# Source: docs/specs/09-spec-command-walkthrough-diagrams/09-spec-command-walkthrough-diagrams.md
# Pattern: CLI/Process
# Recommended test type: Integration

Feature: Mermaid Lint Script and Baseline Sweep

  Scenario: Lint script validates all existing mermaid fences successfully
    Given the repository contains markdown files with valid mermaid fenced blocks
    And the file "scripts/lint-mermaid.sh" exists and is executable
    When the user runs "bash scripts/lint-mermaid.sh"
    Then the command exits with code 0
    And stdout contains a single summary line reporting file count, fence count, and "all valid"

  Scenario: Lint script discovers fences across multiple markdown files
    Given the repository contains at least two markdown files each with one or more mermaid fences
    When the user runs "bash scripts/lint-mermaid.sh"
    Then the summary line reports the total count of files scanned
    And the summary line reports the total count of fences validated
    And the command exits with code 0

  Scenario: Lint script exits non-zero on a broken mermaid fence
    Given a temporary markdown file in the repo containing an invalid mermaid fence
    When the user runs "bash scripts/lint-mermaid.sh"
    Then the command exits with code 1
    And the output names the file containing the broken fence
    And the output identifies the fence index within that file

  Scenario: Lint script excludes node_modules, worktrees, and specs research directories
    Given a markdown file at "node_modules/test/broken.md" containing an invalid mermaid fence
    And a markdown file at ".worktrees/feature-x/broken.md" containing an invalid mermaid fence
    When the user runs "bash scripts/lint-mermaid.sh"
    Then the command exits with code 0
    And the summary line does not include the excluded directories in its counts

  Scenario: Lint script produces clean silent output on success
    Given the repository contains only valid mermaid fences
    When the user runs "bash scripts/lint-mermaid.sh"
    Then stdout contains exactly one line
    And the output contains no instructional prose or multi-line explanations
    And the command exits with code 0

  Scenario: Lint script requires no external configuration file
    Given no mermaid-cli configuration file exists in the repository
    When the user runs "bash scripts/lint-mermaid.sh"
    Then the command completes without error
    And the command exits with code 0

  Scenario: Lint script cleans up temporary files on completion
    Given the repository contains valid mermaid fences
    When the user runs "bash scripts/lint-mermaid.sh"
    Then no temporary files created by the script remain in TMPDIR after exit
    And no temporary files are created outside TMPDIR

  Scenario: Lint script passes shellcheck validation
    Given the file "scripts/lint-mermaid.sh" exists
    When the user runs "shellcheck scripts/lint-mermaid.sh"
    Then the command exits with code 0
    And no warnings or errors are reported
