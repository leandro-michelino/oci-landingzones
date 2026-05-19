#!/usr/bin/env bash
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

fail() {
  echo "ERROR: $*" >&2
  failures=1
}

check_standard_name_prefix_locals() {
  local matches

  matches="$(
    rg -n 'name_prefix[[:space:]]*=' \
      --glob '*.tf' \
      --glob '!**/.terraform/**' \
      --glob '!**/.git/**' \
      "$REPO_ROOT/blueprints" "$REPO_ROOT/modules" |
      grep -Ev 'name_prefix[[:space:]]*=[[:space:]]*"\$\{var\.org\}-\$\{var\.environment\}-\$\{var\.region_key\}"|secondary_name_prefix[[:space:]]*=[[:space:]]*"\$\{var\.org\}-\$\{var\.environment\}-\$\{var\.secondary_region_key\}"|standby_name_prefix[[:space:]]*=[[:space:]]*"\$\{var\.org\}-\$\{var\.environment\}-\$\{var\.standby_region_key\}"|object_name_prefix[[:space:]]*=' || true
  )"

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "All Terraform name_prefix locals must use org-environment-region_key only."
  fi
}

check_generated_name_literals() {
  local matches

  matches="$(
    perl -ne '
      while (/\$\{local\.(?:name_prefix|secondary_name_prefix|standby_name_prefix)\}-([^"]+)/g) {
        my $suffix = $1;
        $suffix =~ s/\$\{[^}]+\}//g;
        if ($suffix =~ /[A-Z_]/) {
          print "$ARGV:$.:$suffix\n";
        }
      }
      close ARGV if eof;
    ' $(rg --files -g '*.tf' "$REPO_ROOT/blueprints" "$REPO_ROOT/modules") || true
  )"

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "Generated names must use lowercase alphanumeric or hyphen-delimited suffixes."
  fi
}

check_generated_name_resource_types() {
  local matches

  matches="$(
    perl -ne '
      BEGIN {
        %allowed = map { $_ => 1 } qw(
          adb agent aip alm apidep apigw apm app bgt bgtal bkt bset bst build cg
          ci cluster cmp cpe db deploy dgrp dns dr drg drga drpg ds dst ep evt
          exa fc fn grp idd igw inst ip job key kb lb lg lis log model nat nfw
          nfwpol nlb np nsg nva oac oic oke opt osmh pac pe pol pool proj redis
          repo rt sch sec sgw sl sn stream streampool sz tns top tool up vcn vlt
          vnic vpn vss waf wafpol wl zpr
        );
      }
      while (/\$\{local\.(?:name_prefix|secondary_name_prefix|standby_name_prefix)\}-([^"]+)/g) {
        my $suffix = $1;
        $suffix =~ s/\$\{[^}]+\}/VAR/g;
        my ($prefix) = split /-/, $suffix;
        if (!$allowed{$prefix}) {
          print "$ARGV:$.:$prefix\n";
        }
      }
      close ARGV if eof;
    ' $(rg --files -g '*.tf' "$REPO_ROOT/blueprints" "$REPO_ROOT/modules") || true
  )"

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "Generated names must place a documented OCI resource-type token after the shared prefix."
  fi
}

check_nonstandard_prefix_rewrites() {
  local matches

  matches="$(
    rg -n 'replace\(local\.(name_prefix|secondary_name_prefix|standby_name_prefix), "-",' \
      --glob '*.tf' \
      --glob '!**/.terraform/**' \
      "$REPO_ROOT/blueprints" "$REPO_ROOT/modules" || true
  )"

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "Generated names must not rewrite the shared prefix with alternate separators."
  fi

  matches="$(
    rg -n '\$\{local\.(name_prefix|secondary_name_prefix|standby_name_prefix)\}/' \
      --glob '*.tf' \
      --glob '!**/.terraform/**' \
      "$REPO_ROOT/blueprints" "$REPO_ROOT/modules" || true
  )"

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "Generated names must use hyphen-delimited OCI naming tokens after the shared prefix."
  fi
}

check_azure_parameter_name_values() {
  local file
  local matches=""

  while IFS= read -r file; do
    local file_matches
    file_matches="$(
      perl -0777 -ne '
        while (/"(logAnalyticsWorkspaceName|managedEnvironmentName|containerAppName|vnetName|containerAppSubnetName|routeTableName|networkSecurityGroupName|clusterName|nodePoolName|aksSubnetName|openAiAccountName|openAiCustomSubdomain|apimServiceName|dnsPrefix)"\s*:\s*\{\s*"value"\s*:\s*"([^"]+)"/sg) {
          $key = $1;
          $value = $2;
          if ($value !~ /^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/) {
            print "$ARGV:$key=$value\n";
          }
        }
      ' "$file"
    )"
    if [[ -n "$file_matches" ]]; then
      matches+="$file_matches"$'\n'
    fi
  done < <(
    find "$REPO_ROOT/blueprints" \
      -path "*/.terraform/*" -prune -o \
      -path "*/.git/*" -prune -o \
      -path "*/azure/parameters.example.json" -type f -print | sort
  )

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "Azure deployment parameter names must use lowercase alphanumeric and hyphen conventions."
  fi
}

