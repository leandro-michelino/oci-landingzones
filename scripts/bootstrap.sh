#!/usr/bin/env bash
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/bootstrap.sh --org <org> --env <env> --region <oci-region>

Purpose:
  Run local bootstrap checks for an OCI landing zone deployment.

Current behavior:
  Delegates to the Ansible bootstrap playbook when Ansible is available. The
  shell fallback only validates inputs and prints the manual prerequisites.
USAGE
}

ORG=""
ENVIRONMENT=""
REGION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --org)
      ORG="${2:-}"
      shift 2
      ;;
    --env)
      ENVIRONMENT="${2:-}"
      shift 2
      ;;
    --region)
      REGION="${2:-}"
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

if [[ -z "$ORG" || -z "$ENVIRONMENT" || -z "$REGION" ]]; then
  echo "Missing required arguments." >&2
  usage
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v ansible-playbook >/dev/null 2>&1 && [[ "${BOOTSTRAP_SHELL_FALLBACK:-0}" != "1" ]]; then
  INVENTORY="$REPO_ROOT/ansible/inventories/$ENVIRONMENT/hosts.yml"
  if [[ ! -f "$INVENTORY" ]]; then
    INVENTORY="$REPO_ROOT/ansible/inventories/dev/hosts.yml"
  fi

  echo "==> ansible-playbook ansible/playbooks/bootstrap.yml"
  ANSIBLE_CONFIG="$REPO_ROOT/ansible/ansible.cfg" \
    ansible-playbook \
      -i "$INVENTORY" \
      "$REPO_ROOT/ansible/playbooks/bootstrap.yml" \
      -e "landingzone_org=$ORG" \
      -e "landingzone_environment=$ENVIRONMENT" \
      -e "landingzone_region=$REGION"
  exit 0
fi

cat <<EOF
Bootstrap context
-----------------
Organization : $ORG
Environment  : $ENVIRONMENT
Region       : $REGION

Manual prerequisites to confirm:
1. Terraform and OCI CLI are installed locally.
2. OCI CLI is authenticated for the selected tenancy.
3. TENANCY_OCID is exported in the shell.
4. A remote state bucket and namespace naming decision exists.
5. Local or approved external secrets handling is defined.

Suggested validation:
  oci iam tenancy get --tenancy-id "\$TENANCY_OCID"
  pre-commit install
EOF
