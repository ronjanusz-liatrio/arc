# Source: docs/specs/17-spec-claude-md-static-references/17-spec-claude-md-static-references.md
# Pattern: CLI/Process + State (skill definition files)
# Recommended test type: Integration

Feature: Remove CLAUDE.md write paths from /arc-wave and /arc-ship

  Scenario: /arc-wave SKILL.md no longer contains the inject-CLAUDE.md step
    Given skills/arc-wave/SKILL.md previously had Step 9 "Inject ARC:product-context into CLAUDE.md"
    When a developer reads the updated SKILL.md
    Then no step titled "Inject ARC:product-context into CLAUDE.md" is present
    And no sub-steps 9a, 9b, 9c, or 9d describing CLAUDE.md injection remain
    And the file does not instruct the agent to write to CLAUDE.md anywhere in the execution flow

  Scenario: /arc-ship SKILL.md no longer contains the refresh-CLAUDE.md step
    Given skills/arc-ship/SKILL.md previously had Step 7 "Refresh ARC:product-context"
    When a developer reads the updated SKILL.md
    Then no step titled "Refresh ARC:product-context" is present
    And the file does not instruct the agent to write to CLAUDE.md anywhere in the execution flow

  Scenario: Step numbering in /arc-wave is contiguous after removal
    Given skills/arc-wave/SKILL.md previously had Steps 1 through 11 with Step 9 as the inject step
    When a developer reads the updated SKILL.md from top to bottom
    Then steps appear in strict ascending order with no gaps
    And the previous Steps 10 and 11 are renumbered to 9 and 10
    And every cross-reference to a step number inside the same SKILL.md resolves to an existing step

  Scenario: Step numbering in /arc-ship is contiguous after removal
    Given skills/arc-ship/SKILL.md previously had Steps 1 through 8 with Step 7 as the refresh step
    When a developer reads the updated SKILL.md from top to bottom
    Then steps appear in strict ascending order with no gaps
    And the previous Step 8 is renumbered to 7
    And every cross-reference to a step number inside the same SKILL.md resolves to an existing step

  Scenario: /arc-wave summary points users to /arc-sync for CLAUDE.md updates
    Given skills/arc-wave/SKILL.md has had Step 9 removed
    When a user runs /arc-wave to completion in a project
    Then the post-completion summary contains a one-line note pointing the user to "/arc-sync" for CLAUDE.md product-context block creation or refresh
    And the note does not claim that /arc-wave updated CLAUDE.md

  Scenario: /arc-ship summary points users to /arc-sync for CLAUDE.md updates
    Given skills/arc-ship/SKILL.md has had Step 7 removed
    When a user runs /arc-ship to completion in a project
    Then the post-completion summary contains a one-line note pointing the user to "/arc-sync" for CLAUDE.md product-context block creation or refresh
    And the note does not claim that /arc-ship refreshed CLAUDE.md

  Scenario: /arc-ship flowchart no longer renders the CLAUDE.md refresh node
    Given skills/arc-ship/SKILL.md contains a flowchart diagram
    When a developer renders the flowchart in a markdown viewer
    Then no node labeled "Refresh CLAUDE.md product-context" appears
    And the edges that previously connected to that node connect the surrounding nodes directly
    And the flowchart parses without unresolved node references

  Scenario: wave-planning reference points to /arc-sync for CLAUDE.md
    Given references/wave-planning.md previously listed an ARC:product-context section under "creates"
    When a developer reads the updated wave-planning.md
    Then the "creates" list does not include an ARC:product-context CLAUDE.md section
    And a sentence in the document directs readers to /arc-sync for CLAUDE.md updates

  Scenario: ship-criteria reference is cleaned of CLAUDE.md refresh language
    Given skills/arc-ship/references/ship-criteria.md previously referenced the CLAUDE.md refresh step
    When a developer reads the updated ship-criteria.md
    Then no instructions in ship-criteria require refreshing CLAUDE.md as a ship gate
    And no proof artifact in ship-criteria depends on /arc-ship writing to CLAUDE.md

  Scenario: Files Read/Written lists drop CLAUDE.md when only used for product-context
    Given /arc-wave and /arc-ship SKILL.md files declare a "Files Read/Written" list
    When a developer reviews each list
    Then CLAUDE.md is absent from /arc-wave's list when its only prior purpose was writing the product-context block
    And CLAUDE.md is absent from /arc-ship's list when its only prior purpose was writing the product-context block

  Scenario: Grep confirms no CLAUDE.md write verbs remain in /arc-wave
    Given skills/arc-wave/SKILL.md has been updated
    When a developer runs "grep -n 'CLAUDE.md' skills/arc-wave/SKILL.md"
    Then any matching lines do not pair the words "Inject", "Refresh", "Update", or "Replace" with CLAUDE.md
    And no matching line describes a write to CLAUDE.md

  Scenario: Grep confirms no CLAUDE.md write verbs remain in /arc-ship
    Given skills/arc-ship/SKILL.md has been updated
    When a developer runs "grep -n 'CLAUDE.md' skills/arc-ship/SKILL.md"
    Then any matching lines do not pair the words "Inject", "Refresh", "Update", or "Replace" with CLAUDE.md
    And no matching line describes a write to CLAUDE.md

  Scenario: Grep confirms product-context is no longer mentioned inside skill execution steps
    Given /arc-wave and /arc-ship SKILL.md files have been updated
    When a developer runs "grep -n 'product-context' skills/arc-wave/SKILL.md skills/arc-ship/SKILL.md"
    Then zero matches are returned inside the numbered execution steps of either file
