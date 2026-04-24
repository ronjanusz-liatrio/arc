# Source: docs/specs/15-spec-agent-utilization-upgrade/15-spec-agent-utilization-upgrade.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Frontmatter Contract Layer

  Scenario: Every arc SKILL.md frontmatter parses as valid YAML with the four new fields populated
    Given all 9 "skills/arc-*/SKILL.md" files after the contract layer is applied
    When a YAML parser reads the frontmatter block of each file in turn
    Then each of the 9 frontmatters parses without error
    And each parsed frontmatter contains non-empty values for the keys "requires", "produces", "consumes", and "triggers"
    And each frontmatter still contains the pre-existing keys "name", "description", "user-invocable", and "allowed-tools" in their original shape

  Scenario: parse-frontmatter.sh emits a Mermaid dependency graph with one node per skill
    Given all 9 arc frontmatters have been populated with requires/produces/consumes/triggers
    When the user runs "scripts/parse-frontmatter.sh --format mermaid skills/arc-*/SKILL.md"
    Then the command exits with code 0
    And stdout contains a Mermaid "graph" or "flowchart" declaration
    And the rendered Mermaid contains exactly 9 nodes, one per arc skill
    And every skill that declares a "consumes.from" entry pointing at a sibling skill appears as the target of at least one edge in the graph
    And the total Mermaid block is 50 lines or fewer

  Scenario: parse-frontmatter.sh emits a JSON dependency graph consumable by tooling
    Given all 9 arc frontmatters have been populated
    When the user runs "scripts/parse-frontmatter.sh --format json skills/arc-*/SKILL.md"
    Then the command exits with code 0
    And stdout is a single valid JSON document
    And the JSON document contains an entry for each of the 9 arc skills keyed by skill name
    And each entry contains the fields "requires", "produces", "consumes", and "triggers" populated from the source frontmatter

  Scenario: State predicates in requires.state reflect actual skill preconditions
    Given the populated frontmatter for "skills/arc-wave/SKILL.md"
    When an agent reads "requires.state" for arc-wave
    Then the value asserts "shaped_count >= 1 AND wave_active = false"
    And the populated frontmatter for "skills/arc-ship/SKILL.md" asserts "requires.state" of "idea.status = 'spec-ready' AND validation_status = 'PASS'"

  Scenario: Frontmatter field shapes are documented in references/frontmatter-fields.md
    Given the repository after the contract layer lands
    When a skill author opens "references/frontmatter-fields.md"
    Then the document describes the expected shape of "requires" (files, artifacts, state), "produces" (files, artifacts, state-transition), "consumes" (from list of skill/artifact pairs), and "triggers" (condition, alternates)
    And each field section includes at least one populated example drawn from an existing arc skill

  Scenario: Backward-compatible frontmatter keeps Claude Code plugin installation working
    Given the repository after the contract layer lands
    When a user runs "claude plugin install arc@arc --scope project" against the updated plugin
    Then the plugin install completes without error
    And all 9 arc skills are registered and invocable from the Claude Code CLI as they were before the change
