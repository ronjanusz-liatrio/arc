#!/usr/bin/env bash
set -euo pipefail

# Lint all mermaid fenced code blocks in markdown files.
# Exits 0 with a one-line summary on success.
# Exits 1 naming the broken file and fence index on failure.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK_DIR="${TMPDIR:-/tmp}/lint-mermaid-$$"
mkdir -p "$WORK_DIR"
trap 'rm -rf "$WORK_DIR"' EXIT

# Collect markdown files, excluding node_modules, .worktrees, and docs/specs
md_files=()
while IFS= read -r f; do
  md_files+=("$f")
done < <(
  find "$REPO_ROOT" -name '*.md' -type f \
    ! -path '*/node_modules/*' \
    ! -path '*/.worktrees/*' \
    ! -path '*/docs/specs/*' \
  | sort
)

if [[ ${#md_files[@]} -eq 0 ]]; then
  echo "0 files, 0 fences, all valid"
  exit 0
fi

total_files=0
total_fences=0
failed=0

for md_file in "${md_files[@]}"; do
  # Extract mermaid fences using awk
  awk '
    /^```mermaid/ { inside=1; content=""; next }
    /^```/ && inside {
      inside=0
      count++
      outfile = outdir "/fence-" count ".mmd"
      print content > outfile
      close(outfile)
      next
    }
    inside { content = content (content ? "\n" : "") $0 }
  ' outdir="$WORK_DIR" "$md_file"

  # Count how many fence files were produced for this markdown file
  file_fences=0
  for fence_file in "$WORK_DIR"/fence-*.mmd; do
    [[ -f "$fence_file" ]] || continue
    file_fences=$((file_fences + 1))
  done

  if [[ $file_fences -eq 0 ]]; then
    rm -f "$WORK_DIR"/fence-*.mmd
    continue
  fi

  total_files=$((total_files + 1))

  # Validate each fence
  idx=0
  for fence_file in "$WORK_DIR"/fence-*.mmd; do
    [[ -f "$fence_file" ]] || continue
    idx=$((idx + 1))
    total_fences=$((total_fences + 1))

    out_file="$WORK_DIR/out-$idx.svg"
    if ! npx --yes @mermaid-js/mermaid-cli -q -i "$fence_file" -o "$out_file" 2>"$WORK_DIR/err-$idx.txt"; then
      rel_path="${md_file#"$REPO_ROOT"/}"
      echo "FAIL: $rel_path fence #$idx"
      failed=$((failed + 1))
    fi
    rm -f "$out_file"
  done

  # Clean up fence files for this iteration
  rm -f "$WORK_DIR"/fence-*.mmd
done

if [[ $failed -gt 0 ]]; then
  exit 1
fi

echo "$total_files files, $total_fences fences, all valid"
