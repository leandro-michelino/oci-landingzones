#!/usr/bin/env bash
set -euo pipefail

run_if_available() {
  local tool="$1"
  shift

  if command -v "$tool" >/dev/null 2>&1; then
    echo "==> $tool $*"
    "$tool" "$@"
  else
    echo "==> Skipping $tool; command not found"
  fi
}

run_if_available terraform fmt -check -recursive
run_if_available tflint --recursive
run_if_available checkov -d . --framework terraform --compact
run_if_available pre-commit run --all-files
