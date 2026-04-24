#!/usr/bin/env bash
# validate-brief.sh — Validate a brief artifact for a named idea in BACKLOG.
#
# Checks that:
#   1. The idea exists in BACKLOG.md with status=shaped.
#   2. A brief section is present with all 5 required fields (problem,
#      proposed_solution, success_criteria, constraints, assumptions).
#   3. Each field is non-trivial (satisfies schemas/brief.schema.json via ajv-cli).
#
# Usage:
#   scripts/validate-brief.sh "<idea-title>" [path/to/BACKLOG.md]
#
#   <idea-title>     Exact title string matching the "## <title>" heading in BACKLOG.md.
#   BACKLOG.md path  Optional. Defaults to docs/BACKLOG.md relative to repo root.
#
# Exit codes:
#   0  pass — idea is shaped and brief is schema-valid
#   1  fail — idea absent, wrong status, or schema violation
#   2  recoverable — schema file or tooling not found; manual inspection required
#
# Dependencies:
#   jq         (https://jqlang.github.io/jq/)
#   awk        (POSIX)
#   npx + ajv-cli@5 + ajv-formats@2  (installed on first run via npx --yes)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCHEMA="${REPO_ROOT}/schemas/brief.schema.json"

die() {
  printf 'validate-brief: ERROR: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'validate-brief: WARN: %s\n' "$*" >&2
}

usage() {
  printf 'Usage: %s "<idea-title>" [path/to/BACKLOG.md]\n' "$0" >&2
  exit 1
}

# ---- arg parsing -------------------------------------------------------

[[ $# -ge 1 ]] || usage

IDEA_TITLE="$1"
BACKLOG_PATH="${2:-${REPO_ROOT}/docs/BACKLOG.md}"

[[ -n "$IDEA_TITLE" ]] || die "idea-title argument must not be empty"

# ---- preflight ---------------------------------------------------------

if [[ ! -f "$SCHEMA" ]]; then
  warn "schema file not found: $SCHEMA — skipping schema validation"
  SCHEMA_AVAILABLE=0
else
  SCHEMA_AVAILABLE=1
fi

if [[ ! -f "$BACKLOG_PATH" ]]; then
  die "BACKLOG file not found: $BACKLOG_PATH"
fi

command -v jq >/dev/null 2>&1 || die "jq not found on PATH (install: https://jqlang.github.io/jq/)"
command -v awk >/dev/null 2>&1 || die "awk not found on PATH"

WORK_DIR="${TMPDIR:-/tmp}/validate-brief-$$"
mkdir -p "$WORK_DIR"
trap 'rm -rf "$WORK_DIR"' EXIT

# ---- step 1: verify idea exists in BACKLOG with status=shaped ----------

# Build a safe regex-safe version of the title for awk section matching.
# We locate the "## <title>" heading and then scan the metadata block.

SECTION_FILE="${WORK_DIR}/section.md"
awk -v title="$IDEA_TITLE" '
  BEGIN { found=0; in_section=0; depth=0 }
  /^## / {
    if (in_section) { exit }
    heading = substr($0, 4)
    # Trim leading/trailing whitespace from heading
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", heading)
    if (heading == title) { in_section=1; found=1; print; next }
  }
  in_section { print }
  END { if (!found) { exit 1 } }
' "$BACKLOG_PATH" > "$SECTION_FILE" 2>/dev/null || {
  printf 'validate-brief: FAIL: idea "%s" not found in %s\n' "$IDEA_TITLE" "$BACKLOG_PATH" >&2
  exit 1
}

if [[ ! -s "$SECTION_FILE" ]]; then
  printf 'validate-brief: FAIL: idea "%s" not found in %s\n' "$IDEA_TITLE" "$BACKLOG_PATH" >&2
  exit 1
fi

