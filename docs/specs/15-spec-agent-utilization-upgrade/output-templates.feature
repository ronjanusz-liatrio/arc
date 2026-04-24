# Source: docs/specs/15-spec-agent-utilization-upgrade/15-spec-agent-utilization-upgrade.md
# Pattern: State + CLI/Process
# Recommended test type: Integration

Feature: Output Templates

  Scenario: Three shared output templates exist in the templates directory
    Given the repository after this unit lands
    When a reader lists the files under "templates/"
    Then "templates/wave-report.tmpl.md" is present
    And "templates/audit-report.tmpl.md" is present
    And "templates/shape-report.tmpl.md" is present

  Scenario: Placeholder syntax in new templates matches the existing arc convention
    Given a reader opens each new template in turn
    When the reader scans each template for placeholder tokens
    Then every placeholder uses the "{SlotName}" convention found in "templates/BACKLOG.tmpl.md" and "templates/VISION.tmpl.md"
    And no placeholder uses a divergent syntax such as "<<Slot>>", "${Slot}", or "[[Slot]]"

  Scenario: Each template ends with a self-checkable Acceptance Criteria list
    Given a reader opens "templates/wave-report.tmpl.md", "templates/audit-report.tmpl.md", and "templates/shape-report.tmpl.md" in turn
    When the reader scrolls to the last section of each template
    Then each template's final section is titled "Acceptance Criteria"
    And each Acceptance Criteria section contains between 3 and 5 bullet items
    And each bullet is phrased so that an agent running the corresponding skill can mark it pass or fail against the generated report

  Scenario: arc-wave produces its Step 10 report by rendering the shared template
    Given an agent runs the arc-wave skill through Step 10 against a repository with at least one shaped idea
    When the generated wave report is written to its destination
    Then the generated report renders every "{SlotName}" in "templates/wave-report.tmpl.md" with a concrete value
    And no literal "{SlotName}" placeholder remains in the rendered output
    And the rendered sections appear in the same order as the template defines

  Scenario: The arc-wave SKILL.md references the wave-report template rather than inline-generating its body
    Given the repository after this unit lands
    When the user runs "grep -l wave-report.tmpl.md skills/arc-wave/SKILL.md"
    Then the command exits with code 0
    And stdout names "skills/arc-wave/SKILL.md"

  Scenario: Template-sourced arc-audit and arc-shape reports match their prior inline shapes
    Given a baseline audit report generated before this unit (inline) and a baseline shape report generated before this unit (inline)
    When the same inputs are re-run after arc-audit and arc-shape are switched to use the shared templates
    Then the resulting audit report contains the same section headings and ordering as the pre-unit baseline
    And the resulting shape report contains the same section headings and ordering as the pre-unit baseline
    And no previously-reported field is missing from the rendered output
