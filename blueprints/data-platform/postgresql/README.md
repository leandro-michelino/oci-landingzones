# PostgreSQL Landing Zone

Use this page as the operator guide for `blueprints/data-platform/postgresql`. It tells you what the blueprint builds, which inputs deserve a real review, how to run Terraform or the local Ansible wrappers, and where to find the detailed Architecture design.

## At A Glance

| Item | Details |
|---|---|
| Folder | `blueprints/data-platform/postgresql` |
| Best fit | Private PostgreSQL database tier for app teams that need managed open-source database foundations. |
| Terraform shape | Optional private VCN/subnet/NSG, `oci_psql_db_system.this`, `oci_identity_policy.access` |
| Inputs to settle first | Base tenancy values, private network mode or existing subnet/NSGs, shape, DB version, admin secret model, storage durability, and backup policy. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `private_network`, `postgresql_db_system_id`, `postgresql_db_system_state`, `postgresql_primary_endpoint`, `postgresql_instance_endpoints`, `postgresql_reader_endpoint`, `postgresql_instances`, `access_policy_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys an OCI PostgreSQL DB system with private networking, storage durability settings, optional backup/maintenance policy, optional restore source, and optional scoped IAM policy.

The blueprint can either consume an existing private subnet and NSG or create a small private VCN, subnet, and NSG so the database is ready for app-team hand-off without requiring a separate networking blueprint first.

## When To Use This Deployment

- You need a managed PostgreSQL database in a private subnet.
- App teams need an open-source database option beside Autonomous Database and MySQL HeatWave.
- You want backup, storage, NSG, and credential decisions documented before apply.
- Outputs from this pattern must be handed off to application, platform, or security teams.

## Deployment Modes

| Mode | Use It When | Main Inputs |
|---|---|---|
| Private endpoint with new network | Fastest complete deployment for demos, tests, or isolated app landing zones. | `create_private_network = true`, `vcn_cidr_block`, `subnet_cidr_block`, `allowed_client_cidrs` |
| Private endpoint with existing network | Production or shared environments already have approved network foundations. | `subnet_id`, `nsg_ids`, `create_private_network = false` |
| Validation only | You want CI or local validation without creating a database. | `enable_db_system = false` |

## Quick Start

For a complete private deployment, start with the example file and fill in approved compartment, sizing, and credential values:

```bash
cd blueprints/data-platform/postgresql
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

For a smoke deployment through the local Ansible wrapper, keep the password outside committed files:

```bash
cd blueprints/data-platform/postgresql
export TF_VAR_admin_password='<secure-password-from-your-vault-or-shell>'
ansible-playbook -i localhost, -c local ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, -c local ansible/apply.yml
```

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_psql_db_system.this` | Declared directly in `main.tf` |
| Resource | `oci_identity_policy.access` | Optional scoped IAM policy declared directly in `main.tf` |

The exact OCI behavior is controlled by `variables.tf` and values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/data-platform/postgresql/
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

Start with `terraform.tfvars.example`, then create a local ignored `terraform.tfvars` with real OCIDs, names, credentials, sizing values, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
|---|---|
| `tenancy_ocid` | Required base value for provider configuration and policy scope. |
| `current_user_ocid` | Required base value for local execution or bootstrap workflows. |
| `region` | OCI region where PostgreSQL is created. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in names. |
| `compartment_ocid` | Compartment OCID where PostgreSQL is created. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
|---|---|
| `enable_db_system` | Keep `false` for validation-only runs; set `true` only for an approved deployment. |
| `create_private_network` | Create a private VCN, subnet, and NSG for a complete PostgreSQL deployment. |
| `vcn_cidr_block`, `subnet_cidr_block`, `allowed_client_cidrs` | CIDR model for the optional private network and approved client ranges. |
| `db_version`, `shape` | PostgreSQL version and compute shape. |
| `instance_count`, `instance_ocpu_count`, `instance_memory_size_in_gbs` | HA and sizing model. |
| `admin_username`, `admin_password`, `admin_password_secret_id` | Credential source and rotation ownership. |
| `subnet_id`, `nsg_ids` | Private endpoint subnet and source controls. |
| `is_reader_endpoint_enabled` | Reader endpoint behavior when supported by the chosen shape and topology. |
| `storage_system_type`, `is_regionally_durable`, `availability_domain`, `iops` | Storage durability, placement, and performance. |
| `backup_policy`, `maintenance_window_start` | Backup start time, retention, and maintenance window. |
| `db_source` | Optional restore or clone source. |
| `policy_statements` | Optional IAM statements for DBAs, operators, or app groups. |

### Enable Flags And Switches

All cost-bearing resources are disabled by default where possible. Turn on only the resources approved for the target environment.

## Outputs And Hand-Off

| Output | Hand-Off Meaning |
|---|---|
| `blueprint_name` | Blueprint identifier for automation. |
| `name_prefix` | Standard OCI naming prefix. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `private_network` | Optional VCN, subnet, and NSG OCIDs created by this blueprint. |
| `postgresql_db_system_id` | PostgreSQL DB system OCID. |
| `postgresql_db_system_state` | DB system lifecycle state. |
| `postgresql_primary_endpoint` | Primary private endpoint FQDN, IP, and port. |
| `postgresql_instance_endpoints` | Per-instance private endpoint details. |
| `postgresql_reader_endpoint` | Reader endpoint details when enabled. |
| `postgresql_instances` | Instance details returned by OCI. |
| `postgresql_admin_username` | Admin username returned by OCI. |
| `access_policy_id` | Optional IAM policy OCID. |

## Terraform And Ansible Workflow

```bash
cd blueprints/data-platform/postgresql
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

```bash
cd blueprints/data-platform/postgresql
ansible-playbook -i localhost, -c local ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, -c local ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, -c local ansible/destroy.yml
```

## Deployment Order

1. Deploy core and the required network foundation first.
2. Confirm database version, shape, subnet, NSGs, storage durability, and backup policy.
3. Populate `terraform.tfvars` with real values from approved sources.
4. Run plan and review endpoint placement, credential source, backup retention, and IAM policy statements.
5. Apply only after the platform, DBA, or application owner approves the output shape.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

## Review Before Apply

- Confirm PostgreSQL version, shape, memory, OCPU count, and instance count.
- Confirm private subnet, NSGs, optional created network CIDRs, and reader endpoint behavior.
- Confirm admin password source is secure and not committed.
- Confirm backup policy includes an approved `backup_start`, maintenance window, storage durability, availability domain for one-AD regions, and restore source if used.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
