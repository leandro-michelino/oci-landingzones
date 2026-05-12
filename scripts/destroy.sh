#!/usr/bin/env bash
set -euo pipefail

cat <<'WARNING'
Destroy helper is intentionally guarded.

Set CONFIRM_DESTROY=true and run this script from the blueprint or environment
directory you intend to destroy.
WARNING

if [[ "${CONFIRM_DESTROY:-}" != "true" ]]; then
  echo "Refusing to run terraform destroy without CONFIRM_DESTROY=true."
  exit 1
fi

terraform destroy
