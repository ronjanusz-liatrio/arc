# Source: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md
# Pattern: State (template file creation with YAML frontmatter and phase-graduated content)
# Recommended test type: Integration

Feature: Product Artifact Templates

  Scenario: VISION template has correct frontmatter and phase-graduated structure
    Given the arc plugin is installed in a project
    When the user reads templates/VISION.tmpl.md
    Then the YAML frontmatter contains role set to "always-required"
    And the YAML frontmatter contains artifact set to "VISION"
    And the YAML frontmatter contains output_path set to "docs/VISION.md"
    And the document contains phase-graduated sections from Spike through Maturity

  Scenario: CUSTOMER template includes persona definitions and JTBD statements
    Given the arc plugin is installed in a project
    When the user reads templates/CUSTOMER.tmpl.md
    Then the YAML frontmatter contains role set to "always-required"
    And the YAML frontmatter contains artifact set to "CUSTOMER"
    And the YAML frontmatter contains output_path set to "docs/CUSTOMER.md"
    And the document contains phase-graduated sections with persona definitions
    And the document contains Jobs-To-Be-Done statement format

  Scenario: ROADMAP template includes wave definitions and Mermaid diagrams with Liatrio colors
    Given the arc plugin is installed in a project
    When the user reads templates/ROADMAP.tmpl.md
    Then the YAML frontmatter contains role set to "product-leadership"
    And the YAML frontmatter contains artifact set to "ROADMAP"
    And the YAML frontmatter contains output_path set to "docs/ROADMAP.md"
    And the document contains wave definition sections
    And the Mermaid diagrams use Liatrio brand colors including "#11B5A4", "#E8662F", and "#1B2A3D"

  Scenario: BACKLOG template specifies inline section format with summary table
    Given the arc plugin is installed in a project
    When the user reads templates/BACKLOG.tmpl.md
    Then the YAML frontmatter contains role set to "product-leadership"
    And the YAML frontmatter contains artifact set to "BACKLOG"
    And the YAML frontmatter contains output_path set to "docs/BACKLOG.md"
    And the document specifies a summary table header format
    And the document specifies "## {Title}" section format for individual ideas
    And the document distinguishes between captured idea stubs and shaped idea full brief subsections

  Scenario: All templates follow Temper phase-graduated conventions
    Given the arc plugin is installed in a project
    When the user reads each template in the templates directory
    Then every template contains YAML frontmatter with role, artifact, and output_path fields
    And every template contains phase-graduated content spanning Spike through Maturity
    And every template includes required sections per phase with content guidance
