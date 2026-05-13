#!/usr/bin/env bash
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

fail() {
  echo "ERROR: $*" >&2
  failures=1
}

check_forbidden_markdown() {
  local pattern="$1"
  local matches

  if command -v rg >/dev/null 2>&1; then
    matches="$(
      rg -n --fixed-strings \
        --glob "*.md" \
        --glob "!**/.terraform/**" \
        --glob "!**/.git/**" \
        -- "$pattern" "$REPO_ROOT" || true
    )"
  else
    matches="$(
      find "$REPO_ROOT" \
        -path "*/.terraform/*" -prune -o \
        -path "*/.git/*" -prune -o \
        -name "*.md" -type f -exec grep -nH -F -- "$pattern" {} + || true
    )"
  fi

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "Forbidden markdown fragment found: $pattern"
  fi
}

check_file() {
  local path="$1"

  if [[ ! -f "$path" ]]; then
    fail "Missing required file: ${path#$REPO_ROOT/}"
  fi
}

check_contains() {
  local path="$1"
  local pattern="$2"
  local description="$3"

  if [[ -f "$path" ]] && ! grep -Fq -- "$pattern" "$path"; then
    fail "${path#$REPO_ROOT/} must contain $description."
  fi
}

check_blueprint_contract() {
  local dir="$1"
  local playbook
  local action

  check_file "$dir/README.md"
  check_file "$dir/architecture/README.md"
  check_file "$dir/main.tf"
  check_file "$dir/variables.tf"
  check_file "$dir/outputs.tf"
  check_file "$dir/providers.tf"
  check_file "$dir/versions.tf"
  check_file "$dir/terraform.tfvars.example"

  for action in plan apply destroy; do
    playbook="$dir/ansible/$action.yml"
    check_file "$playbook"
    check_contains "$playbook" "terraform_action: $action" "terraform_action: $action"
    check_contains "$playbook" "terraform_working_dir:" "terraform_working_dir"
  done
}

echo "==> Checking repository documentation and blueprint contracts"

check_forbidden_markdown "State, Inputs, And Outputs"
check_forbidden_markdown "Input sources"
check_forbidden_markdown "Terraform state"
check_forbidden_markdown "Output contract"
check_forbidden_markdown 'Confirm `terraform output` will expose'

while IFS= read -r main_tf; do
  check_blueprint_contract "${main_tf%/main.tf}"
done < <(
  find "$REPO_ROOT/blueprints" \
    -path "*/.terraform/*" -prune -o \
    -name "main.tf" -type f -print | sort
)

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "Repository contracts look consistent."
