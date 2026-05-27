# Autonomous Database

Use this page as the operator guide for `blueprints/data-platform/autonomous-database`. It tells you what the blueprint builds, which inputs deserve a real review, how to run Terraform or the local Ansible wrappers, and where to find the detailed Architecture design.

## At A Glance

| Item | Details |
|---|---|
| Folder | `blueprints/data-platform/autonomous-database` |
| Best fit | Private ATP or ADW database for application and data-platform landing zones. |
| Terraform shape | Optional private VCN/subnet/NSG, `oci_database_autonomous_database.this`, optional manual backup |
| Inputs to settle first | Private network mode, workload, admin password, compute/storage sizing, license model, backup policy, KMS, and IAM statements. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `private_network`, `autonomous_database_id`, `autonomous_database_state`, `autonomous_database_connection_strings`, `private_endpoint`, `private_endpoint_ip`, `manual_backup_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys a private Autonomous Database pattern for ATP or ADW with optional
private VCN/subnet/NSG creation, manual backup, KMS, NSG controls, private
endpoint inputs, and explicit license model selection.

## When To Use This Deployment

- Private ATP or ADW database for application and data-platform landing zones.
- You need a reusable, reviewable OCI deployment folder with local Terraform and Ansible runners.
- Outputs from this pattern must be handed off to application, platform, or security teams.

## Use Cases

| Use Case | Why This Blueprint Fits |
|---|---|
| Private application database | Creates an Autonomous Database with optional private network resources and endpoint outputs for app-team hand-off. |
| Data warehouse landing zone | Supports ADW-style workloads, private endpoint placement, storage sizing, backup retention, and license review in one folder. |
| Rapid proof of value | Can create a compact private VCN/subnet/NSG plus database for isolated demos or short-lived validation. |
| Secure database foundation | Captures KMS, NSG, admin password, backup, and IAM decisions before apply. |
| Downstream data-platform dependency | Produces ADB IDs, connection strings, private endpoint values, and backup IDs for APEX, analytics, and integration blueprints. |

## Deployment Modes

| Mode | Use It When | Main Inputs |
|---|---|---|
| Private endpoint with new network | Fastest complete deployment for demos, tests, or isolated app landing zones. | `create_private_network = true`, `vcn_cidr_block`, `subnet_cidr_block`, `allowed_client_cidrs` |
| Private endpoint with existing network | Production or shared environments already have approved network foundations. | `subnet_id`, `nsg_ids`, `create_private_network = false` |
| Public or service-default endpoint | A non-private endpoint is explicitly approved for the workload. | Leave `subnet_id` empty and review access controls carefully. |
| Validation only | You want CI or local validation without creating a database. | `enable_autonomous_database = false` |

## Quick Start

For a complete private deployment, start with the example file and fill in
approved compartment, sizing, and credential values:

```bash
cd blueprints/data-platform/autonomous-database
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

For a smoke deployment through the local Ansible wrapper, keep the password
outside committed files:

```bash
cd blueprints/data-platform/autonomous-database
export TF_VAR_admin_password='<secure-password-from-your-vault-or-shell>'
ansible-playbook -i localhost, -c local ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, -c local ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, -c local ansible/destroy.yml
```

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_core_vcn.autonomous`, `oci_core_subnet.autonomous`, `oci_core_network_security_group.autonomous` | Optional private network created when `create_private_network` is enabled. |
| Resource | `oci_database_autonomous_database.this` | Declared directly in `main.tf` |
| Resource | `oci_database_autonomous_database_backup.manual` | Declared directly in `main.tf` |

The exact OCI behavior is controlled by `variables.tf` and values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/data-platform/autonomous-database/
|-- README.md
|-- architecture/README.md
|-- main.tf
|-- variables.tf
|-- outputs.tf
|-- providers.tf
|-- versions.tf
|-- terraform.tfvars.example
`-- ansible/
    |-- plan.yml
    |-- apply.yml
    `-- destroy.yml
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored `terraform.tfvars` with real OCIDs, names, recipients, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
|---|---|
| `tenancy_ocid` | Required base value for naming, provider configuration, or compartment targeting. |
| `current_user_ocid` | Required base value for naming, provider configuration, or compartment targeting. |
| `region` | Required base value for naming, provider configuration, or compartment targeting. |
| `org` | Required base value for naming, provider configuration, or compartment targeting. |
| `environment` | Required base value for naming, provider configuration, or compartment targeting. |
| `region_key` | Required base value for naming, provider configuration, or compartment targeting. |
| `compartment_ocid` | Compartment where Autonomous Database and optional network resources are created. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
|---|---|
| `enable_autonomous_database` | Keep `false` for validation-only runs; set `true` only for an approved deployment. |
| `create_private_network` | Create a private VCN, subnet, and NSG for a complete deployment. |
| `vcn_cidr_block`, `subnet_cidr_block`, `allowed_client_cidrs` | CIDR model for the optional private network and approved client ranges. |
| `db_name`, `database_display_name`, `db_workload` | Database identity and ATP/ADW workload behavior. |
| `admin_password` | Secure password source for the Autonomous Database admin account. |
| `compute_model`, `compute_count`, `data_storage_size_in_tbs` | Capacity model and baseline sizing. |
| `subnet_id`, `nsg_ids`, `private_endpoint_label` | Private endpoint placement and source controls. |
| `kms_key_id` | Optional customer-managed encryption key. |
| `license_model` | Use `LICENSE_INCLUDED` or `BRING_YOUR_OWN_LICENSE` after DBA and commercial review. |
| `backup_retention_period_in_days`, `create_manual_backup` | Automatic retention and optional first manual backup. |
| `policy_statements` | Optional IAM statements for DBAs, operators, or app groups. |

### Enable Flags And Switches

All cost-bearing resources are disabled by default where possible. Turn on only the resources approved for the target environment.

## Outputs And Hand-Off

| Output | Hand-Off Meaning |
|---|---|
| `blueprint_name` | Hand-off value for Autonomous Database. |
| `name_prefix` | Hand-off value for Autonomous Database. |
| `resource_ids` | Hand-off value for Autonomous Database. |
| `private_network` | Optional VCN, subnet, and NSG OCIDs created by this blueprint. |
| `autonomous_database_id` | Hand-off value for Autonomous Database. |
| `autonomous_database_state` | Current ADB lifecycle state. |
| `autonomous_database_connection_strings` | Hand-off value for Autonomous Database. |
| `private_endpoint` | Private endpoint FQDN when configured. |
| `private_endpoint_ip` | Private endpoint IP when configured. |
| `manual_backup_id` | Hand-off value for Autonomous Database. |

## Terraform And Ansible Workflow

```bash
cd blueprints/data-platform/autonomous-database
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

```bash
cd blueprints/data-platform/autonomous-database
ansible-playbook -i localhost, -c local ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, -c local ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, -c local ansible/destroy.yml
```

## Deployment Order

1. Confirm whether this blueprint creates the private network or consumes an
   approved subnet and NSGs.
2. Confirm database workload, compute/storage sizing, license model, and KMS.
3. Populate `terraform.tfvars` with real values from approved sources.
4. Run plan and review endpoint placement, credential source, backup retention,
   and IAM policy statements.
5. Apply only after the platform, DBA, or application owner approves the output
   shape.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

## Review Before Apply

- Confirm admin password handling uses a secure variable source.
- Confirm `license_model` matches approved Oracle Database licensing rights.
- Confirm private endpoint subnet, NSGs, KMS key, workload type, and storage sizing.
- Confirm backup retention and auto-scaling expectations before apply.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-changed.sh
```

Use `./scripts/validate-all.sh` before release work or broad shared changes.
