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

run_terraform_blueprint_validation() {
  local main_tf
  local terraform_dir
  local terraform_dir_label

  if ! command -v terraform >/dev/null 2>&1; then
    echo "==> Skipping Terraform blueprint validation; terraform command not found"
    return 0
  fi

  echo "==> terraform fmt -check -recursive"
  (cd "$REPO_ROOT" && terraform fmt -check -recursive)

  while IFS= read -r main_tf; do
    terraform_dir="${main_tf%/main.tf}"
    terraform_dir_label="${terraform_dir#$REPO_ROOT/}"

    echo "==> terraform init -backend=false ${terraform_dir_label}"
    (cd "$terraform_dir" && terraform init -backend=false -input=false -no-color)

    echo "==> terraform validate ${terraform_dir_label}"
    (cd "$terraform_dir" && terraform validate -no-color)
  done < <(
    find "$REPO_ROOT/blueprints" \
      -path "*/.terraform/*" -prune -o \
      -name main.tf -type f -print | sort
  )
}

run_terraform_blueprint_validation

if command -v ansible-playbook >/dev/null 2>&1 && [[ "${VALIDATE_ALL_ANSIBLE_ROLE:-0}" == "1" ]]; then
  echo "==> ansible-playbook ansible/playbooks/validate.yml"
  ANSIBLE_CONFIG="$REPO_ROOT/ansible/ansible.cfg" \
    ansible-playbook \
      -e validation_run_terraform_commands=false \
      "$REPO_ROOT/ansible/playbooks/validate.yml" "$@"
  exit 0
fi

cd "$REPO_ROOT"

# Keep optional scanners focused on repository source instead of downloaded
# provider/module artifacts created during terraform init.
cleanup_generated_artifacts

run_if_available tflint --config "$REPO_ROOT/.tflint.hcl" --recursive
run_if_available trivy config .
run_if_available checkov -d . --framework terraform --compact
ANSIBLE_CONFIG="$REPO_ROOT/ansible/ansible.cfg" run_if_available ansible-lint ansible

if command -v ansible-playbook >/dev/null 2>&1; then
  echo "==> ansible-playbook syntax checks"
  for playbook in \
    ansible/playbooks/site.yml \
    ansible/playbooks/bootstrap.yml \
    ansible/playbooks/validate.yml \
    ansible/playbooks/terraform-plan.yml \
    ansible/playbooks/terraform-apply.yml \
    ansible/playbooks/terraform-destroy.yml \
    ansible/playbooks/ephemeral-test.yml; do
    ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook --syntax-check "$playbook"
  done

  while IFS= read -r playbook; do
    ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook --syntax-check "$playbook"
  done < <(
    find "$REPO_ROOT/blueprints" \
      -path "*/.terraform/*" -prune -o \
      \( -path "*/ansible/plan.yml" \
      -o -path "*/ansible/apply.yml" \
      -o -path "*/ansible/destroy.yml" \) \
      -type f -print | sort
  )
else
  echo "==> Skipping ansible-playbook syntax checks; command not found"
fi

run_if_available pre-commit run --all-files
