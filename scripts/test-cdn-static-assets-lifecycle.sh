#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BLUEPRINT_DIR="$REPO_ROOT/blueprints/extensions/cdn-static-assets"
DEFAULT_VAR_FILE="$REPO_ROOT/.leo-local/cdn-static-assets.tfvars"
VAR_FILE=""
OCI_PROFILE_VALUE="${OCI_PROFILE:-${OCI_CLI_PROFILE:-DEFAULT}}"
OCI_REGION_VALUE="${OCI_REGION:-}"
PLAN_FILE="tfplan.cdn-static-assets-e2e"
KEEP_RESOURCES="${CDN_STATIC_ASSETS_LIFECYCLE_KEEP_RESOURCES:-false}"

usage() {
  cat <<'USAGE'
Usage:
  scripts/test-cdn-static-assets-lifecycle.sh [--var-file <path>] [--profile <oci-profile>] [--region <oci-region>] [--keep-resources]

Purpose:
  Run a real CDN Static Asset Distribution lifecycle test: fmt, init,
  validate, plan, apply, Object Storage bucket/object/PAR verification, real
  PAR curl download, destroy, and post-destroy state check. If --var-file is
  omitted, the script uses .leo-local/cdn-static-assets.tfvars.

Safety:
  Set CDN_STATIC_ASSETS_LIFECYCLE_CONFIRM=true to allow the real apply
  lifecycle. Without --keep-resources, destroy is always attempted after an
  apply attempt. Pass --keep-resources or set
  CDN_STATIC_ASSETS_LIFECYCLE_KEEP_RESOURCES=true to skip destroy after apply
  and verification.
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

if [[ "${CDN_STATIC_ASSETS_LIFECYCLE_CONFIRM:-}" != "true" ]]; then
  echo "ERROR: refusing real CDN static assets lifecycle without CDN_STATIC_ASSETS_LIFECYCLE_CONFIRM=true." >&2
  exit 1
fi

source "$REPO_ROOT/scripts/terraform-env.sh"
terraform_env_export_common

export OCI_PROFILE="$OCI_PROFILE_VALUE"
export OCI_CLI_PROFILE="$OCI_PROFILE_VALUE"
export SUPPRESS_LABEL_WARNING="${SUPPRESS_LABEL_WARNING:-True}"
if [[ -n "$OCI_REGION_VALUE" ]]; then
  export OCI_REGION="$OCI_REGION_VALUE"
fi

cd "$BLUEPRINT_DIR"
rm -f "$PLAN_FILE"

echo "==> CDN static assets lifecycle target: ${BLUEPRINT_DIR#$REPO_ROOT/}"
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

oci_common_args=(--profile "$OCI_PROFILE_VALUE")
if [[ -n "$OCI_REGION_VALUE" ]]; then
  oci_common_args+=(--region "$OCI_REGION_VALUE")
fi

if [[ "$apply_rc" -eq 0 ]]; then
  echo "==> terraform output -json (sensitive values masked)"
  terraform output -json | jq 'with_entries(if .value.sensitive then .value.value = "<sensitive>" else . end)'

  namespace="$(terraform output -raw namespace 2>/dev/null || true)"
  bucket_name="$(terraform output -raw asset_bucket_name 2>/dev/null || true)"
  if [[ -z "$namespace" || "$namespace" == "null" || -z "$bucket_name" || "$bucket_name" == "null" ]]; then
    echo "ERROR: namespace or asset_bucket_name output was empty." >&2
    verify_rc=1
  fi

  if [[ "$verify_rc" -eq 0 ]]; then
    echo "==> OCI verify bucket exists: $bucket_name"
    set +e
    oci os bucket get \
      --namespace-name "$namespace" \
      --bucket-name "$bucket_name" \
      "${oci_common_args[@]}" \
      --output table \
      --query 'data.{name:name,access:"public-access-type",versioning:versioning}'
    bucket_rc=$?
    set -e
    if [[ "$bucket_rc" -ne 0 ]]; then
      verify_rc="$bucket_rc"
    fi
  fi

  if [[ "$verify_rc" -eq 0 ]]; then
    echo "==> OCI verify public sample object metadata"
    set +e
    oci os object head \
      --namespace-name "$namespace" \
      --bucket-name "$bucket_name" \
      --name "public/index.html" \
      "${oci_common_args[@]}"
    public_head_rc=$?
    set -e
    if [[ "$public_head_rc" -ne 0 ]]; then
      verify_rc="$public_head_rc"
    fi
  fi

  if [[ "$verify_rc" -eq 0 ]]; then
    echo "==> OCI verify private sample object metadata"
    set +e
    oci os object head \
      --namespace-name "$namespace" \
      --bucket-name "$bucket_name" \
      --name "private/demo-statement.txt" \
      "${oci_common_args[@]}"
    private_head_rc=$?
    set -e
    if [[ "$private_head_rc" -ne 0 ]]; then
      verify_rc="$private_head_rc"
    fi
  fi

  if [[ "$verify_rc" -eq 0 ]]; then
    echo "==> OCI verify PAR exists"
    set +e
    par_list_output="$(oci os preauth-request list \
      --namespace-name "$namespace" \
      --bucket-name "$bucket_name" \
      "${oci_common_args[@]}" \
      --output json 2>&1)"
    par_list_rc=$?
    set -e
    echo "$par_list_output"
    if [[ "$par_list_rc" -ne 0 ]]; then
      verify_rc="$par_list_rc"
    elif [[ "$par_list_output" != *"private/demo-statement.txt"* ]]; then
      echo "ERROR: expected PAR for private/demo-statement.txt was not returned." >&2
      verify_rc=1
    fi
  fi

  if [[ "$verify_rc" -eq 0 ]]; then
    echo "==> curl smoke test through Terraform-managed PAR"
    par_url="$(terraform output -json preauth_request_urls | jq -r '.statement_demo // empty')"
    if [[ -z "$par_url" ]]; then
      echo "ERROR: statement_demo PAR URL output was empty." >&2
      verify_rc=1
    else
      set +e
      par_body="$(curl --fail --silent --show-error "$par_url" 2>&1)"
      curl_rc=$?
      set -e
      echo "$par_body"
      if [[ "$curl_rc" -ne 0 ]]; then
        verify_rc="$curl_rc"
      elif [[ "$par_body" != *"Synthetic statement for PAR smoke tests"* ]]; then
        echo "ERROR: PAR response body did not match expected sample content." >&2
        verify_rc=1
      fi
    fi
  fi

  cloudflare_zone_id="$(terraform output -json cdn_handoff | jq -r '.cloudflare_zone_id // empty')"
  cloudflare_dns_record_id="$(terraform output -json cdn_handoff | jq -r '.cloudflare_dns_record_id // empty')"
  cloudflare_cache_ruleset_id="$(terraform output -json cdn_handoff | jq -r '.cloudflare_cache_ruleset_id // empty')"
  cloudflare_origin_ruleset_id="$(terraform output -json cdn_handoff | jq -r '.cloudflare_origin_ruleset_id // empty')"
  cloudflare_worker_script_id="$(terraform output -json cdn_handoff | jq -r '.cloudflare_worker_script_id // empty')"
  cloudflare_worker_route_id="$(terraform output -json cdn_handoff | jq -r '.cloudflare_worker_route_id // empty')"

  if [[ "$verify_rc" -eq 0 && -n "$cloudflare_dns_record_id" ]]; then
    if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
      echo "ERROR: Cloudflare DNS record was created but CLOUDFLARE_API_TOKEN is not set for verification." >&2
      verify_rc=1
    else
      echo "==> Cloudflare verify DNS record exists"
      set +e
      cloudflare_dns_output="$(curl --fail --silent --show-error \
        -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
        "https://api.cloudflare.com/client/v4/zones/${cloudflare_zone_id}/dns_records/${cloudflare_dns_record_id}" 2>&1)"
      cloudflare_dns_rc=$?
      set -e
      echo "$cloudflare_dns_output" | jq '{success, result: {id: .result.id, name: .result.name, type: .result.type, proxied: .result.proxied}}'
      if [[ "$cloudflare_dns_rc" -ne 0 ]]; then
        verify_rc="$cloudflare_dns_rc"
      fi
    fi
  fi

  if [[ "$verify_rc" -eq 0 && -n "$cloudflare_cache_ruleset_id" ]]; then
    if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
      echo "ERROR: Cloudflare cache ruleset was created but CLOUDFLARE_API_TOKEN is not set for verification." >&2
      verify_rc=1
    else
      echo "==> Cloudflare verify cache ruleset exists"
      set +e
      cloudflare_cache_output="$(curl --fail --silent --show-error \
        -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
        "https://api.cloudflare.com/client/v4/zones/${cloudflare_zone_id}/rulesets/${cloudflare_cache_ruleset_id}" 2>&1)"
      cloudflare_cache_rc=$?
      set -e
      echo "$cloudflare_cache_output" | jq '{success, result: {id: .result.id, name: .result.name, phase: .result.phase}}'
      if [[ "$cloudflare_cache_rc" -ne 0 ]]; then
        verify_rc="$cloudflare_cache_rc"
      fi
    fi
  fi

  if [[ "$verify_rc" -eq 0 && -n "$cloudflare_origin_ruleset_id" ]]; then
    echo "==> Cloudflare verify origin ruleset exists"
    set +e
    cloudflare_origin_output="$(curl --fail --silent --show-error \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      "https://api.cloudflare.com/client/v4/zones/${cloudflare_zone_id}/rulesets/${cloudflare_origin_ruleset_id}" 2>&1)"
    cloudflare_origin_rc=$?
    set -e
    echo "$cloudflare_origin_output" | jq '{success, result: {id: .result.id, name: .result.name, phase: .result.phase}}'
    if [[ "$cloudflare_origin_rc" -ne 0 ]]; then
      verify_rc="$cloudflare_origin_rc"
    fi
  fi

  if [[ "$verify_rc" -eq 0 && -n "$cloudflare_worker_script_id" && -n "$cloudflare_worker_route_id" ]]; then
    echo "==> Cloudflare Worker resources present: script=${cloudflare_worker_script_id} route=${cloudflare_worker_route_id}"
  fi

  if [[ "$verify_rc" -eq 0 && "${CDN_STATIC_ASSETS_VERIFY_CLOUDFLARE:-false}" == "true" ]]; then
    echo "==> Cloudflare proxied curl smoke test"
    cloudflare_smoke_url="$(terraform output -json cloudflare_smoke_test_url | jq -r '. // empty')"
    if [[ -z "$cloudflare_smoke_url" || "$cloudflare_smoke_url" == "null" ]]; then
      echo "ERROR: cloudflare_smoke_test_url output was empty." >&2
      verify_rc=1
    else
      cloudflare_curl_rc=1
      cloudflare_body=""
      for attempt in $(seq 1 12); do
        set +e
        cloudflare_body="$(curl --fail --silent --show-error --include "$cloudflare_smoke_url" 2>&1)"
        cloudflare_curl_rc=$?
        set -e
        if [[ "$cloudflare_curl_rc" -eq 0 && "$cloudflare_body" == *"Synthetic Cloudflare smoke test asset"* ]]; then
          break
        fi
        echo "Cloudflare smoke test attempt ${attempt} did not return the expected body; retrying."
        sleep 5
      done
      echo "$cloudflare_body"
      if [[ "$cloudflare_curl_rc" -ne 0 ]]; then
        verify_rc="$cloudflare_curl_rc"
      elif [[ "$cloudflare_body" != *"Synthetic Cloudflare smoke test asset"* ]]; then
        echo "ERROR: Cloudflare smoke-test body did not match expected sample content." >&2
        verify_rc=1
      elif [[ -n "$cloudflare_worker_route_id" && "$(printf "%s" "$cloudflare_body" | tr '[:upper:]' '[:lower:]')" != *"x-oci-lz-cloudflare-proxy: worker"* ]]; then
        echo "ERROR: Cloudflare Worker response header was not returned." >&2
        verify_rc=1
      fi
    fi
  fi
else
  echo "==> Apply failed with rc=$apply_rc; destroy will still be attempted."
fi

if [[ "$KEEP_RESOURCES" == "true" ]]; then
  echo "==> keeping CDN static asset lifecycle resources; destroy skipped by request."
  echo "==> CDN static assets lifecycle result apply=${apply_rc} verify=${verify_rc} destroy=skipped post_destroy=skipped"
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

echo "==> CDN static assets lifecycle result apply=${apply_rc} verify=${verify_rc} destroy=${destroy_rc} post_destroy=${post_destroy_rc}"
if [[ "$apply_rc" -ne 0 || "$verify_rc" -ne 0 || "$destroy_rc" -ne 0 || "$post_destroy_rc" -ne 0 ]]; then
  exit 1
fi
