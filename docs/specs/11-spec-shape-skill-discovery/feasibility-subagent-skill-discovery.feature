# Source: docs/specs/11-spec-shape-skill-discovery/11-spec-shape-skill-discovery.md
# Pattern: CLI/Process
# Recommended test type: Integration

Feature: Feasibility Subagent Skill Discovery

  Scenario: Feasibility subagent invokes skillz-find during shaping
    Given a captured idea exists in docs/BACKLOG.md with title "Add GraphQL API layer"
    And the skillz plugin is installed
    When the user runs /arc-shape "Add GraphQL API layer" and the feasibility subagent executes
    Then the feasibility subagent spawns a sub-Agent that invokes /skillz-find
    And the /skillz-find query contains keyword phrases derived from the idea title and summary

  Scenario: Search query incorporates project context signals
    Given a captured idea exists with title "Add caching layer"
    And the project contains a package.json with "express" and "redis" dependencies
    And the project CLAUDE.md references "Node.js" in the tech stack
    When the feasibility subagent derives the skill discovery search query
    Then the query includes keyword phrases from the idea title and summary
    And the query includes project context signals such as "node" or "express"

  Scenario: Discovered skills appear in feasibility assessment output
    Given a captured idea is being shaped
    And /skillz-find returns results including a skill named "graphql-codegen" with 1200 weekly installs and "pass" security status
    When the feasibility subagent completes its analysis
    Then the feasibility assessment output contains a "#### Relevant Skills" subsection
    And the subsection includes a table row with skill name "graphql-codegen", weekly install count, security status, and recommendation
    And each skill row includes a 1-2 sentence summary of how it relates to the idea

  Scenario: Feasibility subagent parses skillz-find scan report fields
    Given /skillz-find returns a scan report with skill names, weekly install counts, security status, and per-skill recommendations
    When the feasibility subagent parses the /skillz-find output
    Then the extracted data includes the skill name for each result
    And the extracted data includes the weekly install count for each result
    And the extracted data includes the security status for each result
    And the extracted data includes a recommendation of install, investigate, or avoid for each result

  Scenario: Zero results produces informational message
    Given a captured idea is being shaped with title "Quantum entanglement debugger"
    And /skillz-find returns zero results for the derived query
    When the feasibility subagent completes its analysis
    Then the "#### Relevant Skills" subsection states "No relevant skills found on skills.sh for this problem domain"
