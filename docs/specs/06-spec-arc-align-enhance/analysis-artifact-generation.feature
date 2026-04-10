# Source: docs/specs/06-spec-arc-assess-enhance/06-spec-arc-assess-enhance.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Analysis Artifact Generation

  Scenario: Analysis artifact is generated after discovery
    Given a repository where /arc-assess has completed all discovery phases
    When the analysis phase executes
    Then docs/align-analysis.md is created before the import confirmation prompt

  Scenario: Discovery summary counts by source type and target artifact
    Given a repository with discoveries from markdown keywords, spec extraction, and code comments
    When the analysis phase generates docs/align-analysis.md
    Then the Discovery Summary section shows counts broken down by source type
    And the Discovery Summary section shows counts broken down by target artifact (BACKLOG, VISION, CUSTOMER)

  Scenario: Gap analysis identifies missing VISION content
    Given a repository with no mission, vision, or north-star content in any file
    When the analysis phase generates docs/align-analysis.md
    Then the Gap Analysis section flags VISION as a gap
    And the gap description states that no vision content was found

  Scenario: Gap analysis identifies missing CUSTOMER content
    Given a repository with no persona or audience definitions
    When the analysis phase generates docs/align-analysis.md
    Then the Gap Analysis section flags CUSTOMER as a gap

  Scenario: Gap analysis identifies ROADMAP absence
    Given a repository with no phased planning content
    When the analysis phase generates docs/align-analysis.md
    Then the Gap Analysis section flags ROADMAP as absent
    And notes that arc-assess does not populate ROADMAP directly

  Scenario: Gap analysis reports BACKLOG distribution
    Given a repository where 12 TODO comments were found in src/auth/ and 2 in src/utils/
    When the analysis phase generates docs/align-analysis.md
    Then the Gap Analysis BACKLOG section notes the concentration of items in src/auth/

  Scenario: Theme analysis groups related discoveries
    Given a repository with 3 specs and 5 TODO comments that all relate to authentication
    When the analysis phase generates docs/align-analysis.md
    Then the Theme Analysis section groups those 8 items under an authentication theme
    And suggests a potential wave grouping for the authentication topic

  Scenario: Recommendations list suggested next actions
    Given a repository with no VISION content and concentrated TODOs in one module
    When the analysis phase generates docs/align-analysis.md
    Then the Recommendations section includes a suggestion to create a VISION artifact
    And includes a suggestion to shape the concentrated TODOs as a single initiative
    And recommendations are presented as an ordered list

  Scenario: Research report findings are incorporated when available
    Given a repository where the cw-research deep scan completed and produced a research report
    And the research report identifies a microservices architecture pattern
    When the analysis phase generates docs/align-analysis.md
    Then the Research Integration section cross-references architecture patterns with discoveries
    And flags architectural areas with no corresponding product-direction coverage

  Scenario: Analysis works without a research report
    Given a repository where the user selected "Quick scan only" and no research report exists
    When the analysis phase generates docs/align-analysis.md
    Then the analysis artifact is generated successfully without a Research Integration section
    And the remaining sections (Discovery Summary, Gap Analysis, Theme Analysis, Recommendations) are fully populated

  Scenario: Inline summary is presented before the import prompt
    Given a repository where the analysis phase has completed
    When the system presents the import confirmation prompt
    Then a condensed inline summary appears before the prompt
    And the summary includes the top 3 recommendations
    And the summary includes gap analysis results
    And the summary is under 20 lines

  Scenario: Analysis artifact contains a Mermaid distribution diagram
    Given a repository with discoveries from multiple source types and target artifacts
    When the analysis phase generates docs/align-analysis.md
    Then the artifact contains a Mermaid diagram showing discovery distribution
    And the diagram uses Liatrio brand colors

  Scenario: Analysis artifact is overwritten on subsequent runs
    Given a repository where /arc-assess was previously run and docs/align-analysis.md exists
    When the user runs /arc-assess again and the analysis phase completes
    Then docs/align-analysis.md is overwritten with fresh analysis
    And the content reflects the current discovery results, not appended history
