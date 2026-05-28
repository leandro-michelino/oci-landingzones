#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

fail() {
  echo "ERROR: $*" >&2
  failures=1
}

check_forbidden_markdown() {
  local pattern="$1"
  local matches

  if command -v rg >/dev/null 2>&1; then
    matches="$(
      rg -n --fixed-strings \
        --glob "*.md" \
        --glob "!**/.terraform/**" \
        --glob "!**/.git/**" \
        -- "$pattern" "$REPO_ROOT" || true
    )"
  else
    matches="$(
      find "$REPO_ROOT" \
        -path "*/.terraform/*" -prune -o \
        -path "*/.git/*" -prune -o \
        -name "*.md" -type f -exec grep -nH -F -- "$pattern" {} + || true
    )"
  fi

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "Forbidden markdown fragment found: $pattern"
  fi
}

check_forbidden_blueprint_tf_regex() {
  local regex="$1"
  local description="$2"
  local matches

  if command -v rg >/dev/null 2>&1; then
    matches="$(
      rg -n \
        --glob "*.tf" \
        --glob "!**/.terraform/**" \
        --glob "!**/.git/**" \
        -- "$regex" "$REPO_ROOT/blueprints" || true
    )"
  else
    matches="$(
      find "$REPO_ROOT/blueprints" \
        -path "*/.terraform/*" -prune -o \
        -path "*/.git/*" -prune -o \
        -name "*.tf" -type f -exec grep -nHE -- "$regex" {} + || true
    )"
  fi

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "$description"
  fi
}

check_file() {
  local path="$1"

  if [[ ! -f "$path" ]]; then
    fail "Missing required file: ${path#$REPO_ROOT/}"
  fi
}

check_contains() {
  local path="$1"
  local pattern="$2"
  local description="$3"

  if [[ -f "$path" ]] && ! grep -Fq -- "$pattern" "$path"; then
    fail "${path#$REPO_ROOT/} must contain $description."
  fi
}

check_min_lines() {
  local path="$1"
  local minimum="$2"
  local actual

  if [[ -f "$path" ]]; then
    actual="$(wc -l < "$path" | tr -d ' ')"
    if (( actual < minimum )); then
      fail "${path#$REPO_ROOT/} must contain at least $minimum lines for a detailed architecture file; found $actual."
    fi
  fi
}

check_architecture_file() {
  local path="$1"

  check_file "$path"
  check_min_lines "$path" 60
  check_contains "$path" "## Deployment Purpose" "Deployment Purpose section"
  check_contains "$path" "## Architecture At A Glance" "Architecture At A Glance section"
  check_contains "$path" "## Architecture" "Architecture section"
  check_contains "$path" '```text' "a fenced Architecture diagram"
  check_contains "$path" "## Terraform Components" "Terraform Components section"
  check_contains "$path" "## Request And Deployment Flow" "Request And Deployment Flow section"
  check_contains "$path" "## Traffic And Trust Boundaries" "Traffic And Trust Boundaries section"
  check_contains "$path" "## Detailed Architecture Notes" "Detailed Architecture Notes section"
  check_contains "$path" "## Operational Boundaries" "Operational Boundaries section"
  check_contains "$path" "## Review Checklist" "Review Checklist section"
}

check_blueprint_contract() {
  local dir="$1"
  local playbook
  local action

  check_file "$dir/README.md"
  check_architecture_file "$dir/architecture/README.md"
  check_file "$dir/main.tf"
  check_file "$dir/variables.tf"
  check_file "$dir/outputs.tf"
  check_file "$dir/providers.tf"
  check_file "$dir/versions.tf"
  check_file "$dir/terraform.tfvars.example"

  for action in plan apply destroy; do
    playbook="$dir/ansible/$action.yml"
    check_file "$playbook"
    check_contains "$playbook" "terraform_action: $action" "terraform_action: $action"
    check_contains "$playbook" "terraform_working_dir:" "terraform_working_dir"
  done
}

check_cloud_deployment_contract() {
  local dir="$1"
  local provider="$2"
  local template="$3"
  local parameters="$4"
  local playbook
  local action

  check_file "$dir/$provider/README.md"
  check_file "$dir/$provider/$template"
  check_file "$dir/$provider/$parameters"

  for action in plan apply destroy; do
    playbook="$dir/ansible/$provider-$action.yml"
    check_file "$playbook"
    check_contains "$playbook" "${provider}_action: $action" "${provider}_action: $action"
    check_contains "$playbook" "${provider}_deployment_runner" "${provider}_deployment_runner role"
  done
}

check_brownfield_blueprint_contract() {
  local dir="$1"
  local relative_dir="${dir#$REPO_ROOT/}"

  case "$relative_dir" in
    blueprints/networking/externally-managed-vcns)
      check_contains "$dir/README.md" "Externally Managed VCNs" "brownfield blueprint title"
      check_contains "$dir/variables.tf" 'variable "vcn_ids"' "externally managed VCN inputs"
      check_contains "$dir/variables.tf" 'variable "subnet_ids"' "externally managed subnet inputs"
      check_contains "$dir/variables.tf" 'variable "route_target_ids"' "externally managed route target inputs"
      check_contains "$dir/outputs.tf" 'output "resource_ids"' "externally managed resource_ids output"
      return 0
      ;;
  esac

  return 1
}

