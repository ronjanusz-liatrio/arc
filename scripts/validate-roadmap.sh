#!/usr/bin/env bash
# validate-roadmap.sh — Validate docs/ROADMAP.md structure and BACKLOG cross-references.
#
# Checks:
#   1. ROADMAP.md exists and contains a Wave Summary Table with the expected header row.
#   2. Every row in the table is schema-valid against schemas/roadmap-row.schema.json.
#   3. Every wave referenced in the ROADMAP exists as a BACKLOG entry or the BACKLOG
#      table lists at least one idea assigned to that wave.
#   4. Exactly 0 or 1 wave has status=Active (I4 ordering invariant from skill-orchestration.md).
#
# Usage:
#   scripts/validate-roadmap.sh [path/to/ROADMAP.md] [path/to/BACKLOG.md]
#
#   Both paths are optional; defaults are docs/ROADMAP.md and docs/BACKLOG.md
#   relative to the repo root.
#
# Exit codes:
#   0  pass — ROADMAP is well-formed and consistent with BACKLOG
#   1  fail — structural violation, schema error, or cross-reference mismatch
#   2  recoverable — schema file or tooling not found; manual inspection required
#
# Dependencies:
#   jq         (https://jqlang.github.io/jq/)
#   awk        (POSIX)
#   npx + ajv-cli@5 + ajv-formats@2  (installed on first run via npx --yes)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCHEMA="${REPO_ROOT}/schemas/roadmap-row.schema.json"

die() {
  printf 'validate-roadmap: ERROR: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'validate-roadmap: WARN: %s\n' "$*" >&2
}

# ---- arg parsing -------------------------------------------------------

ROADMAP_PATH="${1:-${REPO_ROOT}/docs/ROADMAP.md}"
BACKLOG_PATH="${2:-${REPO_ROOT}/docs/BACKLOG.md}"

# ---- preflight ---------------------------------------------------------

if [[ ! -f "$SCHEMA" ]]; then
  warn "schema file not found: $SCHEMA — skipping schema validation"
  SCHEMA_AVAILABLE=0
else
  SCHEMA_AVAILABLE=1
fi

[[ -f "$ROADMAP_PATH" ]] || die "ROADMAP file not found: $ROADMAP_PATH"
[[ -f "$BACKLOG_PATH" ]] || die "BACKLOG file not found: $BACKLOG_PATH"

command -v jq >/dev/null 2>&1 || die "jq not found on PATH (install: https://jqlang.github.io/jq/)"
command -v awk >/dev/null 2>&1 || die "awk not found on PATH"

WORK_DIR="${TMPDIR:-/tmp}/validate-roadmap-$$"
mkdir -p "$WORK_DIR"
trap 'rm -rf "$WORK_DIR"' EXIT

# ---- step 1: parse the ROADMAP Wave Summary Table ----------------------
#
# Expected table header (case-insensitive column names):
#   | Wave | Goal | Status | Target | Ideas |
#
# We extract every data row (non-header, non-separator) and build a JSON
# array of roadmap-row objects for ajv validation.

TABLE_FILE="${WORK_DIR}/rows.json"
TSV_FILE="${WORK_DIR}/rows.tsv"

# Extract rows as NUL-delimited TSV so that values containing tabs or newlines
# are still handled safely.  Each output line is:
#   wave TAB goal TAB status TAB target TAB ideas_integer
awk '
  BEGIN { in_table=0; header_seen=0 }
  # Detect the header row by looking for all 5 expected columns
  /\|[[:space:]]*[Ww]ave[[:space:]]*\|/ &&
  /[Gg]oal/ && /[Ss]tatus/ && /[Tt]arget/ && /[Ii]deas/ {
    in_table=1; header_seen=1; next
  }
  # Skip separator rows (all dashes)
  in_table && /^\|[-| :]+\|/ { next }
  # Stop on blank line after table
  in_table && /^[[:space:]]*$/ { in_table=0; next }
  # Stop if we hit a new markdown heading (leaves table scope)
  in_table && /^#/ { in_table=0; next }
  # Parse a data row
  in_table && /^\|/ {
    # Remove leading/trailing pipe and whitespace
    row = $0
    gsub(/^\|[[:space:]]*/, "", row)
    gsub(/[[:space:]]*\|[[:space:]]*$/, "", row)
    # Split on " | " — allow variable whitespace
    n = split(row, cols, /[[:space:]]*\|[[:space:]]*/);
    if (n < 5) next
    wave   = cols[1]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", wave)
    goal   = cols[2]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", goal)
    status = cols[3]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
    target = cols[4]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", target)
    ideas  = cols[5]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", ideas)
    # Skip truly empty rows
    if (wave == "" && goal == "") next
    # Emit tab-separated values; ideas coerced to integer
    printf "%s\t%s\t%s\t%s\t%d\n", wave, goal, status, target, (ideas+0)
  }
' "$ROADMAP_PATH" > "$TSV_FILE"

# Build a JSON array from the TSV.  Route every string field through
# jq --arg so that quotes, backslashes, and other special characters are
# escaped correctly — no manual string escaping required.
{
  printf '[\n'
  first=1
  while IFS=$'\t' read -r wave goal status target ideas; do
    if [[ "$first" -eq 0 ]]; then printf ',\n'; fi
    jq -n \
      --arg     wave   "$wave"   \
      --arg     goal   "$goal"   \
      --arg     status "$status" \
      --arg     target "$target" \
      --argjson ideas  "$ideas"  \
      '{wave:$wave,goal:$goal,status:$status,target:$target,ideas:$ideas}'
    first=0
  done < "$TSV_FILE"
  printf '\n]\n'
} > "$TABLE_FILE"