# Extract the status field from the metadata list items.
# Uses portable 2-arg awk match() + substr() so the script works on
# stock macOS /usr/bin/awk (BSD awk); gawk's 3-arg match(s, re, arr) is not
# available there.
IDEA_STATUS="$(awk '
  /^- \*\*Status:\*\*/ {
    # Drop the "- **Status:**" prefix (and surrounding whitespace), then take
    # everything up to the first whitespace as the status token.
    line = $0
    sub(/.*\*\*Status:\*\*[[:space:]]*/, "", line)
    sub(/[[:space:]]+$/, "", line)
    if (match(line, /^[^[:space:]]+/)) {
      print substr(line, RSTART, RLENGTH)
      exit
    }
    # Fallback: whole remaining line.
    print line
    exit
  }
' "$SECTION_FILE")"

if [[ "$IDEA_STATUS" != "shaped" ]]; then
  printf 'validate-brief: FAIL: idea "%s" has status="%s" (expected "shaped")\n' \
    "$IDEA_TITLE" "$IDEA_STATUS" >&2
  exit 1
fi

printf 'validate-brief: OK: idea "%s" found with status=shaped\n' "$IDEA_TITLE"

# ---- step 2: extract the brief block from the section ------------------
#
# Briefs live as a "### Brief" sub-section (or a YAML/JSON code fence
# labelled "brief") inside the idea's ## section.  We support two forms:
#
#   Form A — prose sub-section with "- **field:**" list items (current format)
#   Form B — a fenced code block labelled ```json or ```yaml in the brief section

BRIEF_FILE="${WORK_DIR}/brief.json"

# Try Form B first: look for a JSON code fence within the section.
JSON_BRIEF="$(awk '
  /^```json/ { inside=1; content=""; next }
  /^```/ && inside { inside=0; print content; exit }
  inside { content = content (content ? "\n" : "") $0 }
' "$SECTION_FILE")"

if [[ -n "$JSON_BRIEF" ]]; then
  printf '%s\n' "$JSON_BRIEF" > "$BRIEF_FILE"
else
  # Form A — construct a JSON object from prose "- **field:** value" lines.
  # The 5 required fields: problem, proposed_solution, success_criteria,
  # constraints, assumptions. wave_assignment defaults to "Unassigned" if absent.
  # open_questions defaults to "None" if absent.
  PROBLEM="$(awk '/^\*\*Problem:\*\*|^- \*\*Problem:\*\*/ { sub(/.*\*\*Problem:\*\*[[:space:]]*/, ""); gsub(/[[:space:]]+$/, ""); print; exit }' "$SECTION_FILE")"
  PROPOSED="$(awk '/^\*\*Proposed[_ ]Solution:\*\*|^- \*\*Proposed[_ ]Solution:\*\*/ { sub(/.*\*\*Proposed[_ ]Solution:\*\*[[:space:]]*/, ""); gsub(/[[:space:]]+$/, ""); print; exit }' "$SECTION_FILE")"
  WAVE_ASSIGN="$(awk '/^\*\*Wave[_ ]Assignment:\*\*|^- \*\*Wave[_ ]Assignment:\*\*/ { sub(/.*\*\*Wave[_ ]Assignment:\*\*[[:space:]]*/, ""); gsub(/[[:space:]]+$/, ""); print; exit }' "$SECTION_FILE")"
  [[ -n "$WAVE_ASSIGN" ]] || WAVE_ASSIGN="Unassigned"

  # For array fields, collect bullet lines under the heading until the next heading.
  extract_bullet_array() {
    local heading_pattern="$1"
    awk -v pat="$heading_pattern" '
      $0 ~ pat { in_block=1; next }
      in_block && /^###|^## |^- \*\*[A-Z]/ { in_block=0 }
      in_block && /^  - / { sub(/^  - /, ""); gsub(/[[:space:]]+$/, ""); print }
      in_block && /^- / && !/^- \*\*/ { sub(/^- /, ""); gsub(/[[:space:]]+$/, ""); print }
    ' "$SECTION_FILE"
  }

  # Build JSON with jq.
  SC_ARRAY="$(extract_bullet_array '\*\*Success[_ ]Criteria')"
  CON_ARRAY="$(extract_bullet_array '\*\*Constraints')"
  ASS_ARRAY="$(extract_bullet_array '\*\*Assumptions')"
  OQ_ARRAY="$(extract_bullet_array '\*\*Open[_ ]Questions')"

  {
    jq -n \
      --arg title "$IDEA_TITLE" \
      --arg problem "$PROBLEM" \
      --arg proposed "$PROPOSED" \
      --arg wave "$WAVE_ASSIGN" \
      --argjson sc "$(printf '%s\n' "$SC_ARRAY" | jq -R . | jq -s 'map(select(. != ""))')" \
      --argjson con "$(printf '%s\n' "$CON_ARRAY" | jq -R . | jq -s 'map(select(. != ""))')" \
      --argjson ass "$(printf '%s\n' "$ASS_ARRAY" | jq -R . | jq -s 'map(select(. != ""))')" \
      --argjson oq "$(printf '%s\n' "$OQ_ARRAY" | jq -R . | jq -s 'map(select(. != "")) | if length == 0 then "None" else . end')" \
      '{
        title: $title,
        problem: $problem,
        proposed_solution: $proposed,
        success_criteria: $sc,
        constraints: (if ($con | length) == 0 then ["No constraints identified"] else $con end),
        assumptions: (if ($ass | length) == 0 then ["No assumptions identified"] else $ass end),
        wave_assignment: $wave,
        open_questions: $oq
      }'
  } > "$BRIEF_FILE" 2>/dev/null || {
    warn "could not build JSON from prose brief for idea \"$IDEA_TITLE\""
    printf 'validate-brief: FAIL: brief fields not extractable from BACKLOG section\n' >&2
    exit 1
  }
