# OCI NoSQL Database

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/data-platform/nosql`.
It tells you what the blueprint builds, which inputs deserve a real review, how
to run Terraform or local Ansible wrappers, and where to find the detailed
Architecture design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/data-platform/nosql` |
| Best fit | Managed OCI NoSQL table with deploy-and-use app networking, optional secondary index and cross-region replica, and IAM/alert contracts. |
| Terraform shape | `oci_core_vcn.app`, `oci_core_route_table.app`, `oci_core_security_list.app`, `oci_core_subnet.app`, `oci_nosql_table.this`, `oci_nosql_index.secondary`, `oci_nosql_table_replica.this`, `oci_ons_notification_topic.alert`, `terraform_data.app_network_contract`, `terraform_data.nosql_contract` |
| Inputs to settle first | `compartment_ocid`, `table_ddl_statement`, `table_max_read_units`, `table_max_write_units`, `table_max_storage_in_gbs`, `create_secondary_index`, `enable_table_replica`, `replica_region` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `nosql_table_id`, `nosql_table_name`, `nosql_capacity_contract`, `app_network_contract` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Implements an OCI NoSQL landing zone with a production-oriented table contract,
optional index and replica wiring, and optional app-network foundation for
consumer workloads.

## When To Use This Deployment

- You need low-latency key-value or document storage in OCI.
- Workload teams need explicit capacity and schema contract hand-off.
- You want optional secondary-index and replica controls in the same blueprint.
- You want deploy-and-use networking defaults for app-side consumer tiers.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the
NoSQL resource graph and contracts, while local Ansible files provide the same
plan/apply/destroy rhythm used across the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.app`, `oci_core_route_table.app`, `oci_core_security_list.app`, `oci_core_subnet.app` | Optional app-network resources for NoSQL consumers. |
| Resource | `oci_nosql_table.this` | Core NoSQL table resource. |
| Resource | `oci_nosql_index.secondary` | Optional secondary index for query acceleration. |
| Resource | `oci_nosql_table_replica.this` | Optional cross-region table replica. |
| Resource | `oci_ons_notification_topic.alert` | Optional alert and operations topic. |
| Resource | `oci_identity_policy.access` | Optional IAM policy for NoSQL operators and consumers. |
| Resource | `terraform_data.app_network_contract` | App network contract outputs. |
| Resource | `terraform_data.nosql_contract` | NoSQL table capacity and routing contract outputs. |

The exact behavior is controlled by `variables.tf` and values supplied in your
local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/data-platform/nosql/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
|-- main.tf                    Terraform resources and contracts
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    `-- destroy.yml            Guarded destroy
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real IDs, schema decisions, and capacity thresholds.

### Base Tenancy And Naming

| Input | What To Decide |
| --- | --- |
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region name. |
| `home_region` | OCI tenancy home region. |
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `compartment_ocid` | Compartment OCID where resources are created. |
| `enable_app_network` | Create VCN/subnet/route/security resources for consumer workloads. |
| `table_ddl_statement` | NoSQL table DDL schema contract. |
| `table_max_read_units` | Provisioned read limit. |
| `table_max_write_units` | Provisioned write limit. |
| `table_max_storage_in_gbs` | Max table storage. |
| `table_capacity_mode` | Capacity mode for table limits. |
| `create_secondary_index` | Enable secondary index creation. |
| `secondary_index_columns` | Index columns for secondary index. |
| `enable_table_replica` | Enable cross-region replication. |
| `replica_region` | Target region when replication is enabled. |
| `create_alert_topic` | Create NoSQL operations topic. |
| `policy_statements` | Optional IAM policy statements for NoSQL access. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks,
customer notes, or manual hand-off. If an output name changes, update dependent
docs and consumers in the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource IDs created by this blueprint. |
| `nosql_table_id` | OCI NoSQL table OCID. |
| `nosql_table_name` | OCI NoSQL table name. |
| `nosql_table_state` | Current lifecycle state of the NoSQL table. |
| `nosql_secondary_index_name` | Secondary index name when enabled. |
| `nosql_replica_region` | Replica target region when enabled. |
| `nosql_capacity_contract` | Table capacity contract output. |
| `app_network_contract` | App network IDs for consumer workloads. |
| `alert_topic_name` | NoSQL alert topic name. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/data-platform/nosql
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across
the repo:

```bash
cd blueprints/data-platform/nosql
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow,
traffic boundaries, detailed notes, and review checklist expected for this
blueprint.

## Review Before Apply

- Confirm table DDL and primary/shard key design with the application owner.
- Confirm capacity and storage thresholds are realistic.
- Confirm replication region, if enabled, is intentional.
- Confirm index columns match expected query patterns.
- Confirm app-network ingress CIDRs and route behavior if app-network resources are enabled.
- Confirm `architecture/README.md` matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files,
required architecture README sections, `terraform init -backend=false`,
`terraform validate`, root Ansible syntax, blueprint-local Ansible syntax,
optional scanners when installed, and cleanup of generated Terraform artifacts.
