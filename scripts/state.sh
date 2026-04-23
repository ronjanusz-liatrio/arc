#!/usr/bin/env bash
set -euo pipefail

# state.sh -- emit the current Arc project state vector as JSON on stdout.
#
# The state vector is the minimum project state a dispatcher needs to choose
# the correct next skill. See references/skill-orchestration.md for the
# canonical definition.
#
# Output shape:
#   {
#     "idea_status_counts": {
#       "captured":   <int>,
#       "shaped":     <int>,
#       "spec_ready": <int>,
#       "shipped":    <int>
#     },
#     "wave_active":       <bool>,
#     "current_wave":      <string|null>,
#     "validation_status": "PASS" | "PENDING" | "FAIL" | "N/A",
#     "gaps": [
#       { "type": <string>, "idea": <string>, "remediation": <string> },
#       ...
#     ],
#     "timestamp": "<ISO 8601 UTC>"
#   }
#
# Reads (no writes, no network):
#   docs/BACKLOG.md
#   docs/ROADMAP.md
#   docs/specs/NN-spec-*/     (for in-flight specs -> validation status)
#
# Exit codes:
#   0  success
#   1  BACKLOG or ROADMAP unreadable
#
# Performance target:
#   < 500 ms on a repository with 50 ideas.
#
# Dependencies:
#   awk  (POSIX)
#   jq   (https://jqlang.github.io/jq/) -- JSON assembly only
#
# Usage:
#   scripts/state.sh
#   scripts/state.sh | jq .idea_status_counts
#
# The script is non-interactive and depends only on the repository files;
# it never prompts and never touches the network.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKLOG="$REPO_ROOT/docs/BACKLOG.md"
ROADMAP="$REPO_ROOT/docs/ROADMAP.md"
SPECS_DIR="$REPO_ROOT/docs/specs"

die() {
  echo "state.sh: $*" >&2
  exit 1
}

command -v jq >/dev/null 2>&1 || die "jq not found on PATH (install: https://jqlang.github.io/jq/)"

# ---- input gating (exit 1 on unreadable BACKLOG/ROADMAP) --------------------

[[ -r "$BACKLOG" ]] || die "cannot read BACKLOG at $BACKLOG"
[[ -r "$ROADMAP" ]] || die "cannot read ROADMAP at $ROADMAP"

# ---- idea parse -------------------------------------------------------------
#
# Walk the BACKLOG a single time via awk. For each `## <title>` section we
# capture the title and the first `- **Status:** <status>` line that follows
# it. Output is one TSV line per idea: "<status>\t<title>". Statuses unknown
# to Arc are emitted verbatim and ignored during counting.

IDEAS_TSV="$(
  awk '
    BEGIN { FS="\n"; title=""; status="" }

    # Start of a new idea section.
    /^## / {
      if (title != "" && status != "") {
        print status "\t" title
      }
      title = substr($0, 4)
      status = ""
      next
    }

    # First status line after the section header wins.
    /^- \*\*Status:\*\*/ && title != "" && status == "" {
      line = $0
      sub(/^- \*\*Status:\*\*[[:space:]]*/, "", line)
      # Trim trailing whitespace.
      sub(/[[:space:]]+$/, "", line)
      status = line
      next
    }

    END {
      if (title != "" && status != "") {
        print status "\t" title
      }
    }
  ' "$BACKLOG"
)"

# ---- status counts ----------------------------------------------------------

count_status() {
  local want="$1"
  local n=0
  if [[ -n "$IDEAS_TSV" ]]; then
    # Count lines whose first TSV field equals $want. Normalise both sides
    # (trim, lowercase, replace '-' with '_') so "spec-ready", "spec_ready",
    # and "Spec-Ready" are treated as a single bucket.
    n="$(
      printf '%s\n' "$IDEAS_TSV" \
        | awk -F '\t' -v want="$want" '
            function norm(s) {
              gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
              s = tolower(s)
              gsub(/-/, "_", s)
              return s
            }
            norm($1) == want { c++ }
            END { print c + 0 }
          '
    )"
  fi
  printf '%d' "$n"
}

CAPTURED_COUNT="$(count_status "captured")"
SHAPED_COUNT="$(count_status "shaped")"
SPEC_READY_COUNT="$(count_status "spec_ready")"
SHIPPED_COUNT="$(count_status "shipped")"

# ---- roadmap parse ----------------------------------------------------------
#
# wave_active = true  iff ROADMAP has at least one wave row with Status
#                     "Active" or "Planned" (case-insensitive, whitespace
#                     tolerant).
# current_wave = name of the first Active wave, else the first Planned wave,
#                else null.
#
# A wave row is a markdown table row whose first non-empty cell looks like a
# wave label ("Wave N: ..." or similar) AND which is not the header / divider
# row. Using awk we can do this in one pass over the file.

