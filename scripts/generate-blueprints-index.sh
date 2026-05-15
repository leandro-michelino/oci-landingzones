#!/usr/bin/env bash
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$REPO_ROOT/BLUEPRINTS.md"

usage() {
  cat <<'USAGE'
Usage:
  scripts/generate-blueprints-index.sh [--check]

Purpose:
  Generate BLUEPRINTS.md from deployable folders under blueprints/.

Options:
  --check   Fail when BLUEPRINTS.md is missing or out of date.
USAGE
}

check_mode=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      check_mode=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

title_for() {
  local readme="$1"
  local title

  title="$(awk '/^# / { sub(/^# /, ""); print; exit }' "$readme" 2>/dev/null || true)"
  if [[ -z "$title" ]]; then
    title="$(basename "$(dirname "$readme")")"
  fi

  printf '%s\n' "$title"
}

summary_for() {
  local readme="$1"
  local summary

  summary="$(
    awk -F '|' '
      $2 ~ /^[[:space:]]*Best fit[[:space:]]*$/ {
        value=$3
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
        gsub(/`/, "", value)
        print value
        exit
      }
    ' "$readme" 2>/dev/null || true
  )"

  if [[ -z "$summary" ]]; then
    summary="See the blueprint README for deployment purpose, inputs, and review notes."
  fi

  printf '%s\n' "$summary"
}

family_for() {
  local relative_path="$1"
  local remainder="${relative_path#blueprints/}"

  printf '%s\n' "${remainder%%/*}"
}

render_index() {
  local main_tf
  local dir
  local relative_dir
  local family
  local current_family=""
  local title
  local summary

  cat <<HEADER
# Blueprint Index

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Generated from deployable folders under \`blueprints/\`.
Run \`make blueprints\` after adding, moving, or removing a blueprint.

| Quick Links |
|---|
| [Main README](README.md) |
| [Deployment Guide](docs/DEPLOYMENT-GUIDE.md) |
| [Deployment Pattern Catalog](docs/DEPLOYMENT-PATTERN-CATALOG.md) |
| [Architecture Index](docs/architecture/README.md) |

HEADER

  while IFS= read -r main_tf; do
    dir="${main_tf%/main.tf}"
    relative_dir="${dir#$REPO_ROOT/}"
    family="$(family_for "$relative_dir")"

    if [[ "$family" != "$current_family" ]]; then
      if [[ -n "$current_family" ]]; then
        printf '\n'
      fi
      printf '## %s\n\n' "$family"
      printf '| Blueprint | Summary | Architecture |\n'
      printf '|---|---|---|\n'
      current_family="$family"
    fi

    title="$(title_for "$dir/README.md")"
    summary="$(summary_for "$dir/README.md")"
    printf '| [%s](%s/) | %s | [ASCII](%s/architecture/README.md) |\n' \
      "$title" "$relative_dir" "$summary" "$relative_dir"
  done < <(
    find "$REPO_ROOT/blueprints" \
      -path "*/.terraform/*" -prune -o \
      -name "main.tf" -type f -print | sort
  )
}

if [[ "$check_mode" == true ]]; then
  temp_file="$(mktemp)"
  trap 'rm -f "$temp_file"' EXIT
  render_index > "$temp_file"

  if [[ ! -f "$OUTPUT_FILE" ]]; then
    echo "ERROR: BLUEPRINTS.md is missing. Run scripts/generate-blueprints-index.sh." >&2
    exit 1
  fi

  if ! diff -u "$OUTPUT_FILE" "$temp_file"; then
    echo "ERROR: BLUEPRINTS.md is out of date. Run scripts/generate-blueprints-index.sh." >&2
    exit 1
  fi

  echo "BLUEPRINTS.md is current."
  exit 0
fi

render_index > "$OUTPUT_FILE"
echo "Wrote ${OUTPUT_FILE#$REPO_ROOT/}."
