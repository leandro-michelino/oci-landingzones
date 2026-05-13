#!/usr/bin/env bash
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$REPO_ROOT/scripts/terraform-env.sh"
terraform_env_export_common

export ANSIBLE_LOCAL_TEMP="${ANSIBLE_LOCAL_TEMP:-${TMPDIR:-/tmp}/ansible-local}"
export ANSIBLE_REMOTE_TEMP="${ANSIBLE_REMOTE_TEMP:-${ANSIBLE_LOCAL_TEMP}/remote}"
mkdir -p "$ANSIBLE_LOCAL_TEMP" "$ANSIBLE_REMOTE_TEMP"

cleanup_generated_artifacts() {
  find "$REPO_ROOT" -name ".terraform" -type d -prune -exec rm -rf {} +
  find "$REPO_ROOT" \
    \( -name ".terraform.lock.hcl" \
    -o -name "terraform.tfstate" \
    -o -name "terraform.tfstate.backup" \
    -o -name "tfplan" \
    -o -name "tfplan.*" \
    -o -name "*.tfplan" \
    -o -name ".DS_Store" \) \
    -type f -delete
}

trap cleanup_generated_artifacts EXIT

"$REPO_ROOT/scripts/check-repo-contracts.sh"

if command -v ansible-playbook >/dev/null 2>&1 && [[ "${VALIDATE_ALL_SHELL_FALLBACK:-0}" != "1" ]]; then
  echo "==> ansible-playbook ansible/playbooks/validate.yml"
  ANSIBLE_CONFIG="$REPO_ROOT/ansible/ansible.cfg" \
    ansible-playbook "$REPO_ROOT/ansible/playbooks/validate.yml" "$@"
  exit 0
fi

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

cd "$REPO_ROOT"

run_if_available terraform fmt -check -recursive
run_if_available tflint --recursive
run_if_available tfsec .
run_if_available checkov -d . --framework terraform --compact
run_if_available ansible-lint ansible

if command -v ansible-playbook >/dev/null 2>&1; then
  echo "==> ansible-playbook syntax checks"
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook --syntax-check ansible/playbooks/site.yml
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook --syntax-check ansible/playbooks/bootstrap.yml
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook --syntax-check ansible/playbooks/validate.yml
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook --syntax-check ansible/playbooks/terraform-plan.yml
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook --syntax-check ansible/playbooks/terraform-apply.yml
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook --syntax-check ansible/playbooks/terraform-destroy.yml
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook --syntax-check ansible/playbooks/ephemeral-test.yml
else
  echo "==> Skipping ansible-playbook syntax checks; command not found"
fi

run_if_available pre-commit run --all-files