fi

# ---- step 3: validate required fields are non-trivial (pre-schema check) ------

# Verify the 5 mandatory fields are present and non-empty before calling ajv.
# String fields are checked for empty/null; array fields are checked for length == 0.
MISSING_FIELDS=""
for field in title problem proposed_solution; do
  val="$(jq -r --arg f "$field" '.[$f] // empty' "$BRIEF_FILE" 2>/dev/null)"
  if [[ -z "$val" ]] || [[ "$val" == "null" ]]; then
    MISSING_FIELDS="${MISSING_FIELDS} ${field}"
  fi
done
for field in success_criteria constraints assumptions; do
  len="$(jq --arg f "$field" '.[$f] | if type == "array" then length else 0 end' "$BRIEF_FILE" 2>/dev/null)"
  if [[ -z "$len" ]] || [[ "$len" == "0" ]]; then
    MISSING_FIELDS="${MISSING_FIELDS} ${field}"
  fi
done

if [[ -n "$MISSING_FIELDS" ]]; then
  printf 'validate-brief: FAIL: missing or empty brief fields:%s\n' "$MISSING_FIELDS" >&2
  exit 1
fi

printf 'validate-brief: OK: all 5 required brief fields present\n'

# ---- step 4: schema validation via ajv-cli -----------------------------

if [[ "$SCHEMA_AVAILABLE" -eq 0 ]]; then
  warn "schema not available — skipping ajv validation (exit 2 = recoverable)"
  exit 2
fi

command -v npx >/dev/null 2>&1 || {
  warn "npx not found — skipping ajv validation (exit 2 = recoverable)"
  exit 2
}

printf 'validate-brief: running ajv schema validation...\n'
if npx --yes \
      --package=ajv-cli@5 \
      --package=ajv-formats@2 \
    ajv validate \
      -s "$SCHEMA" \
      -d "$BRIEF_FILE" \
      --spec=draft7 \
      -c ajv-formats \
    2>"${WORK_DIR}/ajv.err"; then
  printf 'validate-brief: PASS: brief for "%s" is schema-valid\n' "$IDEA_TITLE"
  exit 0
else
  printf 'validate-brief: FAIL: brief schema validation failed\n' >&2
  cat "${WORK_DIR}/ajv.err" >&2
  exit 1
fi
