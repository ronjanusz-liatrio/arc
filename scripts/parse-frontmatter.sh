#!/usr/bin/env bash
set -euo pipefail

# parse-frontmatter.sh — emit a dependency graph derived from arc SKILL.md frontmatters.
#
# Reads every skills/arc-*/SKILL.md frontmatter block and emits one of two formats:
#
#   --format mermaid   Mermaid markdown flowchart (one node per skill,
#                      edges derived from consumes.from[].skill).
#                      Styled to match Arc's Liatrio theme convention
#                      (see templates/VISION.tmpl.md). The rendered block
#                      stays under 50 lines so it previews cleanly in GitHub.
#
#   --format json      Structured JSON keyed by skill name. Each entry
#                      exposes requires, produces, consumes, triggers
#                      populated from the source frontmatter.
#
# Usage:
#   scripts/parse-frontmatter.sh --format mermaid [SKILL.md ...]
#   scripts/parse-frontmatter.sh --format json    [SKILL.md ...]
#
# When no SKILL.md paths are supplied, defaults to skills/arc-*/SKILL.md
# relative to the repo root. Missing paths are skipped with a warning on
# stderr; malformed frontmatter fails with exit 1.
#
# Exit codes:
#   0  success
#   1  invalid flag, parse error, or malformed frontmatter
#
# Dependencies:
#   awk  (POSIX, universally available)
#   yq   (mikefarah/yq v4+; https://github.com/mikefarah/yq)
#   jq   (https://jqlang.github.io/jq/)
#
# Install hints (yq is not universally available on base images):
#   macOS:   brew install yq
#   Linux:   curl -fsSL -o ~/.local/bin/yq \
#              https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
#              && chmod +x ~/.local/bin/yq
#   arm64:   swap yq_linux_amd64 -> yq_linux_arm64 in the URL above
#   Docker:  FROM mikefarah/yq:4 as yq-stage

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

die() {
  echo "parse-frontmatter: $*" >&2
  exit 1
}

# ---- arg parsing ------------------------------------------------------------

FORMAT=""
FILES=()

while (($#)); do
  case "$1" in
    --format)
      shift
      [[ $# -gt 0 ]] || die "--format requires an argument (mermaid|json)"
      FORMAT="$1"
      shift
      ;;
    --format=*)
      FORMAT="${1#--format=}"
      shift
      ;;
    -h|--help)
      sed -n '3,40p' "$0"
      exit 0
      ;;
    --)
      shift
      while (($#)); do FILES+=("$1"); shift; done
      ;;
    -*)
      die "unknown flag: $1"
      ;;
    *)
      FILES+=("$1")
      shift
      ;;
  esac
done

case "$FORMAT" in
  mermaid|json) ;;
  "") die "--format is required (mermaid|json)" ;;
  *)  die "invalid --format value: $FORMAT (expected mermaid|json)" ;;
esac

