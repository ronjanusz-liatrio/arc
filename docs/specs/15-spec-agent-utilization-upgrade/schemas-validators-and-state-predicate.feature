# Source: docs/specs/15-spec-agent-utilization-upgrade/15-spec-agent-utilization-upgrade.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Schemas Validators And State Predicate

  Scenario: Four JSON Schema files exist and parse as valid Draft-07 schemas
    Given the repository after this unit lands
    When a JSON Schema CLI validates each file under "schemas/" against Draft-07
    Then "schemas/backlog-entry.schema.json" is reported as a valid Draft-07 schema
    And "schemas/brief.schema.json" is reported as a valid Draft-07 schema
    And "schemas/wave.schema.json" is reported as a valid Draft-07 schema
    And "schemas/roadmap-row.schema.json" is reported as a valid Draft-07 schema

  Scenario: validate-backlog.sh passes on the current repository BACKLOG
    Given the current committed "docs/BACKLOG.md" in the repository
    When the user runs "scripts/validate-backlog.sh docs/BACKLOG.md"
    Then the command exits with code 0
    And stdout or stderr contains no "ERROR" diagnostics

  Scenario: validate-backlog.sh fails with a diagnostic on a fixture missing the brief field
    Given the fixture file "schemas/tests/backlog-missing-brief.md" is present in the repository
    When the user runs "scripts/validate-backlog.sh schemas/tests/backlog-missing-brief.md"
    Then the command exits with code 1
    And the combined stdout and stderr contain a diagnostic that names the missing "brief" field

  Scenario: state.sh emits a non-null state vector as JSON
    Given a repository whose BACKLOG and ROADMAP describe at least one captured idea
    When the user runs "scripts/state.sh | jq .idea_status_counts"
    Then the jq invocation exits with code 0
    And the returned object is non-null
    And the returned object contains the keys "captured", "shaped", "spec_ready", and "shipped"
    And each of those keys has an integer value

  Scenario: state.sh completes within the performance budget on a 50-idea repository
    Given a repository whose "docs/BACKLOG.md" contains 50 idea entries
    When the user runs "scripts/state.sh" once and measures wall-clock duration
    Then the command exits with code 0
    And the measured duration is less than 500 milliseconds

  Scenario: All validator scripts are executable and non-interactive
    Given the repository after this unit lands
    When the user inspects the file mode of each validator script
    Then "scripts/validate-backlog.sh", "scripts/validate-brief.sh", "scripts/validate-roadmap.sh", and "scripts/state.sh" are each executable
    And running each script with valid input produces no interactive prompt and terminates on its own

  Scenario: Validator exit codes distinguish pass, fail, and recoverable
    Given a well-formed artifact, a structurally-broken artifact, and a recoverable-warning artifact exist as test fixtures
    When the user runs the corresponding validator against each of the three fixtures
    Then the well-formed fixture produces exit code 0
    And the structurally-broken fixture produces exit code 1
    And the recoverable-warning fixture produces exit code 2

  Scenario: A scheduled routine can chain validators based on exit codes
    Given a scheduled routine runs "scripts/validate-backlog.sh && scripts/validate-roadmap.sh && scripts/validate-brief.sh docs/briefs/*.md"
    And all three underlying artifacts are well-formed
    When the routine executes the chain
    Then every script in the chain exits with code 0
    And the routine reports overall success
