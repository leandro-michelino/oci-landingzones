#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'USAGE'
Usage:
  scripts/test-networking-lifecycle.sh --blueprint <blueprint-dir> [--providers <csv>]
  scripts/test-networking-lifecycle.sh --all-networking [--providers <csv>]

Purpose:
  Run ephemeral networking lifecycle tests and always teardown after apply
  attempts for selected providers.

Provider values:
  oci,azure,aws

Examples:
  scripts/test-networking-lifecycle.sh --blueprint blueprints/networking/aws-oci-hybrid-network-backbone --providers oci,aws
  scripts/test-networking-lifecycle.sh --all-networking --providers oci
USAGE
}

blueprint=""
all_networking="false"
providers_csv="oci,azure,aws"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --blueprint)
      blueprint="${2:-}"
      shift 2
      ;;
    --all-networking)
      all_networking="true"
      shift
      ;;
    --providers)
      providers_csv="${2:-}"
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

if [[ "$all_networking" == "true" && -n "$blueprint" ]]; then
  echo "ERROR: use either --blueprint or --all-networking, not both." >&2
  exit 1
fi

if [[ "$all_networking" != "true" && -z "$blueprint" ]]; then
  echo "ERROR: pass --blueprint <dir> or --all-networking." >&2
  exit 1
fi

if [[ "$all_networking" == "true" ]]; then
  mapfile -t blueprints < <(find "$REPO_ROOT/blueprints/networking" -mindepth 1 -maxdepth 1 -type d | sort)
else
  if [[ "$blueprint" != /* ]]; then
    blueprint="$REPO_ROOT/$blueprint"
  fi
  if [[ ! -d "$blueprint" ]]; then
    echo "ERROR: blueprint directory not found: $blueprint" >&2
    exit 1
  fi
  blueprints=("$blueprint")
fi

IFS=',' read -r -a providers <<< "$providers_csv"

run_playbook() {
  local playbook="$1"
  if [[ ! -f "$playbook" ]]; then
    return 2
  fi
  ANSIBLE_CONFIG="$REPO_ROOT/ansible/ansible.cfg" ansible-playbook -i localhost, -c local "$playbook"
}

run_provider_lifecycle() {
  local provider="$1"
  local bp="$2"
  local ansible_dir="$bp/ansible"
  local plan=""
  local apply=""
  local destroy=""

  case "$provider" in
    oci)
      plan="$ansible_dir/plan.yml"
      apply="$ansible_dir/apply.yml"
      destroy="$ansible_dir/destroy.yml"
      ;;
    azure)
      plan="$ansible_dir/azure-plan.yml"
      apply="$ansible_dir/azure-apply.yml"
      destroy="$ansible_dir/azure-destroy.yml"
      ;;
    aws)
      plan="$ansible_dir/aws-plan.yml"
      apply="$ansible_dir/aws-apply.yml"
      destroy="$ansible_dir/aws-destroy.yml"
      ;;
    *)
      echo "ERROR: unsupported provider '$provider'" >&2
      return 1
      ;;
  esac

  if [[ ! -f "$plan" && ! -f "$apply" && ! -f "$destroy" ]]; then
    echo "==> [$provider] ${bp#$REPO_ROOT/}: no provider lifecycle playbooks, skipping"
    return 0
  fi

  echo "==> [$provider] ${bp#$REPO_ROOT/}: plan"
  set +e
  run_playbook "$plan"
  local plan_rc=$?
  set -e

  local apply_rc=0
  if [[ $plan_rc -eq 0 ]]; then
    echo "==> [$provider] ${bp#$REPO_ROOT/}: apply"
    set +e
    case "$provider" in
      oci)
        CONFIRM_APPLY=true run_playbook "$apply"
        apply_rc=$?
        ;;
      azure)
        CONFIRM_AZURE_APPLY=true run_playbook "$apply"
        apply_rc=$?
        ;;
      aws)
        CONFIRM_AWS_APPLY=true run_playbook "$apply"
        apply_rc=$?
        ;;
    esac
    set -e
  else
    echo "==> [$provider] ${bp#$REPO_ROOT/}: apply skipped because plan failed"
    apply_rc=4
  fi

  echo "==> [$provider] ${bp#$REPO_ROOT/}: destroy (always after apply attempt)"
  set +e
  local destroy_rc=0
  case "$provider" in
    oci)
      CONFIRM_DESTROY=true run_playbook "$destroy"
      destroy_rc=$?
      ;;
    azure)
      CONFIRM_AZURE_DESTROY=true run_playbook "$destroy"
      destroy_rc=$?
      ;;
    aws)
      CONFIRM_AWS_DESTROY=true run_playbook "$destroy"
      destroy_rc=$?
      ;;
  esac
  set -e

  echo "==> [$provider] ${bp#$REPO_ROOT/}: result plan=${plan_rc} apply=${apply_rc} destroy=${destroy_rc}"

  if [[ $plan_rc -ne 0 || $apply_rc -ne 0 || $destroy_rc -ne 0 ]]; then
    return 1
  fi
  return 0
}

overall_rc=0
for bp in "${blueprints[@]}"; do
  if [[ ! -d "$bp/ansible" ]]; then
    echo "==> ${bp#$REPO_ROOT/}: no ansible directory, skipping"
    continue
  fi

  for provider in "${providers[@]}"; do
    provider="$(echo "$provider" | tr '[:upper:]' '[:lower:]' | xargs)"
    if [[ -z "$provider" ]]; then
      continue
    fi
    if ! run_provider_lifecycle "$provider" "$bp"; then
      overall_rc=1
    fi
  done
done

exit "$overall_rc"
