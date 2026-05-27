# Autonomous Database MongoDB API

Start here for `blueprints/data-platform/mongodb-api`: what it builds, which inputs deserve a careful look, how to run Terraform or the local Ansible wrappers, and where the detailed architecture notes live.

## At A Glance

| Item | Details |
|---|---|
| Folder | `blueprints/data-platform/mongodb-api` |
| Best fit | Managed MongoDB-compatible document API on OCI using Autonomous Database. |
| Terraform shape | Optional private VCN/subnet/NSG, `oci_database_autonomous_database.this`, `oci_database_autonomous_database_backup.manual`, `oci_identity_policy.access` |
| Inputs to settle first | Base tenancy values, private network mode or existing subnet/NSGs, admin password source, workload sizing, MongoDB API tool settings, backup policy, and IAM statements. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `private_network`, `autonomous_database_id`, `autonomous_database_state`, `mongodb_api_url`, `private_endpoint`, `private_endpoint_ip`, `service_console_url`, `manual_backup_id`, `access_policy_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys an OCI-managed MongoDB-compatible document database endpoint by creating an Autonomous Database with the MongoDB API database tool enabled. The pattern is private-first, supports NSGs, KMS, backup retention, optional manual backup, and optional scoped IAM policy statements.

This is the managed-service path for teams that want MongoDB-style application access without running MongoDB replica set nodes, patching operating systems, or managing database host backups.

## When To Use This Deployment

- App teams need MongoDB driver or tool compatibility on an OCI-managed database service.
- You want a private endpoint document API without operating MongoDB compute nodes.
- Platform teams need database sizing, network placement, backup, KMS, and IAM decisions captured before apply.
- Outputs from this pattern must be handed off to application, platform, DBA, or security teams.

## Use Cases

| Use Case | Why This Blueprint Fits |
|---|---|
| MongoDB-compatible app modernization | Gives app teams a MongoDB-style API on an OCI managed database service without self-managing replica sets. |
| JSON document workloads | Uses Autonomous Database JSON/document capabilities with MongoDB API tooling enabled for document-style access patterns. |
| Private document API | Creates or consumes private endpoint networking so document traffic stays inside approved OCI network paths. |
| Migration assessment | Lets teams validate driver behavior, command compatibility, indexing, and endpoint handling before production cutover. |
| Managed platform alternative | Reduces operational ownership for patching, database host backups, and OS-level database maintenance. |

## Deployment Modes

| Mode | Use It When | Main Inputs |
|---|---|---|
| Private endpoint with new network | Fastest complete deployment for demos, tests, or isolated app landing zones. | `create_private_network = true`, `vcn_cidr_block`, `subnet_cidr_block`, `allowed_client_cidrs` |
| Private endpoint with existing network | Production or shared environments need VCN-only access. | `subnet_id`, `nsg_ids`, `private_endpoint_label`, `create_private_network = false` |
| Public endpoint with ACL | Legacy or non-AI Autonomous Database shapes where public ACL is supported. | `enable_public_access_control = true`, `whitelisted_ips` set to approved `/32` or CIDR ranges |
| Validation only | You want CI or local validation without creating a database. | `enable_mongodb_api_database = false` |

## Quick Start

For a private deployment, start with the example file and fill in approved compartment, subnet, NSG, and password values:

```bash
cd blueprints/data-platform/mongodb-api
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

For a smoke deployment through the local Ansible wrapper, keep the password outside committed files:

```bash
cd blueprints/data-platform/mongodb-api
export TF_VAR_admin_password='<secure-password-from-your-vault-or-shell>'
ansible-playbook -i localhost, -c local ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, -c local ansible/apply.yml
```

When the run completes, hand off `mongodb_api_url`, the approved username/password source, and the endpoint access model to the application owner.

## What This Deploys

Everything needed for this deployment starts in this folder: Terraform composes the OCI resource graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_database_autonomous_database.this` | Autonomous Database configured for JSON/document workloads with MongoDB API enabled through `db_tools_details` |
| Resource | `oci_database_autonomous_database_backup.manual` | Optional initial manual backup |
| Resource | `oci_identity_policy.access` | Optional scoped IAM policy for app, DBA, or operator access |

Use `variables.tf` as the input contract, then keep real OCIDs, CIDRs, names, and enable flags in an ignored local `terraform.tfvars`.

## Folder Contract

```text
blueprints/data-platform/mongodb-api/
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