ROADMAP_SCAN="$(
  awk -F '|' '
    function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
    function lower(s) { return tolower(s) }

    # Skip horizontal divider rows: | --- | --- |
    /^\|[[:space:]]*-+[[:space:]]*\|/ { next }

    # A data row has at least 3 pipes, i.e. NF >= 4 (leading + trailing empty).
    NF >= 4 {
      wave  = trim($2)
      status = trim($4)

      # Header row usually has "Wave" / "Status" labels -- skip when the
      # status cell equals "status" (case-insensitive) or the wave cell
      # equals "wave".
      if (lower(wave) == "wave" && lower(status) == "status") next
      if (wave == "" || wave == "--") next

      s = lower(status)
      if (s == "active") {
        if (active_wave == "") active_wave = wave
      } else if (s == "planned") {
        if (planned_wave == "") planned_wave = wave
      }
    }

    END {
      if (active_wave != "")       { print "active\t" active_wave }
      else if (planned_wave != "") { print "planned\t" planned_wave }
      else                         { print "none\t" }
    }
  ' "$ROADMAP"
)"

ROADMAP_KIND="${ROADMAP_SCAN%%$'\t'*}"
ROADMAP_WAVE="${ROADMAP_SCAN#*$'\t'}"

WAVE_ACTIVE="false"
CURRENT_WAVE_JSON="null"
case "$ROADMAP_KIND" in
  active|planned)
    WAVE_ACTIVE="true"
    # shellcheck disable=SC2016
    CURRENT_WAVE_JSON="$(jq -Rn --arg w "$ROADMAP_WAVE" '$w')"
    ;;
  *)
    WAVE_ACTIVE="false"
    CURRENT_WAVE_JSON="null"
    ;;
esac

# ---- validation status ------------------------------------------------------
#
# Scan docs/specs/NN-spec-*/NN-validation-*.md for an "**Overall**: <status>"
# line. Precedence (matches skill-orchestration.md "validation_status" semantics):
#   FAIL    > PENDING > PASS > N/A (most-recent / worst-wins)
# The most recently modified validation file's verdict is reported. If any
# validation file reports FAIL we surface FAIL regardless of mtime so a
# dispatcher never treats a failed spec as clean.

VALIDATION_STATUS="N/A"
if [[ -d "$SPECS_DIR" ]]; then
  # Collect validation files sorted newest-first by mtime.
  mapfile -t VALIDATION_FILES < <(
    find "$SPECS_DIR" -mindepth 2 -maxdepth 2 -type f -name '*-validation-*.md' \
      -printf '%T@ %p\n' 2>/dev/null \
      | sort -rn \
      | awk '{ sub(/^[^ ]+ /, ""); print }'
  )

  newest_status=""
  saw_fail="false"
  for vfile in "${VALIDATION_FILES[@]}"; do
    [[ -r "$vfile" ]] || continue
    line="$(grep -m1 -E '^\*\*Overall\*\*:' "$vfile" 2>/dev/null || true)"
    [[ -n "$line" ]] || continue
    verdict="$(printf '%s' "$line" | awk -F ':' '{ sub(/^[[:space:]]+/, "", $2); sub(/[[:space:]]+$/, "", $2); print toupper($2) }')"
    case "$verdict" in
      PASS|PENDING|FAIL) ;;
      *) verdict="" ;;
    esac
    [[ -z "$verdict" ]] && continue
    [[ "$verdict" == "FAIL" ]] && saw_fail="true"
    [[ -z "$newest_status" ]] && newest_status="$verdict"
  done

  if [[ "$saw_fail" == "true" ]]; then
    VALIDATION_STATUS="FAIL"
  elif [[ -n "$newest_status" ]]; then
    VALIDATION_STATUS="$newest_status"
  else
    VALIDATION_STATUS="N/A"
  fi
fi

# ---- gap detection ----------------------------------------------------------
#
# Gaps are advisory only. We flag three lightweight gap types that a
# dispatcher can act on:
#
#   - "shaped_no_spec"    idea is shaped but has no docs/specs/ directory
#                         referencing its slug (Shaped -> Spec gap; P4 in the
#                         dispatcher precedence list).
#   - "captured_high_pri" idea is captured at priority P0 or P1
#                         (Captured -> Shaped gap; P5).
#   - "spec_ready_no_pass" idea is spec-ready but no validation report has
#                         PASS (Validation -> Shipped gap; P1).
#
# Each gap is an object { type, idea, remediation }. Gaps are deliberately
# shallow -- richer analysis belongs to /arc-status.

# Build the gap array in JSON via jq. We stream the ideas TSV through jq
# which receives structured arguments for the spec slugs and the pass flag.

SPEC_SLUGS=""
if [[ -d "$SPECS_DIR" ]]; then
  SPEC_SLUGS="$(
    find "$SPECS_DIR" -mindepth 1 -maxdepth 1 -type d -name '*-spec-*' -printf '%f\n' 2>/dev/null \
      | awk -F '-spec-' 'NF == 2 { print tolower($2) }'
  )"
fi

# A "pass" is available when any validation file records **Overall**: PASS.
ANY_PASS="false"
if [[ "$VALIDATION_STATUS" == "PASS" ]]; then
  ANY_PASS="true"