check_deployable_blueprint_payload() {
  local dir="$1"
  local relative_dir="${dir#$REPO_ROOT/}"
  local scaffold_matches

  if check_brownfield_blueprint_contract "$dir"; then
    return 0
  fi

  if ! grep -REq '^[[:space:]]*(resource|module)[[:space:]]+"' "$dir"/*.tf; then
    fail "${relative_dir} must create OCI resources directly, compose resource-bearing modules/blueprints, or be listed as an explicit brownfield contract."
  fi

  if command -v rg >/dev/null 2>&1; then
    scaffold_matches="$(
      rg -n --fixed-strings \
        --glob "*.tf" \
        --glob "*.md" \
        -e "Add OCI resources and release-pinned module sources here" \
        -e "moves from scaffold to delivery" \
        -e "Starts a naming-compliant OCI blueprint" \
        -e "Scaffold with standard providers" \
        "$dir" || true
    )"
  else
    scaffold_matches="$(
      find "$dir" \
        \( -name "*.tf" -o -name "*.md" \) \
        -type f -exec grep -nHE \
        "Add OCI resources and release-pinned module sources here|moves from scaffold to delivery|Starts a naming-compliant OCI blueprint|Scaffold with standard providers" {} + || true
    )"
  fi

  if [[ -n "$scaffold_matches" ]]; then
    echo "$scaffold_matches" >&2
    fail "${relative_dir} still contains scaffold-only blueprint text."
  fi

  if [[ -f "$dir/aws/main.yaml" ]] && ! grep -Eq 'Type:[[:space:]]+AWS::' "$dir/aws/main.yaml"; then
    fail "${relative_dir}/aws/main.yaml must define real AWS CloudFormation resources."
  fi

  if [[ -f "$dir/azure/main.bicep" ]] && ! grep -Eq '^[[:space:]]*resource[[:space:]]+[[:alnum:]_]+' "$dir/azure/main.bicep"; then
    fail "${relative_dir}/azure/main.bicep must define real Azure Bicep resources."
  fi
}

check_architecture_inventory_count() {
  local architecture_index="$REPO_ROOT/docs/architecture/README.md"
  local actual_count
  local table_count
  local stated_count

  check_file "$architecture_index"

  actual_count="$(
    find "$REPO_ROOT/blueprints" \
      -path "*/.terraform/*" -prune -o \
      -name "main.tf" -type f -print | wc -l | tr -d ' '
  )"

  table_count="$(
    awk -F'|' '/^\| [^|]+ \| \[/ && $2 !~ /Family/ { count++ } END { print count + 0 }' \
      "$architecture_index"
  )"

  stated_count="$(
    sed -nE 's/^The current catalog has ([0-9]+) deployable blueprint entry points.*/\1/p' \
      "$architecture_index" | head -n 1
  )"

  if [[ "$table_count" != "$actual_count" ]]; then
    fail "docs/architecture/README.md table lists $table_count blueprints, but $actual_count deployable Terraform entry points exist."
  fi

  if [[ "$stated_count" != "$actual_count" ]]; then
    fail "docs/architecture/README.md stated blueprint count is ${stated_count:-missing}, but $actual_count deployable Terraform entry points exist."
  fi
}

echo "==> Checking repository documentation and blueprint contracts"

"$REPO_ROOT/scripts/check-naming-conventions.sh"
"$REPO_ROOT/scripts/generate-blueprints-index.sh" --check
"$REPO_ROOT/scripts/check-markdown-links.sh"
check_architecture_inventory_count

check_forbidden_markdown "State, Inputs, And Outputs"
check_forbidden_markdown "Input sources"
check_forbidden_markdown "Terraform state"
check_forbidden_markdown "Output contract"
check_forbidden_markdown 'Confirm `terraform output` will expose'
check_forbidden_blueprint_tf_regex 'source[[:space:]]*=[[:space:]]*"\.\.?/' \
  "Deployable blueprints must not use local Terraform module source paths."

while IFS= read -r main_tf; do
  blueprint_dir="${main_tf%/main.tf}"
  check_blueprint_contract "$blueprint_dir"
  check_deployable_blueprint_payload "$blueprint_dir"
done < <(
  find "$REPO_ROOT/blueprints" \
    -path "*/.terraform/*" -prune -o \
    -name "main.tf" -type f -print | sort
)

while IFS= read -r template; do
  check_cloud_deployment_contract "${template%/aws/main.yaml}" "aws" "main.yaml" "parameters.example.json"
done < <(
  find "$REPO_ROOT/blueprints" \
    -path "*/.terraform/*" -prune -o \
    -path "*/aws/main.yaml" -type f -print | sort
)

while IFS= read -r template; do
  check_cloud_deployment_contract "${template%/azure/main.bicep}" "azure" "main.bicep" "parameters.example.json"
done < <(
  find "$REPO_ROOT/blueprints" \
    -path "*/.terraform/*" -prune -o \
    -path "*/azure/main.bicep" -type f -print | sort
)

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "Repository contracts look consistent."
