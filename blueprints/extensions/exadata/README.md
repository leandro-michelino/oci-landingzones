# Exadata Extension

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/extensions/exadata`. It tells you what
the blueprint builds, which inputs deserve a real review, how to run Terraform or the local
Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/extensions/exadata` |
| Best fit | Adds OCI Cloud Exadata Infrastructure as an optional service extension after the landing-zone network and compartments are ready. |
| Terraform shape | `oci_database_cloud_exadata_infrastructure.this` |
| Inputs to settle first | `compartment_ocid`, `exadata_label`, `availability_domain`, `shape`, `compute_count`, `storage_count`, `database_server_type`, plus 2 more |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `cloud_exadata_infrastructure_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Adds OCI Cloud Exadata Infrastructure as an optional service extension after the
landing-zone network and compartments are ready.

## When To Use This Deployment

- Database workloads require Exadata infrastructure.
- Platform and database teams need a repeatable starting shape.
- Capacity, maintenance, and network placement need review.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_database_cloud_exadata_infrastructure.this` | Declared directly in `main.tf` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/extensions/exadata/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed ASCII architecture for this deployment
|-- main.tf                    Terraform modules, resources, and data sources
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

Start with `terraform.tfvars.example`, then create a local ignored `terraform.tfvars` with
real OCIDs, CIDRs, names, recipients, and enable flags.

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
| `compartment_ocid` | Compartment OCID where Exadata resources are created. Defaults to tenancy_ocid for validation-only tests. |
| `exadata_label` | Short Exadata label used in names. |
| `availability_domain` | Availability domain for Exadata infrastructure. |
| `shape` | Exadata infrastructure shape. |
| `compute_count` | Optional Exadata compute server count. |
| `storage_count` | Optional Exadata storage server count. |
| `database_server_type` | Optional Exadata database server type. |
| `storage_server_type` | Optional Exadata storage server type. |
| `customer_contacts` | Customer contacts for Exadata operational notifications. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_exadata_infrastructure` | Create Exadata Cloud Infrastructure. Disabled by default because this is high-cost and quota-sensitive. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `cloud_exadata_infrastructure_id` | Exadata Cloud Infrastructure OCID. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/extensions/exadata
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/extensions/exadata
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Deploy core and the required network foundation first.
2. Confirm service-specific quotas, cost, and dependencies.
3. Populate `terraform.tfvars` with subnet, compartment, and service values.
4. Run plan and review optional resource enable flags.
5. Apply only after the platform or service owner approves the output shape.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Confirm quota, shape, maintenance, and cost approvals.
- Validate subnet and backup/network dependencies.
- Treat apply as a customer-approved service deployment.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required
architecture README sections, `terraform init -backend=false`, `terraform validate`, root
Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and
cleanup of generated Terraform artifacts.
