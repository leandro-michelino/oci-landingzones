#!/usr/bin/env bash
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
set -euo pipefail

cat <<'WARNING'
Destroy helper is intentionally guarded.

Set CONFIRM_DESTROY=true and run this script from the blueprint or environment
directory you intend to destroy. When Ansible is installed, this delegates to
ansible/playbooks/terraform-destroy.yml.
WARNING

if [[ "${CONFIRM_DESTROY:-}" != "true" ]]; then
  echo "Refusing to run terraform destroy without CONFIRM_DESTROY=true."
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_WORKING_DIR="${TERRAFORM_WORKING_DIR:-$PWD}"
LANDINGZONE_ENVIRONMENT="${LANDINGZONE_ENVIRONMENT:-dev}"
ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-$REPO_ROOT/ansible/inventories/$LANDINGZONE_ENVIRONMENT/hosts.yml}"

if command -v ansible-playbook >/dev/null 2>&1 && [[ "${DESTROY_SHELL_FALLBACK:-0}" != "1" ]]; then
  if [[ ! -f "$ANSIBLE_INVENTORY" ]]; then
    ANSIBLE_INVENTORY="$REPO_ROOT/ansible/inventories/dev/hosts.yml"
  fi

  echo "==> ansible-playbook ansible/playbooks/terraform-destroy.yml"
  ANSIBLE_CONFIG="$REPO_ROOT/ansible/ansible.cfg" \
    ansible-playbook \
      -i "$ANSIBLE_INVENTORY" \
      "$REPO_ROOT/ansible/playbooks/terraform-destroy.yml" \
      -e "terraform_working_dir=$TERRAFORM_WORKING_DIR" \
      -e "landingzone_environment=$LANDINGZONE_ENVIRONMENT"
  exit 0
fi

terraform destroy