Start with `terraform.tfvars.example`, then create a local ignored `terraform.tfvars` with real OCIDs, credentials, sizing values, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
|---|---|
| `tenancy_ocid` | Required base value for provider configuration and default policy scope. |
| `current_user_ocid` | Required base value for local execution or bootstrap workflows. |
| `region` | OCI region where the database is created. |
| `home_region` | Tenancy home region for optional IAM policy creation. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `compartment_ocid` | Compartment OCID where the database is created. |
| `policy_compartment_ocid` | Optional compartment OCID where IAM policy is created. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
|---|---|
| `enable_mongodb_api_database` | Keep `false` for validation-only runs; set `true` only for an approved deployment. |
| `create_private_network` | Create a private VCN, subnet, and NSG for a complete private endpoint deployment. |
| `vcn_cidr_block`, `subnet_cidr_block`, `allowed_client_cidrs` | CIDR model for the optional private network and allowed client ranges. |
| `db_name`, `database_display_name` | Database name and human-readable display name. |
| `admin_password` | Secure password source for the Autonomous Database admin account. |
| `db_workload` | Use `AJD` for the JSON/document workload by default; use `OLTP` only after DBA review. |
| `compute_model`, `compute_count`, `data_storage_size_in_tbs` | Capacity model and baseline sizing. |
| `is_auto_scaling_enabled`, `is_auto_scaling_for_storage_enabled` | Compute and storage auto-scaling behavior. |
| `is_mtls_connection_required` | Client TLS posture for application connections. |
| `subnet_id`, `nsg_ids`, `private_endpoint_label` | Private endpoint placement and source controls. |
| `enable_public_access_control`, `whitelisted_ips` | Public endpoint allow-list controls. Leave disabled for private Autonomous AI Database deployments. |
| `kms_key_id` | Optional customer-managed encryption key. |
| `mongodb_api_tool_name`, `enable_mongodb_api` | MongoDB API tool contract. The default tool name is `MONGODB_API`. |
| `mongodb_api_compute_count`, `mongodb_api_max_idle_time_in_minutes` | Optional MongoDB API tool resource controls. |
| `backup_retention_period_in_days`, `create_manual_backup` | Automatic retention and optional first manual backup. |
| `policy_statements` | Optional IAM statements for DBAs, operators, or app groups. |

### Enable Flags And Switches

All cost-bearing resources are disabled by default where possible. Turn on only the resources approved for the target environment.

## Compatibility Notes

- This blueprint enables Oracle Database API for MongoDB on Autonomous Database. It is not a self-managed MongoDB Community or Enterprise server deployment.
- Validate the application command surface, driver version, authentication behavior, and index usage before production migration.
- Use `AJD` as the default JSON/document workload unless the DBA team chooses another supported Autonomous Database workload.
- Prefer private endpoint access for production. Use `whitelisted_ips` only when an explicitly approved public ACL is acceptable.

## Outputs And Hand-Off

| Output | Hand-Off Meaning |
|---|---|
| `blueprint_name` | Blueprint identifier for automation. |
| `name_prefix` | Standard OCI naming prefix. |
| `resource_ids` | Map of created resource identifiers. |
| `private_network` | Optional VCN, subnet, and NSG OCIDs created by this blueprint. |
| `autonomous_database_id` | Autonomous Database OCID. |
| `autonomous_database_state` | Autonomous Database lifecycle state. |
| `mongodb_api_url` | MongoDB API URL returned by Autonomous Database. |
| `private_endpoint` | Private endpoint FQDN when configured. |
| `private_endpoint_ip` | Private endpoint IP when configured. |
| `service_console_url` | Service console URL for operators. |
| `manual_backup_id` | Optional manual backup OCID. |
| `access_policy_id` | Optional IAM policy OCID. |

## Terraform And Ansible Workflow

```bash
cd blueprints/data-platform/mongodb-api
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

```bash
cd blueprints/data-platform/mongodb-api
ansible-playbook -i localhost, -c local ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, -c local ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, -c local ansible/destroy.yml
```

## Deployment Order

1. Deploy core and the required private network foundation first.
2. Confirm database workload, private endpoint subnet, NSGs, KMS key, backup retention, and IAM policy statements.
3. Populate `terraform.tfvars` with real values from approved sources.
4. Run plan and review endpoint placement, MongoDB API tool settings, admin password handling, backups, and IAM policy scope.
5. Apply only after the platform, DBA, or application owner approves the output shape.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

## Review Before Apply

- Confirm the application accepts Oracle Database API for MongoDB compatibility for its required MongoDB commands and driver behavior.
- Confirm admin password handling uses a secure variable source and is not committed.
- Confirm private endpoint subnet, NSGs, DNS behavior, and whether the blueprint should create or consume the network.
- Confirm `db_workload`, sizing, auto-scaling, KMS key, license model, and backup retention.
- Confirm `mongodb_api_url` is handed only to approved app and operator channels.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