# Default to skills/arc-*/SKILL.md relative to repo root when no paths given.
if [[ ${#FILES[@]} -eq 0 ]]; then
  while IFS= read -r -d '' f; do
    FILES+=("$f")
  done < <(find "$REPO_ROOT/skills" -maxdepth 2 -type f -name 'SKILL.md' -path '*/arc-*' -print0 | sort -z)
fi

[[ ${#FILES[@]} -gt 0 ]] || die "no SKILL.md paths supplied and none discovered under $REPO_ROOT/skills"

# ---- dependency check -------------------------------------------------------

command -v yq >/dev/null 2>&1 || die "yq not found on PATH (install: https://github.com/mikefarah/yq)"
command -v jq >/dev/null 2>&1 || die "jq not found on PATH (install: https://jqlang.github.io/jq/)"

# Confirm this is mikefarah/yq v4+, not python-yq. python-yq lacks the
# --output-format / -o flag we rely on and will produce wrong output silently.
if ! yq --version 2>&1 | grep -qE 'mikefarah|v4\.'; then
  die "mikefarah/yq v4+ required (detected: $(yq --version 2>&1 || echo unknown))"
fi

# ---- helpers ----------------------------------------------------------------

# Extract the first YAML frontmatter block (between the first pair of "---" lines)
# from a SKILL.md file. Emits the YAML body (no fences) on stdout.
extract_frontmatter() {
  local file="$1"
  awk '
    BEGIN { state=0 }
    state==0 && /^---[[:space:]]*$/ { state=1; next }
    state==1 && /^---[[:space:]]*$/ { exit }
    state==1 { print }
  ' "$file"
}

WORK_DIR="${TMPDIR:-/tmp}/parse-frontmatter-$$"
mkdir -p "$WORK_DIR"
trap 'rm -rf "$WORK_DIR"' EXIT

# Build a combined JSON object: { "<skill-name>": { requires, produces, consumes, triggers }, ... }
# Written to $WORK_DIR/combined.json. Exits 1 on any parse error.
build_combined_json() {
  local combined="$WORK_DIR/combined.json"
  echo '{}' > "$combined"

  local file fm_file skill_json name tmp
  for file in "${FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "parse-frontmatter: warning: skipping missing file $file" >&2
      continue
    fi

    fm_file="$WORK_DIR/$(basename "$(dirname "$file")").yaml"
    if ! extract_frontmatter "$file" > "$fm_file"; then
      die "failed to extract frontmatter from $file"
    fi
    if [[ ! -s "$fm_file" ]]; then
      die "no frontmatter block found in $file"
    fi

    # Convert YAML -> JSON via yq.
    if ! skill_json="$(yq -o=json '.' "$fm_file" 2>"$WORK_DIR/yq.err")"; then
      echo "parse-frontmatter: yq failed parsing $file:" >&2
      cat "$WORK_DIR/yq.err" >&2
      exit 1
    fi

    # Derive the skill name from the frontmatter (authoritative), falling back
    # to the directory name if name is absent.
    if ! name="$(printf '%s' "$skill_json" | jq -er '.name // empty' 2>/dev/null)"; then
      name="$(basename "$(dirname "$file")")"
    fi
    [[ -n "$name" ]] || name="$(basename "$(dirname "$file")")"

    # Reduce to just the four contract fields, preserving structure and
    # normalising missing fields to empty objects.
    tmp="$WORK_DIR/${name}.json"
    if ! printf '%s' "$skill_json" | jq '{
      requires: (.requires // {}),
      produces: (.produces // {}),
      consumes: (.consumes // {}),
      triggers: (.triggers // {})
    }' > "$tmp" 2>"$WORK_DIR/jq.err"; then
      echo "parse-frontmatter: jq failed normalising $file:" >&2
      cat "$WORK_DIR/jq.err" >&2
      exit 1
    fi

    # Merge this skill entry into the combined object.
    if ! jq --arg name "$name" --slurpfile entry "$tmp" \
          '. + {($name): $entry[0]}' "$combined" > "$combined.next"; then
      die "failed to merge $name into combined frontmatter JSON"
    fi
    mv "$combined.next" "$combined"
  done

  echo "$combined"
}

# ---- format: json -----------------------------------------------------------

emit_json() {
  local combined
  combined="$(build_combined_json)"
  # Pretty-print for human inspection; still a valid single JSON document.
  jq '.' "$combined"
}

# ---- format: mermaid --------------------------------------------------------

emit_mermaid() {
  local combined
  combined="$(build_combined_json)"

  # Collect the skill node list.
  local nodes
  nodes="$(jq -r 'keys[]' "$combined")"

  # Collect edges as "src|dst" where src is the upstream skill declared in
  # consumes.from[].skill and dst is the current skill. Only edges where src
  # is also a known arc-* sibling are rendered — external skills (e.g.
  # /cw-validate) are summarised as a note to keep the block under 50 lines.
  local edges external_edges
  edges="$(
    jq -r '
      to_entries
      | map(
          .key as $dst
          | (.value.consumes.from // [])
          | map(select(type == "object") | .skill + "|" + $dst)
        )
      | flatten | .[]
    ' "$combined"
  )"

  # Stable short node ids: arc-capture -> cap, arc-shape -> shp, etc.
  # Fall back to a hash-free slug for unknown arc skills.
  node_id() {
    case "$1" in
      arc-capture) echo "cap" ;;
      arc-shape)   echo "shp" ;;
      arc-wave)    echo "wav" ;;
      arc-ship)    echo "shi" ;;
      arc-status)  echo "sta" ;;
      arc-audit)   echo "aud" ;;
      arc-assess)  echo "ass" ;;
      arc-sync)    echo "syn" ;;
      arc-help)    echo "hlp" ;;
      *)           printf 'ext_%s' "$(printf '%s' "$1" | tr -c 'A-Za-z0-9' '_')" ;;
    esac
  }

  # Determine which sibling-to-sibling edges exist (both ends are arc-* in the
  # combined set) versus external-upstream edges (src not present in combined).
  local sibling_edges=""
  external_edges=""
  local line src dst src_slug
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    src="${line%%|*}"
    dst="${line#*|}"
    # Strip leading slash when present: "/arc-shape" -> "arc-shape".
    src_slug="${src#/}"
    if jq -e --arg k "$src_slug" 'has($k)' "$combined" >/dev/null 2>&1; then
      sibling_edges+="$src_slug|$dst"$'\n'
    else
      external_edges+="$src_slug -> $dst"$'\n'
    fi
  done <<< "$edges"

  # Emit the Mermaid block — fenced so it renders in GitHub preview.
  {
    echo '```mermaid'
    echo "%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#11B5A4', 'primaryTextColor': '#FFFFFF', 'primaryBorderColor': '#0D8F82', 'secondaryColor': '#E8662F', 'secondaryTextColor': '#FFFFFF', 'secondaryBorderColor': '#C7502A', 'tertiaryColor': '#1B2A3D', 'tertiaryTextColor': '#FFFFFF', 'lineColor': '#1B2A3D', 'fontFamily': 'Inter, sans-serif'}}}%%"
    echo "flowchart LR"

    # Nodes (one per skill), stable short ids + human labels.
    while IFS= read -r name; do
      [[ -z "$name" ]] && continue
      printf '    %s["/%s"]\n' "$(node_id "$name")" "$name"
    done <<< "$nodes"

    # Sibling edges: src --> dst.
    if [[ -n "$sibling_edges" ]]; then
      while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        src="${line%%|*}"
        dst="${line#*|}"
        printf '    %s --> %s\n' "$(node_id "$src")" "$(node_id "$dst")"
      done <<< "$sibling_edges"
    fi

    # External upstream edges (collapsed into a single note node when present).
    if [[ -n "$external_edges" ]]; then
      echo "    ext(\"external upstream\"):::ext"
      while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        dst="${line##* -> }"
        printf '    ext --> %s\n' "$(node_id "$dst")"
      done <<< "$external_edges"
      echo "    classDef ext fill:#1B2A3D,stroke:#0D8F82,color:#FFFFFF,stroke-dasharray:4 2"
    fi

    echo '```'
  }
}

# ---- dispatch ---------------------------------------------------------------

case "$FORMAT" in
  json)    emit_json ;;
  mermaid) emit_mermaid ;;
esac
