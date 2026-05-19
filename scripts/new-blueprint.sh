#!/usr/bin/env bash
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'USAGE'
Usage:
  scripts/new-blueprint.sh <family> <name> [title]
  scripts/new-blueprint.sh <blueprints/path> [title]

Examples:
  scripts/new-blueprint.sh networking private-service-edge "Private Service Edge"
  scripts/new-blueprint.sh blueprints/extensions/example-service "Example Service"

Purpose:
  Scaffold a deployable OCI blueprint with Terraform, Ansible, README,
  architecture README, hello-world page, tfvars example, and naming-compliant
  defaults.
USAGE
}

slugify() {
  local value="$1"

  value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  value="$(printf '%s' "$value" | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
  printf '%s\n' "$value"
}

titleize() {
  local value="$1"

  value="${value//-/ }"
  awk '{
    for (i = 1; i <= NF; i++) {
      $i = toupper(substr($i, 1, 1)) substr($i, 2)
    }
    print
  }' <<< "$value"
}

write_file() {
  local path="$1"
  local content="$2"

  if [[ -e "$path" ]]; then
    echo "ERROR: Refusing to overwrite existing file: ${path#$REPO_ROOT/}" >&2
    exit 1
  fi

  printf '%s\n' "$content" > "$path"
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "$1" == blueprints/* ]]; then
  relative_dir="${1%/}"
  blueprint_slug="$(basename "$relative_dir")"
  title="${2:-$(titleize "$blueprint_slug")}"
else
  if [[ $# -lt 2 ]]; then
    usage
    exit 1
  fi
  family="$(slugify "$1")"
  blueprint_slug="$(slugify "$2")"
  relative_dir="blueprints/$family/$blueprint_slug"
  title="${3:-$(titleize "$blueprint_slug")}"
fi

if [[ -z "$relative_dir" || "$relative_dir" != blueprints/* ]]; then
  echo "ERROR: Blueprint path must live under blueprints/." >&2
  exit 1
fi

if [[ "$relative_dir" == *".."* ]]; then
  echo "ERROR: Blueprint path must not contain '..'." >&2
  exit 1
fi

target_dir="$REPO_ROOT/$relative_dir"
blueprint_name="${relative_dir#blueprints/}"
blueprint_name="${blueprint_name//\//-}"
name_token="${blueprint_slug%%-*}"
case "$name_token" in
  adb|agent|aip|alm|apidep|apigw|apm|app|bgt|bgtal|bkt|bset|bst|build|cg|ci|cluster|cmp|cpe|db|deploy|dgrp|dns|dr|drg|drga|drpg|ds|dst|ep|evt|exa|fc|fn|grp|idd|igw|inst|ip|job|key|kb|lb|lg|lis|log|model|nat|nfw|nfwpol|nlb|np|nsg|nva|oac|oic|oke|opt|osmh|pac|pe|pol|pool|proj|redis|repo|rt|sch|sec|sgw|sl|sn|stream|streampool|sz|tns|top|tool|up|vcn|vlt|vnic|vpn|vss|waf|wafpol|wl|zpr)
    resource_token="$name_token"
    ;;
  *)
    resource_token="app"
    ;;
esac

if [[ -e "$target_dir" ]]; then
  echo "ERROR: Blueprint directory already exists: $relative_dir" >&2
  exit 1
fi

mkdir -p "$target_dir/architecture" "$target_dir/ansible" "$target_dir/hello-world"

component_count="$(awk -F/ '{ print NF }' <<< "$relative_dir")"
role_prefix=""
for _ in $(seq 1 $((component_count + 1))); do
  role_prefix+="../"
done

read -r -d '' versions_tf <<EOF || true
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
terraform {
  required_version = ">= 1.12.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
  }
}
EOF

read -r -d '' providers_tf <<EOF || true
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  region              = var.region
  config_file_profile = var.oci_config_profile
}
EOF

read -r -d '' variables_tf <<EOF || true
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "current_user_ocid" {
  description = "OCI user OCID used for local execution or bootstrap."
  type        = string
}

variable "region" {
  description = "OCI region name, such as eu-madrid-1."
  type        = string
}

variable "oci_config_profile" {
  description = "Optional OCI CLI config profile for local execution."
  type        = string
  default     = null
}

variable "org" {
  description = "Short organization prefix used in OCI resource names."
  type        = string
  default     = "acme"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "region_key" {
  description = "Short OCI region key used in resource names."
  type        = string
  default     = "mad"
}

variable "defined_tags" {
  description = "Defined tags applied to created resources."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags applied to created resources."
  type        = map(string)
  default     = {}
}
EOF

read -r -d '' locals_tf <<EOF || true
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name = "$blueprint_name"
  name_prefix    = "\${var.org}-\${var.environment}-\${var.region_key}"

  common_freeform_tags = merge(
    {
      Blueprint = local.blueprint_name
      ManagedBy = "terraform"
    },
    var.freeform_tags
  )

  example_resource_name = "\${local.name_prefix}-$resource_token-$blueprint_slug"
}
EOF

read -r -d '' main_tf <<EOF || true
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
# Add OCI resources and release-pinned module sources here as the blueprint
# moves from scaffold to implementation.
EOF

read -r -d '' outputs_tf <<EOF || true
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this blueprint."
  value       = local.name_prefix
}

output "example_resource_name" {
  description = "Naming-compliant example resource name for implementation work."
  value       = local.example_resource_name
}
EOF

read -r -d '' tfvars_example <<EOF || true
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
tenancy_ocid      = "ocid1.tenancy.oc1..example"
current_user_ocid = "ocid1.user.oc1..example"
region            = "eu-madrid-1"

org         = "acme"
environment = "dev"
region_key  = "mad"

defined_tags  = {}
freeform_tags = {}
EOF

read -r -d '' readme_md <<EOF || true
# $title

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for \`$relative_dir\`. It explains the
deployment intent, the local workflow, and the review path before real OCI
resources are added.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | \`$relative_dir\` |
| Best fit | Starts a naming-compliant OCI blueprint for $title. |
| Terraform shape | Scaffold with standard providers, variables, locals, outputs, and tfvars example. |
| Inputs to settle first | \`tenancy_ocid\`, \`current_user_ocid\`, \`region\`, \`org\`, \`environment\`, and \`region_key\`. |
| Outputs to hand off | \`blueprint_name\`, \`name_prefix\`, and \`example_resource_name\`. |
| Local runner | \`terraform plan\` for quick iteration; \`ansible/plan.yml\` and guarded \`ansible/apply.yml\` for the repo-standard flow. |

## Deployment Purpose

Use this scaffold when a new OCI landing-zone pattern needs a consistent folder
shape before the service-specific resources are implemented.

## Folder Contract

\`\`\`text
$relative_dir/
|-- README.md
|-- architecture/README.md
|-- hello-world/index.html
|-- main.tf
|-- locals.tf
|-- variables.tf
|-- outputs.tf
|-- providers.tf
|-- versions.tf
|-- terraform.tfvars.example
\`-- ansible/
    |-- plan.yml
    |-- apply.yml
    \`-- destroy.yml
\`\`\`

## Local Workflow

\`\`\`bash
cd $relative_dir
cp terraform.tfvars.example terraform.tfvars
terraform init -backend=false
terraform validate
terraform plan
\`\`\`

Or use the shared local runner:

\`\`\`bash
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
\`\`\`

## Review Path

- Replace the scaffold notes in \`main.tf\` with release-pinned module sources
  or direct OCI resources.
- Keep generated names behind \`local.name_prefix\` and documented OCI resource
  tokens.
- Update \`architecture/README.md\` when components, traffic paths, trust
  boundaries, or operator hand-offs change.
- Run \`make blueprints validate\` before opening a pull request.
EOF

read -r -d '' architecture_md <<EOF || true
# $title Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

This architecture page starts the review record for \`$relative_dir\`. The
scaffold is intentionally small so the first implementation can add real OCI
resources without changing the repository contract.

## Architecture At A Glance

| Layer | Current Shape |
| --- | --- |
| Operator | Supplies local tfvars and runs Terraform directly or through Ansible. |
| Terraform | Defines standard provider wiring, shared variables, naming locals, and outputs. |
| OCI | Ready for service-specific resources, modules, and data sources. |
| Review | Tracks deployment intent, trust boundaries, and hand-off expectations. |

## ASCII Architecture

\`\`\`text
+-------------------------+
| Operator Workstation    |
| terraform / ansible     |
+-----------+-------------+
            |
            v
+-------------------------+
| $relative_dir
| - providers.tf          |
| - variables.tf          |
| - locals.tf             |
| - main.tf               |
| - outputs.tf            |
+-----------+-------------+
            |
            v
+-------------------------+
| OCI Tenancy             |
| service resources added |
| during implementation   |
+-------------------------+
\`\`\`

## Terraform Components

| File | Role |
| --- | --- |
| \`versions.tf\` | Pins the Terraform and OCI provider contract. |
| \`providers.tf\` | Connects Terraform to the target OCI tenancy and region. |
| \`variables.tf\` | Holds the shared input shape used across blueprints. |
| \`locals.tf\` | Defines \`blueprint_name\`, \`name_prefix\`, tags, and an example generated resource name. |
| \`main.tf\` | Implementation home for OCI resources and release-pinned modules. |
| \`outputs.tf\` | Exposes stable hand-off values for downstream documentation and automation. |

## Request And Deployment Flow

1. The operator creates a local ignored \`terraform.tfvars\` from the example.
2. Terraform loads the OCI provider, standard identity inputs, and naming locals.
3. Implementation resources use \`local.name_prefix\` plus a resource-type token.
4. \`terraform plan\` shows the proposed OCI changes for review.
5. A guarded Ansible apply can run the same working directory after approval.

## Traffic And Trust Boundaries

The scaffold does not create network traffic yet. When resources are added,
document every ingress path, egress path, private endpoint, public endpoint,
service gateway dependency, and administrative control plane boundary here.

The main trust boundary is between the local operator workstation and the target
OCI tenancy. Keep credentials in the local OCI CLI profile or environment and
avoid committing real OCIDs, secrets, private endpoints, or customer values.

## Detailed Architecture Notes

Use this section to replace scaffold assumptions with the concrete deployment
shape. Capture the compartments, IAM policies, VCNs, subnets, gateways, service
resources, logging hooks, monitoring hooks, and security controls that matter to
the pattern.

Prefer small, reviewable Terraform modules or direct resources that follow the
repository naming convention. Customer-facing blueprint module sources should
use release tags once the implementation is ready for reuse.

Keep the README focused on operator workflow and this file focused on design
review. That split keeps the first page easy to scan while preserving the
engineering details needed for architecture review.

## Operational Boundaries

- Treat \`terraform.tfvars.example\` as a safe shape, not a real customer file.
- Keep local \`terraform.tfvars\`, state, plans, and downloaded providers out of
  Git.
- Review IAM and network reachability before enabling any public path.
- Run \`make validate\` for broad changes and \`make changed\` while iterating.
- Update \`BLUEPRINTS.md\` with \`make blueprints\` after moving this folder.

## Review Checklist

- [ ] The deployment purpose is specific enough for an operator to choose it.
- [ ] The ASCII architecture shows every important OCI component.
- [ ] Resource names use \`local.name_prefix\` and documented type tokens.
- [ ] Inputs are safe to publish in \`terraform.tfvars.example\`.
- [ ] Outputs match the values downstream users need.
- [ ] Ansible plan, apply, and destroy runners point at this directory.
- [ ] README and architecture links work from GitHub.
- [ ] Validation passes before commit.
EOF

read -r -d '' hello_world_html <<EOF || true
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>$title - Hello World Application</title>
  <style>
    :root {
      --bg: #0b1220;
      --panel: #0f172a;
      --line: #334155;
      --text: #e5e7eb;
      --muted: #94a3b8;
      --accent: #22d3ee;
      --ok: #34d399;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
      background: radial-gradient(circle at top right, #1e293b 0%, var(--bg) 52%);
      color: var(--text);
    }
    main {
      max-width: 940px;
      margin: 44px auto;
      padding: 20px;
    }
    section {
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 22px;
      box-shadow: 0 12px 28px rgba(0, 0, 0, 0.28);
    }
    h1 {
      margin: 0 0 10px;
      font-size: clamp(1.35rem, 2.4vw, 2rem);
      letter-spacing: 0.02em;
    }
    p {
      margin: 0 0 12px;
      color: var(--muted);
      line-height: 1.52;
    }
    code {
      color: #bae6fd;
      background: #0b1220;
      border: 1px solid #1f2937;
      border-radius: 6px;
      padding: 1px 6px;
    }
    .badge {
      display: inline-block;
      margin: 8px 8px 0 0;
      padding: 6px 10px;
      border-radius: 999px;
      border: 1px solid #475569;
      font-size: 0.85rem;
      color: var(--text);
      background: #0b1220;
    }
    .ok {
      border-color: #065f46;
      color: #d1fae5;
      background: rgba(6, 95, 70, 0.30);
    }
    .grid {
      margin-top: 14px;
      display: grid;
      gap: 10px;
      grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
    }
    .cell {
      border: 1px solid var(--line);
      border-radius: 10px;
      background: #0b1220;
      padding: 10px;
      font-size: 0.92rem;
    }
    .label {
      font-size: 0.8rem;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--accent);
      margin-bottom: 4px;
    }
  </style>
</head>
<body>
  <main>
    <section>
      <h1>Hello World Application: $title</h1>
      <p>
        This page is a lightweight demo artifact for the deployment blueprint
        <code>$relative_dir</code>.
      </p>
      <p>
        Use it in walkthroughs, handoff notes, smoke checks, and runbook rehearsal
        sessions where an example application endpoint helps validate the intended flow.
      </p>
      <span class="badge ok">Application Demo</span>
      <span class="badge">Blueprint Ready</span>
      <span class="badge">Runbook Friendly</span>
      <div class="grid">
        <div class="cell">
          <div class="label">Blueprint</div>
          <div>$title</div>
        </div>
        <div class="cell">
          <div class="label">Path</div>
          <div>$relative_dir</div>
        </div>
        <div class="cell">
          <div class="label">Endpoint (Example)</div>
          <div>app.example.com</div>
        </div>
        <div class="cell">
          <div class="label">Purpose</div>
          <div>Application hello-world and operational validation</div>
        </div>
      </div>
    </section>
  </main>
</body>
</html>
EOF

for action in plan apply destroy; do
  backend_enabled=false
  verb="Plan"
  if [[ "$action" == "apply" ]]; then
    backend_enabled=true
    verb="Apply"
  elif [[ "$action" == "destroy" ]]; then
    backend_enabled=true
    verb="Destroy"
  fi

  read -r -d '' playbook <<EOF || true
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
---
- name: $verb the $title blueprint
  hosts: localhost
  gather_facts: false
  vars:
    terraform_working_dir: "{{ playbook_dir }}/.."
    terraform_action: $action
    terraform_backend_enabled: $backend_enabled
  tasks:
    - name: Run shared Terraform runner
      ansible.builtin.import_role:
        name: ${role_prefix}ansible/roles/terraform_runner
EOF
  write_file "$target_dir/ansible/$action.yml" "$playbook"
done

write_file "$target_dir/versions.tf" "$versions_tf"
write_file "$target_dir/providers.tf" "$providers_tf"
write_file "$target_dir/variables.tf" "$variables_tf"
write_file "$target_dir/locals.tf" "$locals_tf"
write_file "$target_dir/main.tf" "$main_tf"
write_file "$target_dir/outputs.tf" "$outputs_tf"
write_file "$target_dir/terraform.tfvars.example" "$tfvars_example"
write_file "$target_dir/README.md" "$readme_md"
write_file "$target_dir/architecture/README.md" "$architecture_md"
write_file "$target_dir/hello-world/index.html" "$hello_world_html"

"$REPO_ROOT/scripts/generate-blueprints-index.sh"

echo "Created $relative_dir."
echo "Next: edit the Terraform implementation, then run make changed."
