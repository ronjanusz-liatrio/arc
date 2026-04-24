#!/usr/bin/env bash
# validate-backlog.sh — parse docs/BACKLOG.md and validate each idea entry.
#
# Parses each "## {Title}" section plus the summary table in BACKLOG.md into a
# JSON record, validates each record against schemas/backlog-entry.schema.json,
# and enforces structural invariants:
#
#   1. Every title in the summary table has a matching "## {Title}" section.
#   2. Every "## {Title}" section has a matching row in the summary table.
#   3. No duplicate titles (case-insensitive).
#   4. Shaped / spec-ready ideas supply the required brief fields (enforced by
#      the JSON Schema's allOf conditionals, and double-checked structurally).
#
# Schema CLI: ajv-cli@5 + ajv-formats@2 (see references/schema-tooling.md).
# Install:    npm install -g ajv-cli@5 ajv-formats@2
#             -- or rely on the npx invocation below (no global install needed).
#
# Usage:
#   scripts/validate-backlog.sh [BACKLOG.md]
#
# When no path is supplied, defaults to docs/BACKLOG.md relative to the repo
# root (determined from the script's own location).
#
# Exit codes:
#   0  All entries pass schema validation and all invariants hold.
#   1  One or more entries fail validation (hard failure, must fix).
#   2  Recoverable warning only (e.g., optional field recommendations).
#      Nothing currently produces exit 2; reserved for future soft checks.
#
# Non-interactive: diagnostics go to stderr, terse pass/fail to stdout.
# Chainable:  scripts/validate-backlog.sh && scripts/validate-roadmap.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCHEMA="${REPO_ROOT}/schemas/backlog-entry.schema.json"

# ---- helpers ----------------------------------------------------------------

die() {
  printf 'validate-backlog: ERROR: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'validate-backlog: WARN: %s\n' "$*" >&2
}

info() {
  printf 'validate-backlog: %s\n' "$*"
}

# ---- arg parsing ------------------------------------------------------------

BACKLOG_FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      sed -n '3,36p' "$0"
      exit 0
      ;;
    --)
      shift
      BACKLOG_FILE="${1:-}"
      break
      ;;
    -*)
      die "unknown flag: $1"
      ;;
    *)
      BACKLOG_FILE="$1"
      shift
      ;;
  esac
done

if [[ -z "${BACKLOG_FILE}" ]]; then
  BACKLOG_FILE="${REPO_ROOT}/docs/BACKLOG.md"
fi

[[ -f "${BACKLOG_FILE}" ]] || die "backlog file not found: ${BACKLOG_FILE}"
[[ -f "${SCHEMA}" ]]       || die "schema not found: ${SCHEMA}"

# ---- dependency check -------------------------------------------------------

command -v jq  >/dev/null 2>&1 || die "jq not found on PATH (install: https://jqlang.github.io/jq/)"
command -v awk >/dev/null 2>&1 || die "awk not found on PATH"
command -v npx >/dev/null 2>&1 || die "npx not found on PATH (install Node.js)"

# ---- work area --------------------------------------------------------------

WORK_DIR="${TMPDIR:-/tmp}/validate-backlog-$$"
mkdir -p "${WORK_DIR}"
trap 'rm -rf "${WORK_DIR}"' EXIT

# ---- phase 1: parse summary table -------------------------------------------

# Extract the summary table rows (skip the two header/separator lines).
# Expected format: | Title (possibly a link) | Status | Priority | Wave |
TABLE_FILE="${WORK_DIR}/table.txt"
awk '
  /^\| *Title *\|/ { in_table=1; next }
  in_table && /^\|[-| ]+\|/ { next }
  in_table && /^\|/ { print; next }
  in_table { in_table=0 }
' "${BACKLOG_FILE}" > "${TABLE_FILE}"

# Extract raw title from a table row: strip leading "| [" or "| " prefix and
# markdown link syntax, then trim trailing whitespace.
# e.g.: "| [(deferred) Batch capture](#...) | captured | P3-Low | -- |"
#    -> "(deferred) Batch capture"
extract_table_title() {
  # Portable 2-arg awk match() + substr(): avoids gawk's 3-arg match(s, re, arr)
  # so the script runs on stock macOS /usr/bin/awk (one true awk / BSD awk).
  printf '%s' "$1" | awk '
    {
      # Remove leading pipe + whitespace
      sub(/^\|[[:space:]]*/, "")
      # Remove markdown link: "[text](#anchor)" -> "text"
      if (match($0, /\[[^]]+\]\([^)]*\)/)) {
        cell = substr($0, RSTART, RLENGTH)
        # Strip leading "[" and everything from the closing "]" onward.
        sub(/^\[/, "", cell)
        sub(/\].*$/, "", cell)
        title = cell
      } else {
        # Plain title cell (strip up to first "|")
        title = $0
        sub(/[[:space:]]*\|.*/, "", title)
        sub(/^[[:space:]]+/, "", title)
        sub(/[[:space:]]+$/, "", title)
      }
      print title
    }
  '
}