fi

# Helper: slugify an idea title the same way humans slugify spec dirs.
slugify() {
  # Lowercase; strip leading "(deferred) " prefix; drop non-alphanum to "-";
  # collapse repeats; strip leading/trailing "-".
  awk '{
    s = tolower($0)
    sub(/^\(deferred\)[[:space:]]+/, "", s)
    gsub(/[^a-z0-9]+/, "-", s)
    sub(/^-+/, "", s)
    sub(/-+$/, "", s)
    print s
  }'
}

GAPS_JSON="[]"
if [[ -n "$IDEAS_TSV" ]]; then
  # Build a newline-delimited list of "status<TAB>title<TAB>slug" tuples.
  IDEAS_WITH_SLUGS="$(
    printf '%s\n' "$IDEAS_TSV" \
      | awk -F '\t' '
          {
            status = $1
            title  = $2
            # Cheap inline slugifier -- must match slugify() above.
            slug = tolower(title)
            sub(/^\(deferred\)[[:space:]]+/, "", slug)
            gsub(/[^a-z0-9]+/, "-", slug)
            sub(/^-+/, "", slug)
            sub(/-+$/, "", slug)
            # Normalise status too.
            ns = tolower(status)
            gsub(/-/, "_", ns)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", ns)
            print ns "\t" title "\t" slug
          }
        '
  )"

  # Priority column is captured separately -- a second awk pass that looks
  # for Priority: P0/P1/... lines within each `## <title>` section. We emit
  # "title<TAB>priority" rows.
  PRIORITIES="$(
    awk '
      BEGIN { title = "" }
      /^## / {
        title = substr($0, 4)
        next
      }
      /^- \*\*Priority:\*\*/ && title != "" {
        p = $0
        sub(/^- \*\*Priority:\*\*[[:space:]]*/, "", p)
        sub(/[[:space:]]+$/, "", p)
        # Keep just the P-tag prefix (P0, P1, ...).
        if (match(p, /P[0-9]+/)) {
          p = substr(p, RSTART, RLENGTH)
        }
        print title "\t" p
        title = ""
      }
    ' "$BACKLOG"
  )"

  GAPS_JSON="$(
    jq -n \
      --arg ideas "$IDEAS_WITH_SLUGS" \
      --arg priorities "$PRIORITIES" \
      --arg specs "$SPEC_SLUGS" \
      --arg any_pass "$ANY_PASS" \
      '
      def lines(s): s | split("\n") | map(select(length > 0));

      # { <title>: <priority> }
      ($priorities | split("\n") | map(select(length > 0) | split("\t"))
        | map({ (.[0]): .[1] }) | add // {}) as $pri

      # Set of known spec slugs (empty list when no specs dir).
      | (lines($specs)) as $spec_slugs

      # Parse each "status<TAB>title<TAB>slug" line into a structured record.
      | (lines($ideas) | map(split("\t"))
          | map({
              status:   .[0],
              title:    .[1],
              slug:     .[2],
              priority: ($pri[.[1]] // "")
            })
        ) as $ideas_arr

      | $ideas_arr | map(
          . as $i
          | if $i.status == "shaped" and (($spec_slugs | index($i.slug)) == null)
            then {
              type: "shaped_no_spec",
              idea: $i.title,
              remediation: "write a spec with /cw-spec"
            }
            elif $i.status == "captured" and ($i.priority == "P0" or $i.priority == "P1")
            then {
              type: "captured_high_pri",
              idea: $i.title,
              remediation: "shape with /arc-shape"
            }
            elif $i.status == "spec_ready" and ($any_pass == "false")
            then {
              type: "spec_ready_no_pass",
              idea: $i.title,
              remediation: "validate with /cw-validate"
            }
            else empty
            end
        )
      '
  )"
fi

# ---- assemble ---------------------------------------------------------------

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

jq -n \
  --argjson captured   "$CAPTURED_COUNT" \
  --argjson shaped     "$SHAPED_COUNT" \
  --argjson spec_ready "$SPEC_READY_COUNT" \
  --argjson shipped    "$SHIPPED_COUNT" \
  --argjson wave_active "$WAVE_ACTIVE" \
  --argjson current_wave "$CURRENT_WAVE_JSON" \
  --arg     validation_status "$VALIDATION_STATUS" \
  --argjson gaps       "$GAPS_JSON" \
  --arg     timestamp  "$TIMESTAMP" \
  '{
    idea_status_counts: {
      captured:   $captured,
      shaped:     $shaped,
      spec_ready: $spec_ready,
      shipped:    $shipped
    },
    wave_active:       $wave_active,
    current_wave:      $current_wave,
    validation_status: $validation_status,
    gaps:              $gaps,
    timestamp:         $timestamp
  }'

# Suppress unused helper warning from shellcheck -- slugify() is kept as an
# explicit, documented function for future callers even though the hot path
# inlines the same logic for a single-pass awk.
: "${slugify:-}"
