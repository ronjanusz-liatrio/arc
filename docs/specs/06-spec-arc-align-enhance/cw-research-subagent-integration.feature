# Source: docs/specs/06-spec-arc-align-enhance/06-spec-arc-align-enhance.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: cw-research Subagent Integration

  Scenario: Research phase prompt appears as the first interaction
    Given a repository with source code and documentation files
    When the user invokes /arc-align
    Then the first prompt presented is the research phase question
    And the options include "Run deep scan (Recommended)", "Quick scan only", and "Use existing report"

  Scenario: Deep scan produces a research report
    Given a repository with source code and documentation files
    And the user invokes /arc-align
    When the user selects "Run deep scan (Recommended)" at the research phase prompt
    Then the cw-research subagent is invoked with a product-direction discovery focus
    And a research report is saved to docs/specs/research-align/research-align.md
    And the report contains sections on architecture patterns, dependencies, and product-direction content

  Scenario: Quick scan skips research and proceeds to existing behavior
    Given a repository with source code and documentation files
    And the user invokes /arc-align
    When the user selects "Quick scan only" at the research phase prompt
    Then no research subagent is invoked
    And the next prompt is the exclusion configuration step (Step 1)
    And no research report file is created

  Scenario: Use existing report reads prior research
    Given a repository with a prior research report at docs/specs/research-align/research-align.md
    And the user invokes /arc-align
    When the user selects "Use existing report" at the research phase prompt
    Then the existing research report is read and its findings are available for the analysis phase
    And no new research subagent is invoked

  Scenario: Research findings feed into analysis artifact
    Given a repository where the deep scan has completed
    And the research report contains detected architecture patterns and key dependencies
    When the analysis phase (Unit 4) generates docs/align-analysis.md
    Then the analysis artifact references findings from the research report
    And the theme analysis incorporates architecture patterns from the research

  Scenario: SKILL.md includes Agent in allowed-tools
    Given the arc-align SKILL.md has been updated for research integration
    When the user invokes /arc-align and selects "Run deep scan"
    Then the subagent invocation succeeds without a tool permission error
