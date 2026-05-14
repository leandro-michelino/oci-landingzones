#!/usr/bin/env bash
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_REF="${VALIDATE_CHANGED_BASE:-origin/main}"

usage() {
  cat <<'USAGE'
Usage:
  scripts/validate-changed.sh [--base <git-ref>]

Purpose:
  Validate only the Terraform and Ansible surfaces touched by the current
  branch or working tree, while still running the fast repository contract
  guard.

Notes:
  - The default comparison base is origin/main.
  - Uncommitted staged, unstaged, and untracked files are included.
  - Use scripts/validate-all.sh for release, broad refactor, or shared contract
    changes that should exercise every blueprint.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)
      BASE_REF="${2:-}"
      shift 2
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

if [[ -z "$BASE_REF" ]]; then
  echo "ERROR: --base requires a git ref." >&2
  exit 1
fi

if ! git -C "$REPO_ROOT" rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  echo "ERROR: base ref '$BASE_REF' is not available. Fetch it or pass --base <ref>." >&2
  exit 1
fi

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

nearest_tf_root() {
  local path="$1"
  local dir

  if [[ -d "$REPO_ROOT/$path" ]]; then
    dir="$REPO_ROOT/$path"
  else
    dir="$(dirname "$REPO_ROOT/$path")"
  fi

  while [[ "$dir" == "$REPO_ROOT"* && "$dir" != "$REPO_ROOT" ]]; do
    if [[ -f "$dir/main.tf" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
}

add_unique() {
  local value="$1"
  local existing
  shift

  for existing in "$@"; do
    if [[ "$existing" == "$value" ]]; then
      return 1
    fi
  done
  return 0
}

mapfile -t changed_files < <(
  {
    git -C "$REPO_ROOT" diff --name-only --diff-filter=ACMRT "$BASE_REF"...HEAD
    git -C "$REPO_ROOT" diff --name-only --diff-filter=ACMRT HEAD
    git -C "$REPO_ROOT" ls-files --others --exclude-standard
  } | sed '/^$/d' | sort -u
)

echo "==> Checking changed-scope repository contracts"
"$REPO_ROOT/scripts/check-repo-contracts.sh"

if [[ "${#changed_files[@]}" -eq 0 ]]; then
  echo "No changed files detected against $BASE_REF."
  exit 0
fi

echo "==> Changed files against $BASE_REF"
printf '  %s\n' "${changed_files[@]}"

terraform_roots=()
ansible_playbooks=()
run_root_ansible_syntax=false
run_pre_commit=false

for changed_file in "${changed_files[@]}"; do
  case "$changed_file" in
    *.tf|*.tfvars.example|blueprints/*/README.md|blueprints/*/*/README.md|blueprints/*/architecture/README.md|blueprints/*/*/architecture/README.md)
      tf_root="$(nearest_tf_root "$changed_file" || true)"
      if [[ -n "${tf_root:-}" ]] && add_unique "$tf_root" "${terraform_roots[@]}"; then
        terraform_roots+=("$tf_root")
      fi
      ;;
  esac

  case "$changed_file" in
    blueprints/*/ansible/*.yml|blueprints/*/*/ansible/*.yml)
      if add_unique "$REPO_ROOT/$changed_file" "${ansible_playbooks[@]}"; then
        ansible_playbooks+=("$REPO_ROOT/$changed_file")
      fi
      ;;
    ansible/playbooks/*.yml|ansible/roles/*)
      run_root_ansible_syntax=true
      ;;
    .pre-commit-config.yaml|scripts/check-repo-contracts.sh|scripts/validate-changed.sh)
      run_pre_commit=true
      ;;
  esac
done

if command -v terraform >/dev/null 2>&1 && [[ "${#terraform_roots[@]}" -gt 0 ]]; then
  for terraform_root in "${terraform_roots[@]}"; do
    terraform_label="${terraform_root#$REPO_ROOT/}"

    echo "==> terraform fmt -check ${terraform_label}"
    (cd "$terraform_root" && terraform fmt -check -recursive)

    echo "==> terraform init -backend=false ${terraform_label}"
    (cd "$terraform_root" && terraform init -backend=false -input=false -no-color)

    echo "==> terraform validate ${terraform_label}"
    (cd "$terraform_root" && terraform validate -no-color)
  done
elif [[ "${#terraform_roots[@]}" -gt 0 ]]; then
  echo "==> Skipping changed Terraform validation; terraform command not found"
else
  echo "==> No changed Terraform roots detected"
fi

if command -v ansible-playbook >/dev/null 2>&1; then
  if [[ "$run_root_ansible_syntax" == true ]]; then
    echo "==> ansible-playbook syntax checks for changed shared Ansible"
    for playbook in \
      ansible/playbooks/site.yml \
      ansible/playbooks/bootstrap.yml \
      ansible/playbooks/validate.yml \
      ansible/playbooks/terraform-plan.yml \
      ansible/playbooks/terraform-apply.yml \
      ansible/playbooks/terraform-destroy.yml \
      ansible/playbooks/ephemeral-test.yml; do
      ANSIBLE_CONFIG="$REPO_ROOT/ansible/ansible.cfg" ansible-playbook --syntax-check "$REPO_ROOT/$playbook"
    done
  fi

  for playbook in "${ansible_playbooks[@]}"; do
    echo "==> ansible-playbook --syntax-check ${playbook#$REPO_ROOT/}"
    ANSIBLE_CONFIG="$REPO_ROOT/ansible/ansible.cfg" ansible-playbook --syntax-check "$playbook"
  done
else
  echo "==> Skipping changed Ansible syntax checks; ansible-playbook command not found"
fi

if [[ "${#terraform_roots[@]}" -gt 0 ]]; then
  for terraform_root in "${terraform_roots[@]}"; do
    run_if_available tflint --chdir "$terraform_root" --config "$REPO_ROOT/.tflint.hcl"
  done
fi

if [[ "$run_pre_commit" == true ]]; then
  run_if_available pre-commit run --all-files
fi

echo "Changed-scope validation completed."