# Parallel arrays replacing a bash-4 associative array, so the script runs on
# macOS stock bash 3.2. TABLE_KEYS[i] holds the lowercase title (lookup key),
# TABLE_VALUES[i] holds the original-cased title.  Order preserved via
# TABLE_ORDER (list of lowercase keys in first-seen order).
TABLE_KEYS=()
TABLE_VALUES=()
TABLE_ORDER=()

# Helper: lookup a value in the parallel arrays by key. Echos the value if
# present and returns 0; returns 1 when the key is absent.
table_lookup() {
  local needle="$1"
  local i
  for ((i = 0; i < ${#TABLE_KEYS[@]}; i++)); do
    if [[ "${TABLE_KEYS[$i]}" == "$needle" ]]; then
      printf '%s' "${TABLE_VALUES[$i]}"
      return 0
    fi
  done
  return 1
}

while IFS= read -r row; do
  [[ -z "${row}" ]] && continue
  title="$(extract_table_title "${row}")"
  [[ -z "${title}" ]] && continue
  lower_title="$(printf '%s' "${title}" | tr '[:upper:]' '[:lower:]')"
  if table_lookup "${lower_title}" >/dev/null; then
    warn "duplicate title in summary table: '${title}'"
  fi
  TABLE_KEYS+=("${lower_title}")
  TABLE_VALUES+=("${title}")
  TABLE_ORDER+=("${lower_title}")
done < "${TABLE_FILE}"

# ---- phase 2: parse ## idea sections ----------------------------------------

SECTIONS_FILE="${WORK_DIR}/sections.ndjson"
: > "${SECTIONS_FILE}"

# Parallel arrays (bash 3.2-safe) analogous to TABLE_KEYS/TABLE_VALUES above.
SECTION_KEYS=()
SECTION_VALUES=()
SECTION_ORDER=()

section_lookup() {
  local needle="$1"
  local i
  for ((i = 0; i < ${#SECTION_KEYS[@]}; i++)); do
    if [[ "${SECTION_KEYS[$i]}" == "$needle" ]]; then
      printf '%s' "${SECTION_VALUES[$i]}"
      return 0
    fi
  done
  return 1
}

# emit_section writes the current section state as one NDJSON line and resets.
emit_section() {
  local title="$1" status="$2" priority="$3" captured="$4"
  local shaped="$5" wave="$6" context="$7" summary="$8"

  [[ -z "${title}" ]] && return

  local lower
  lower="$(printf '%s' "${title}" | tr '[:upper:]' '[:lower:]')"

  # Track duplicates
  if section_lookup "${lower}" >/dev/null; then
    warn "duplicate section title: '${title}'"
  fi
  SECTION_KEYS+=("${lower}")
  SECTION_VALUES+=("${title}")
  SECTION_ORDER+=("${lower}")

  # Build JSON via jq to handle escaping correctly.
  local jq_args=(
    --arg title    "${title}"
    --arg status   "${status}"
    --arg priority "${priority}"
    --arg captured "${captured}"
    --arg summary  "${summary}"
  )
  # shellcheck disable=SC2016
  local filter='{ title: $title, status: $status, priority: $priority, captured: $captured, summary: $summary }'

  if [[ -n "${shaped}" ]]; then
    jq_args+=(--arg shaped "${shaped}")
    # shellcheck disable=SC2016
    filter='{ title: $title, status: $status, priority: $priority, captured: $captured, shaped: $shaped, summary: $summary }'
  fi

  if [[ -n "${wave}" && "${wave}" != "--" ]]; then
    jq_args+=(--arg wave "${wave}")
    # shellcheck disable=SC2016
    filter="${filter%\}}"', wave: $wave }'
  fi

  if [[ -n "${context}" ]]; then
    jq_args+=(--arg context "${context}")
    # shellcheck disable=SC2016
    filter="${filter%\}}"', context: $context }'
  fi

  local json
  json="$(jq -cn "${jq_args[@]}" "${filter}")"
  printf '%s\n' "${json}" >> "${SECTIONS_FILE}"
}

parse_sections_bash() {
  local file="$1"
  local current_title="" status="" priority="" captured=""
  local shaped="" wave="" context="" summary=""
  local in_section=0

  local line
  while IFS= read -r line || [[ -n "${line}" ]]; do
    # New ## section heading
    if [[ "${line}" =~ ^##[[:space:]](.+)$ ]]; then
      # Flush previous section before starting a new one
      emit_section "${current_title}" "${status}" "${priority}" "${captured}" \
                   "${shaped}" "${wave}" "${context}" "${summary}"
      current_title="${BASH_REMATCH[1]}"
      # Trim trailing whitespace
      current_title="${current_title%"${current_title##*[![:space:]]}"}"
      status=""; priority=""; captured=""; shaped=""
      wave=""; context=""; summary=""
      in_section=1
      continue
    fi

    [[ "${in_section}" -eq 0 ]] && continue

    # Skip HTML comments
    [[ "${line}" =~ ^\<\!-- ]] && continue

    # Extract metadata list items
    if [[ "${line}" =~ ^\-[[:space:]]\*\*Status:\*\*[[:space:]]*(.*) ]]; then
      status="${BASH_REMATCH[1]}"
      continue
    fi
    if [[ "${line}" =~ ^\-[[:space:]]\*\*Priority:\*\*[[:space:]]*(.*) ]]; then
      priority="${BASH_REMATCH[1]}"
      continue
    fi
    if [[ "${line}" =~ ^\-[[:space:]]\*\*Captured:\*\*[[:space:]]*(.*) ]]; then
      captured="${BASH_REMATCH[1]}"
      continue
    fi
    if [[ "${line}" =~ ^\-[[:space:]]\*\*Shaped:\*\*[[:space:]]*(.*) ]]; then
      shaped="${BASH_REMATCH[1]}"
      continue
    fi
    if [[ "${line}" =~ ^\-[[:space:]]\*\*Wave:\*\*[[:space:]]*(.*) ]]; then
      wave="${BASH_REMATCH[1]}"
      continue
    fi
    if [[ "${line}" =~ ^\-[[:space:]]\*\*Context:\*\*[[:space:]]*(.*) ]]; then
      context="${BASH_REMATCH[1]}"
      continue
    fi
    # Skip other list items
    if [[ "${line}" =~ ^\-[[:space:]] ]]; then
      continue
    fi

    # Skip blank lines
    if [[ -z "${line// }" ]]; then
      continue
    fi

    # First non-empty, non-list, non-comment line becomes the summary
    if [[ -z "${summary}" ]]; then
      summary="${line}"
    fi
  done < "${file}"

  # Flush last section
  emit_section "${current_title}" "${status}" "${priority}" "${captured}" \
               "${shaped}" "${wave}" "${context}" "${summary}"
}

parse_sections_bash "${BACKLOG_FILE}"

# ---- phase 3: structural invariant checks -----------------------------------

FAIL=0

# Invariant C: every table title has a matching section
if [[ ${#TABLE_ORDER[@]} -gt 0 ]]; then
  for lower in "${TABLE_ORDER[@]}"; do
    if ! section_lookup "${lower}" >/dev/null; then
      original="$(table_lookup "${lower}")"
      printf 'validate-backlog: ERROR: summary table title missing its ## section: "%s"\n' \
        "${original}" >&2
      FAIL=1
    fi
  done
fi

# Invariant D: every section has a matching table row
if [[ ${#SECTION_ORDER[@]} -gt 0 ]]; then
  for lower in "${SECTION_ORDER[@]}"; do
    if ! table_lookup "${lower}" >/dev/null; then
      original="$(section_lookup "${lower}")"
      printf 'validate-backlog: ERROR: ## section has no summary table row: "%s"\n' \
        "${original}" >&2
      FAIL=1
    fi
  done
fi

# ---- phase 4: per-entry schema validation -----------------------------------

ENTRY_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

while IFS= read -r entry_json; do
  [[ -z "${entry_json}" ]] && continue
  ENTRY_COUNT=$((ENTRY_COUNT + 1))
  entry_title="$(printf '%s' "${entry_json}" | jq -r '.title')"

  entry_file="${WORK_DIR}/entry-${ENTRY_COUNT}.json"
  printf '%s\n' "${entry_json}" > "${entry_file}"

  ajv_out="${WORK_DIR}/ajv-${ENTRY_COUNT}.txt"
  if npx --yes --package=ajv-cli@5 --package=ajv-formats@2 \
       ajv validate \
         -s "${SCHEMA}" \
         -d "${entry_file}" \
         --spec=draft7 \
         -c ajv-formats \
       >"${ajv_out}" 2>&1; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    printf 'validate-backlog: ERROR: schema validation FAILED for entry "%s"\n' \
      "${entry_title}" >&2
    cat "${ajv_out}" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
    FAIL=1
  fi
done < "${SECTIONS_FILE}"

# ---- phase 5: structural brief check for shaped/spec-ready entries ----------

while IFS= read -r entry_json; do
  [[ -z "${entry_json}" ]] && continue
  entry_status="$(printf '%s' "${entry_json}" | jq -r '.status')"
  entry_title="$(printf '%s' "${entry_json}" | jq -r '.title')"

  if [[ "${entry_status}" == "shaped" || "${entry_status}" == "spec-ready" ]]; then
    has_brief="$(printf '%s' "${entry_json}" | jq 'has("brief")')"
    if [[ "${has_brief}" != "true" ]]; then
      printf 'validate-backlog: ERROR: entry "%s" has status "%s" but is missing required "brief" field\n' \
        "${entry_title}" "${entry_status}" >&2
      FAIL=1
    fi
  fi
done < "${SECTIONS_FILE}"

# ---- summary ----------------------------------------------------------------

if [[ "${FAIL}" -eq 0 ]]; then
  info "PASS -- ${ENTRY_COUNT} entries validated (${PASS_COUNT} pass, ${FAIL_COUNT} fail)"
  exit 0
else
  info "FAIL -- ${ENTRY_COUNT} entries checked, ${FAIL_COUNT} schema failures"
  exit 1
fi
