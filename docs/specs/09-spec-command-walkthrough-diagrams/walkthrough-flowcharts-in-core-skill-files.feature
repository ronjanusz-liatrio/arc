# Source: docs/specs/09-spec-command-walkthrough-diagrams/09-spec-command-walkthrough-diagrams.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Walkthrough Flowcharts in Core SKILL.md Files

  Scenario: arc-capture SKILL.md contains a walkthrough flowchart after Overview
    Given the file "skills/arc-capture/SKILL.md" exists with an "## Overview" section
    When the walkthrough flowchart has been added
    Then the file contains a "## Walkthrough" heading
    And the "## Walkthrough" section appears after "## Overview" and before "## Critical Constraints"
    And the "## Walkthrough" section contains a mermaid fenced code block

  Scenario: arc-shape SKILL.md contains a walkthrough flowchart after Overview
    Given the file "skills/arc-shape/SKILL.md" exists with an "## Overview" section
    When the walkthrough flowchart has been added
    Then the file contains a "## Walkthrough" heading
    And the "## Walkthrough" section appears after "## Overview" and before "## Critical Constraints"
    And the "## Walkthrough" section contains a mermaid fenced code block

  Scenario: arc-wave SKILL.md contains a walkthrough flowchart after Overview
    Given the file "skills/arc-wave/SKILL.md" exists with an "## Overview" section
    When the walkthrough flowchart has been added
    Then the file contains a "## Walkthrough" heading
    And the "## Walkthrough" section appears after "## Overview" and before "## Critical Constraints"
    And the "## Walkthrough" section contains a mermaid fenced code block

  Scenario: arc-capture flowchart depicts inline idea Path A as canonical flow
    Given the file "skills/arc-capture/SKILL.md" contains a walkthrough flowchart
    When the mermaid diagram is rendered
    Then the flowchart includes nodes for user invocation with inline idea
    And the flowchart includes a node for parsing title and summary
    And the flowchart includes a node for AskUserQuestion confirmation and priority
    And the flowchart includes a node for appending to BACKLOG
    And the flowchart includes a node for confirmation message

  Scenario: arc-shape flowchart depicts the common shaping flow
    Given the file "skills/arc-shape/SKILL.md" contains a walkthrough flowchart
    When the mermaid diagram is rendered
    Then the flowchart includes a node for selecting an idea
    And the flowchart includes a node for launching parallel subagents
    And the flowchart includes a node for synthesizing a draft brief
    And the flowchart includes a node for interactive Q&A
    And the flowchart includes a node for validating the brief
    And the flowchart includes a node for updating BACKLOG and writing the shape report

  Scenario: arc-wave flowchart depicts the common wave flow
    Given the file "skills/arc-wave/SKILL.md" contains a walkthrough flowchart
    When the mermaid diagram is rendered
    Then the flowchart includes a node for reading context
    And the flowchart includes a node for scope assessment
    And the flowchart includes a node for selecting shaped ideas
    And the flowchart includes a node for gathering theme and target
    And the flowchart includes a node for updating ROADMAP and BACKLOG
    And the flowchart includes a node for injecting product context into CLAUDE.md
    And the flowchart includes a node for writing the wave report

  Scenario: All flowcharts use Arc brand theme variables
    Given the file "README.md" contains a mermaid themeVariables init block
    When the walkthrough flowcharts in all three SKILL.md files are compared to README.md
    Then each flowchart begins with an init block matching the README.md themeVariables exactly
    And the init block includes primaryColor "#11B5A4" teal
    And the init block includes secondaryColor "#E8662F" orange
    And the init block includes tertiaryColor "#1B2A3D" navy

  Scenario: Each flowchart stays within the 15-node limit
    Given walkthrough flowcharts have been added to all three core SKILL.md files
    When the node count of each mermaid flowchart is tallied
    Then the arc-capture flowchart contains no more than 15 nodes
    And the arc-shape flowchart contains no more than 15 nodes
    And the arc-wave flowchart contains no more than 15 nodes

  Scenario: Flowcharts use classDef styles for semantic node coloring
    Given walkthrough flowcharts have been added to all three core SKILL.md files
    When the mermaid source of any flowchart is inspected
    Then classDef definitions map user input nodes to navy
    And classDef definitions map Claude action nodes to teal
    And classDef definitions map file write nodes to orange

  Scenario: Lint script passes against all three modified SKILL.md files
    Given walkthrough flowcharts have been added to all three core SKILL.md files
    And the file "scripts/lint-mermaid.sh" exists and is executable
    When the user runs "bash scripts/lint-mermaid.sh"
    Then the command exits with code 0
    And the summary includes counts from the three updated SKILL.md files

  Scenario: Existing textual Process sections remain unchanged
    Given the original content of each core SKILL.md is recorded before modification
    When the walkthrough flowcharts have been added
    Then the "## Process" section in "skills/arc-capture/SKILL.md" is identical to the original
    And the "## Process" section in "skills/arc-shape/SKILL.md" is identical to the original
    And the "## Process" section in "skills/arc-wave/SKILL.md" is identical to the original
