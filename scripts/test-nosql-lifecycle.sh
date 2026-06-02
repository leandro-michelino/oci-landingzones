#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BLUEPRINT_DIR="$REPO_ROOT/blueprints/data-platform/nosql"
DEFAULT_VAR_FILE="$REPO_ROOT/.leo-local/nosql-saopaulo.tfvars"
VAR_FILE=""
OCI_PROFILE_VALUE="${OCI_PROFILE:-${OCI_CLI_PROFILE:-DEFAULT}}"
OCI_REGION_VALUE="${OCI_REGION:-}"
PLAN_FILE="tfplan.nosql-e2e"
KEEP_RESOURCES="${NOSQL_LIFECYCLE_KEEP_RESOURCES:-false}"

usage() {
  cat <<'USAGE'
Usage:
  scripts/test-nosql-lifecycle.sh [--var-file <path>] [--profile <oci-profile>] [--region <oci-region>] [--keep-resources]

Purpose:
  Run a real OCI NoSQL lifecycle test: fmt, init, validate, plan, apply,
  table/index verification through OCI CLI, destroy, and post-destroy state
  check. If --var-file is omitted, the script uses
  .leo-local/nosql-saopaulo.tfvars.

Safety:
  Set NOSQL_LIFECYCLE_CONFIRM=true to allow the real apply lifecycle.
  Without --keep-resources, destroy is always attempted after an apply attempt.
  Pass --keep-resources or set NOSQL_LIFECYCLE_KEEP_RESOURCES=true to skip
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

if [[ "${NOSQL_LIFECYCLE_CONFIRM:-}" != "true" ]]; then
  echo "ERROR: refusing real NoSQL lifecycle without NOSQL_LIFECYCLE_CONFIRM=true." >&2
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

echo "==> NoSQL lifecycle target: ${BLUEPRINT_DIR#$REPO_ROOT/}"
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

  table_id="$(terraform output -raw nosql_table_id 2>/dev/null || true)"
  table_name="$(terraform output -raw nosql_table_name 2>/dev/null || true)"
  if [[ -n "$table_id" && "$table_id" != "null" ]]; then
    echo "==> OCI verify NoSQL table exists: $table_id"
    oci_table_args=(
      nosql table get
      --table-name-or-id "$table_id"
      --profile "$OCI_PROFILE_VALUE"
      --output table
      --query 'data.{id:id,name:name,state:"lifecycle-state"}'
    )
    if [[ -n "$OCI_REGION_VALUE" ]]; then
      oci_table_args+=(--region "$OCI_REGION_VALUE")
    fi

    set +e
    oci "${oci_table_args[@]}"
    verify_rc=$?
    set -e
  else
    echo "==> No NoSQL table output found; skipping OCI table lookup."
    verify_rc=1
  fi

  index_name="$(terraform output -raw nosql_secondary_index_name 2>/dev/null || true)"
  if [[ "$verify_rc" -eq 0 && -n "$index_name" && "$index_name" != "null" && -n "$table_name" && "$table_name" != "null" ]]; then
    echo "==> OCI verify NoSQL secondary index exists: $index_name"
    oci_index_args=(
      nosql index list
      --table-name-or-id "$table_id"
      --profile "$OCI_PROFILE_VALUE"
      --name "$index_name"
      --output json
      --query 'data.items[*].{name:name,state:"lifecycle-state"}'
    )
    if [[ -n "$OCI_REGION_VALUE" ]]; then
      oci_index_args+=(--region "$OCI_REGION_VALUE")
    fi

    set +e
    index_output="$(oci "${oci_index_args[@]}" 2>&1)"
    index_rc=$?
    set -e
    echo "$index_output"
    if [[ "$index_rc" -ne 0 ]]; then
      verify_rc="$index_rc"
    elif [[ "$index_output" != *"$index_name"* ]]; then
      echo "ERROR: NoSQL secondary index was not returned by OCI CLI: $index_name" >&2
      verify_rc=1
    fi
  fi
else
  echo "==> Apply failed with rc=$apply_rc; destroy will still be attempted."
fi

if [[ "$KEEP_RESOURCES" == "true" ]]; then
  echo "==> keeping NoSQL lifecycle resources; destroy skipped by request."
  echo "==> NoSQL lifecycle result apply=${apply_rc} verify=${verify_rc} destroy=skipped post_destroy=skipped"
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

echo "==> NoSQL lifecycle result apply=${apply_rc} verify=${verify_rc} destroy=${destroy_rc} post_destroy=${post_destroy_rc}"
if [[ "$apply_rc" -ne 0 || "$verify_rc" -ne 0 || "$destroy_rc" -ne 0 || "$post_destroy_rc" -ne 0 ]]; then
  exit 1
fi