check_azure_bicep_default_names() {
  local file
  local matches=""

  while IFS= read -r file; do
    local file_matches
    file_matches="$(
      perl -ne '
        if (/^param[[:space:]]+(vnetName|containerAppSubnetName|routeTableName|networkSecurityGroupName|nodePoolName)[[:space:]]+string[[:space:]]*=[[:space:]]*'\''([^'\'']+)'\''/) {
          $key = $1;
          $value = $2;
          if ($value !~ /^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/) {
            print "$ARGV:$.:$key=$value\n";
          }
        }
      ' "$file"
    )"
    if [[ -n "$file_matches" ]]; then
      matches+="$file_matches"$'\n'
    fi
  done < <(
    find "$REPO_ROOT/blueprints" \
      -path "*/.terraform/*" -prune -o \
      -path "*/.git/*" -prune -o \
      -path "*/azure/main.bicep" -type f -print | sort
  )

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "Azure Bicep default resource names must use lowercase alphanumeric and hyphen conventions."
  fi
}

check_aws_resource_labels() {
  local matches

  matches="$(
    perl -ne '
      if (/^[[:space:]]*resource[[:space:]]+"(aws_[^"]+)"[[:space:]]+"([^"]+)"/) {
        $label = $2;
        if ($label !~ /^[a-z][a-z0-9_]*$/) {
          print "$ARGV:$.:$label\n";
        }
      }
    ' $(rg --files -g '*.tf' "$REPO_ROOT/blueprints" "$REPO_ROOT/modules") || true
  )"

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "AWS Terraform resource labels must use snake_case."
  fi
}

check_aws_tag_key_prefix() {
  local matches

  matches="$(
    rg -n \
      --glob '*.tf' \
      --glob '!**/.terraform/**' \
      --glob '!**/.git/**' \
      -- '"aws:[^"]+"' "$REPO_ROOT/blueprints" "$REPO_ROOT/modules" || true
  )"

  if [[ -n "$matches" ]]; then
    echo "$matches" >&2
    fail "AWS user-defined tag keys must not use the reserved aws: prefix."
  fi
}

check_tfvars_examples() {
  local file
  local value
  local key
  local valid_region_keys

  valid_region_keys='^(ams|dxb|fra|gru|iad|jnb|lhr|mad|nrt|phx|syd)$'

  while IFS= read -r file; do
    while IFS='=' read -r key value; do
      key="$(echo "$key" | xargs)"
      value="$(echo "$value" | sed -E 's/[[:space:]]*#.*$//' | xargs)"
      value="${value%\"}"
      value="${value#\"}"

      case "$key" in
        org)
          [[ "$value" =~ ^[a-z][a-z0-9-]{1,15}$ ]] ||
            fail "${file#$REPO_ROOT/}: org must be lowercase alphanumeric or hyphenated, 2-16 chars."
          ;;
        environment)
          [[ "$value" =~ ^(dev|uat|prod|nonprod|dr)$ ]] ||
            fail "${file#$REPO_ROOT/}: environment must be dev, uat, prod, nonprod, or dr."
          ;;
        region_key|secondary_region_key|standby_region_key)
          [[ "$value" =~ $valid_region_keys ]] ||
            fail "${file#$REPO_ROOT/}: $key must use a documented OCI region key."
          ;;
      esac
    done < <(grep -E '^[[:space:]]*(org|environment|region_key|secondary_region_key|standby_region_key)[[:space:]]*=' "$file" || true)
  done < <(
    find "$REPO_ROOT/blueprints" "$REPO_ROOT/environments" \
      -path "*/.terraform/*" -prune -o \
      -name "terraform.tfvars.example" -type f -print | sort
  )
}

echo "==> Checking OCI, Azure, and AWS naming conventions"

check_standard_name_prefix_locals
check_generated_name_literals
check_generated_name_resource_types
check_nonstandard_prefix_rewrites
check_azure_parameter_name_values
check_azure_bicep_default_names
check_aws_resource_labels
check_aws_tag_key_prefix
check_tfvars_examples

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "OCI, Azure, and AWS naming conventions look consistent."
