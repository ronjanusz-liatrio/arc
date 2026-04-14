# Source: docs/specs/11-spec-shape-skill-discovery/11-spec-shape-skill-discovery.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Synthesis Table Integration

  Scenario: Skill Discovery row appears in dimension ratings table when skills are found
    Given a captured idea has been analyzed by all four subagents
    And the feasibility subagent discovered 2 relevant skills from /skillz-find
    When /arc-shape presents the Step 3 synthesis to the user
    Then the dimension ratings table includes a "Skill Discovery" row
    And the Skill Discovery row has columns Dimension, Rating, and Key Finding
    And the Rating column displays "Skills found"
    And the Key Finding column summarizes the top 1-2 most relevant skills by name and recommendation

  Scenario: Skill Discovery row shows "No skills" when search returns zero results
    Given a captured idea has been analyzed by all four subagents
    And the feasibility subagent found zero relevant skills from /skillz-find
    When /arc-shape presents the Step 3 synthesis to the user
    Then the dimension ratings table includes a "Skill Discovery" row
    And the Rating column displays "No skills"
    And the Key Finding column states the search returned no results

  Scenario: Skill Discovery row shows "Skipped" when skillz is not installed
    Given a captured idea has been analyzed by all four subagents
    And the skillz plugin is not installed so skill discovery was skipped
    When /arc-shape presents the Step 3 synthesis to the user
    Then the dimension ratings table includes a "Skill Discovery" row
    And the Rating column displays "Skipped"
    And the Key Finding column states the skip reason

  Scenario: Relevant Skills section lists discovered skills with full metadata
    Given a captured idea has been analyzed with skill discovery enabled
    And /skillz-find returned skills "graphql-codegen" by author "guild" with 1200 weekly installs and recommendation "install"
    And /skillz-find returned skills "schema-validator" by author "fastify" with 800 weekly installs and recommendation "investigate"
    When /arc-shape presents the Step 3 synthesis to the user
    Then a "### Relevant Skills" section appears below the dimension ratings table
    And the section lists "graphql-codegen" with author "guild", install count 1200, and recommendation "install"
    And the section lists "schema-validator" with author "fastify", install count 800, and recommendation "investigate"
    And each skill entry includes a relevance statement connecting the skill to the idea being shaped

  Scenario: Relevant Skills section displays appropriate message when discovery was skipped
    Given a captured idea has been analyzed without skill discovery
    And the skillz plugin was not installed
    When /arc-shape presents the Step 3 synthesis to the user
    Then a "### Relevant Skills" section appears below the dimension ratings table
    And the section displays the skip message instead of an empty table

  Scenario: Relevant Skills section displays appropriate message when no results were found
    Given a captured idea has been analyzed with skill discovery enabled
    And /skillz-find returned zero results
    When /arc-shape presents the Step 3 synthesis to the user
    Then a "### Relevant Skills" section appears below the dimension ratings table
    And the section displays "No relevant skills found on skills.sh for this problem domain"
    And no empty table is rendered
