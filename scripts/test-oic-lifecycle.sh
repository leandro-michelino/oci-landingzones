#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BLUEPRINT_DIR="$REPO_ROOT/blueprints/extensions/oic"
DEFAULT_VAR_FILE="$REPO_ROOT/.leo-local/oic-saopaulo.tfvars"
VAR_FILE=""
OCI_PROFILE_VALUE="${OCI_PROFILE:-${OCI_CLI_PROFILE:-DEFAULT}}"
OCI_REGION_VALUE="${OCI_REGION:-}"
PLAN_FILE="tfplan.oic-e2e"
KEEP_RESOURCES="${OIC_LIFECYCLE_KEEP_RESOURCES:-false}"

usage() {
  cat <<'USAGE'
Usage:
  scripts/test-oic-lifecycle.sh [--var-file <path>] [--profile <oci-profile>] [--region <oci-region>] [--keep-resources]

Purpose:
  Run a real Oracle Integration Cloud lifecycle test: fmt, init, validate,
  plan, apply, OCI CLI instance verification, destroy, and post-destroy state
  check. If --var-file is omitted, the script uses
  .leo-local/oic-saopaulo.tfvars.

Safety:
  Set OIC_LIFECYCLE_CONFIRM=true to allow the real apply lifecycle.
  Without --keep-resources, destroy is always attempted after an apply attempt.
  Pass --keep-resources or set OIC_LIFECYCLE_KEEP_RESOURCES=true to skip
  destroy after apply and verification.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --var-file)
      VAR_FILE="${2:-}"
      shift 2
      ;;
    --profile)
      OCI_PROFILE_VALUE="${2:-}"
      shift 2
      ;;
    --region)
      OCI_REGION_VALUE="${2:-}"
      shift 2
      ;;
    --keep-resources)
      KEEP_RESOURCES="true"
      shift
      ;;
    -h | --help)
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

if [[ -z "$VAR_FILE" ]]; then
  VAR_FILE="$DEFAULT_VAR_FILE"
fi

if [[ "$VAR_FILE" != /* ]]; then
  VAR_FILE="$REPO_ROOT/$VAR_FILE"
fi

if [[ ! -f "$VAR_FILE" ]]; then
  echo "ERROR: variable file not found: $VAR_FILE" >&2
  exit 1
fi

if [[ "${OIC_LIFECYCLE_CONFIRM:-}" != "true" ]]; then
  echo "ERROR: refusing real OIC lifecycle without OIC_LIFECYCLE_CONFIRM=true." >&2
  exit 1
fi

source "$REPO_ROOT/scripts/terraform-env.sh"
terraform_env_export_common

export OCI_PROFILE="$OCI_PROFILE_VALUE"
export OCI_CLI_PROFILE="$OCI_PROFILE_VALUE"
if [[ -n "$OCI_REGION_VALUE" ]]; then
  export OCI_REGION="$OCI_REGION_VALUE"
fi

cd "$BLUEPRINT_DIR"
rm -f "$PLAN_FILE"

echo "==> OIC lifecycle target: ${BLUEPRINT_DIR#$REPO_ROOT/}"
echo "==> Variable file: ${VAR_FILE#$REPO_ROOT/}"
echo "==> OCI profile: $OCI_PROFILE_VALUE"
if [[ -n "$OCI_REGION_VALUE" ]]; then
  echo "==> OCI region: $OCI_REGION_VALUE"
fi

echo "==> terraform fmt -check"
terraform fmt -check -recursive

echo "==> terraform init -backend=false"
terraform init -backend=false -input=false -no-color

echo "==> terraform validate"
terraform validate -no-color

echo "==> terraform plan"
terraform plan -input=false -no-color -var-file="$VAR_FILE" -out="$PLAN_FILE"

apply_rc=0
verify_rc=0
destroy_rc=0
post_destroy_rc=0

echo "==> terraform apply"
set +e
terraform apply -input=false -no-color "$PLAN_FILE"
apply_rc=$?
set -e

if [[ "$apply_rc" -eq 0 ]]; then
  echo "==> terraform output -json"
  terraform output -json

  instance_id="$(terraform output -raw integration_instance_id 2>/dev/null || true)"
  if [[ -n "$instance_id" && "$instance_id" != "null" ]]; then
    echo "==> OCI verify OIC instance exists: $instance_id"
    oci_instance_args=(
      integration integration-instance get
      --id "$instance_id"
      --profile "$OCI_PROFILE_VALUE"
      --output table
      --query 'data.{id:id,displayName:"display-name",state:"lifecycle-state"}'
    )
    if [[ -n "$OCI_REGION_VALUE" ]]; then
      oci_instance_args+=(--region "$OCI_REGION_VALUE")
    fi

    set +e
    oci "${oci_instance_args[@]}"
    verify_rc=$?
    set -e
  else
    echo "==> No OIC instance output found; verification failed."
    verify_rc=1
  fi
else
  echo "==> Apply failed with rc=$apply_rc; destroy will still be attempted."
fi

if [[ "$KEEP_RESOURCES" == "true" ]]; then
  echo "==> keeping OIC lifecycle resources; destroy skipped by request."
  echo "==> OIC lifecycle result apply=${apply_rc} verify=${verify_rc} destroy=skipped post_destroy=skipped"
  if [[ "$apply_rc" -ne 0 || "$verify_rc" -ne 0 ]]; then
    exit 1
  fi
  exit 0
fi

echo "==> terraform destroy"
set +e
terraform destroy -auto-approve -input=false -no-color -var-file="$VAR_FILE"
destroy_rc=$?
set -e

echo "==> post-destroy Terraform state check"
managed_state="$(terraform state list 2>/dev/null | grep -v '^data\.' || true)"
if [[ -n "$managed_state" ]]; then
  echo "$managed_state" >&2
  post_destroy_rc=1
else
  echo "No managed Terraform resources remain in state."
fi

rm -f "$PLAN_FILE"

echo "==> OIC lifecycle result apply=${apply_rc} verify=${verify_rc} destroy=${destroy_rc} post_destroy=${post_destroy_rc}"
if [[ "$apply_rc" -ne 0 || "$verify_rc" -ne 0 || "$destroy_rc" -ne 0 || "$post_destroy_rc" -ne 0 ]]; then
  exit 1
fi
