#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export ANSIBLE_CONFIG="$REPO_ROOT/ansible/ansible.cfg"
export ANSIBLE_LOCAL_TEMP="${ANSIBLE_LOCAL_TEMP:-${TMPDIR:-/tmp}/ansible-local}"
export ANSIBLE_REMOTE_TEMP="${ANSIBLE_REMOTE_TEMP:-${ANSIBLE_LOCAL_TEMP}/remote}"
mkdir -p "$ANSIBLE_LOCAL_TEMP" "$ANSIBLE_REMOTE_TEMP"

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "ERROR: ansible-playbook is required for cloud deployment simulation." >&2
  exit 1
fi

run_cloud_family() {
  local provider="$1"
  local simulate_var="$2"
  local plan_playbook
  local action
  local playbook

  while IFS= read -r plan_playbook; do
    for action in plan apply destroy; do
      playbook="${plan_playbook%plan.yml}${action}.yml"
      if [[ ! -f "$playbook" ]]; then
        echo "ERROR: Missing ${provider} ${action} playbook: ${playbook#$REPO_ROOT/}" >&2
        exit 1
      fi

      echo "==> ansible-playbook --syntax-check ${playbook#$REPO_ROOT/}"
      ansible-playbook -i localhost, --syntax-check "$playbook"
    done

    echo "==> Simulating ${provider} plan ${plan_playbook#$REPO_ROOT/}"
    ansible-playbook -i localhost, -e "${simulate_var}=true" "$plan_playbook"
  done < <(
    find "$REPO_ROOT/blueprints" \
      -path "*/.terraform/*" -prune -o \
      -path "*/ansible/${provider}-plan.yml" -type f -print | sort
  )
}

echo "==> Simulating Azure and AWS deployment wrappers"
run_cloud_family azure azure_simulate_only
run_cloud_family aws aws_simulate_only
echo "Cloud deployment simulations completed."