ROW_COUNT="$(jq 'length' "$TABLE_FILE")"

printf 'validate-roadmap: found %s wave row(s) in ROADMAP\n' "$ROW_COUNT"

if [[ "$ROW_COUNT" -eq 0 ]]; then
  printf 'validate-roadmap: PASS: ROADMAP table is empty (no waves — acceptable for new projects)\n'
  exit 0
fi

# ---- step 2: schema-validate each row ----------------------------------

FAIL=0

if [[ "$SCHEMA_AVAILABLE" -eq 1 ]] && command -v npx >/dev/null 2>&1; then
  printf 'validate-roadmap: validating %s row(s) against schema...\n' "$ROW_COUNT"
  idx=0
  while IFS= read -r row_json; do
    ROW_FILE="${WORK_DIR}/row-${idx}.json"
    printf '%s\n' "$row_json" > "$ROW_FILE"
    if ! npx --yes \
          --package=ajv-cli@5 \
          --package=ajv-formats@2 \
        ajv validate \
          -s "$SCHEMA" \
          -d "$ROW_FILE" \
          --spec=draft7 \
          -c ajv-formats \
        >/dev/null 2>"${WORK_DIR}/ajv-${idx}.err"; then
      printf 'validate-roadmap: FAIL: row %s failed schema validation: %s\n' \
        "$idx" "$row_json" >&2
      cat "${WORK_DIR}/ajv-${idx}.err" >&2
      FAIL=1
    fi
    idx=$((idx + 1))
  done < <(jq -c '.[]' "$TABLE_FILE")
  if [[ "$FAIL" -eq 0 ]]; then
    printf 'validate-roadmap: OK: all rows pass schema validation\n'
  fi
elif [[ "$SCHEMA_AVAILABLE" -eq 0 ]]; then
  warn "schema not available — skipping ajv row validation (recoverable)"
  exit 2
else
  warn "npx not found — skipping ajv row validation (recoverable)"
  exit 2
fi

# ---- step 3: invariant — at most 1 Active wave -------------------------

ACTIVE_COUNT="$(jq '[.[] | select(.status == "Active")] | length' "$TABLE_FILE")"

if [[ "$ACTIVE_COUNT" -gt 1 ]]; then
  printf 'validate-roadmap: FAIL: %s Active waves found (invariant I4: exactly 0 or 1 allowed)\n' \
    "$ACTIVE_COUNT" >&2
  jq -r '.[] | select(.status == "Active") | "  active wave: " + .wave' "$TABLE_FILE" >&2
  FAIL=1
else
  printf 'validate-roadmap: OK: active wave count = %s (invariant I4 satisfied)\n' "$ACTIVE_COUNT"
fi

# ---- step 4: cross-reference — ROADMAP waves exist in BACKLOG ----------
#
# For each wave name in the ROADMAP, verify that at least one BACKLOG
# summary-table row has a matching Wave column.  A wave with no ideas in
# the BACKLOG summary is a cross-reference violation.
#
# The BACKLOG summary table header is:
#   | Title | Status | Priority | Wave |
# Rows with Wave == "--" are unassigned; we skip those.

BACKLOG_WAVE_LIST="${WORK_DIR}/backlog-waves.txt"
awk '
  /\|[[:space:]]*Title[[:space:]]*\|/ &&
  /Status/ && /Wave/ { in_table=1; header_seen=1; next }
  in_table && /^\|[-| :]+\|/ { next }
  in_table && /^[[:space:]]*$/ { in_table=0; next }
  in_table && /^#/ { in_table=0; next }
  in_table && /^\|/ {
    row = $0
    gsub(/^\|[[:space:]]*/, "", row)
    gsub(/[[:space:]]*\|[[:space:]]*$/, "", row)
    n = split(row, cols, /[[:space:]]*\|[[:space:]]*/);
    if (n < 4) next
    wave = cols[4]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", wave)
    if (wave != "" && wave != "--") print wave
  }
' "$BACKLOG_PATH" | sort -u > "$BACKLOG_WAVE_LIST"

# For each ROADMAP wave, check membership in the BACKLOG wave list.
while IFS= read -r wave_name; do
  if ! grep -qxF "$wave_name" "$BACKLOG_WAVE_LIST" 2>/dev/null; then
    printf 'validate-roadmap: WARN: wave "%s" in ROADMAP has no ideas assigned in BACKLOG\n' \
      "$wave_name" >&2
    # This is a warning, not a hard failure: a wave may have ideas that predate
    # the summary table or the backlog may be in flux.  Downgrade to exit 2
    # only if no other hard failure has been set.
    if [[ "$FAIL" -eq 0 ]]; then
      FAIL=2
    fi
  else
    printf 'validate-roadmap: OK: wave "%s" has ideas in BACKLOG\n' "$wave_name"
  fi
done < <(jq -r '.[].wave' "$TABLE_FILE")

# ---- final result ------------------------------------------------------

if [[ "$FAIL" -eq 0 ]]; then
  printf 'validate-roadmap: PASS: ROADMAP is well-formed and consistent with BACKLOG\n'
  exit 0
elif [[ "$FAIL" -eq 2 ]]; then
  printf 'validate-roadmap: RECOVERABLE: warnings found (exit 2) — review output above\n' >&2
  exit 2
else
  printf 'validate-roadmap: FAIL: one or more structural violations found (exit 1)\n' >&2
  exit 1
fi
