# Externally Managed VCNs

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/networking/externally-managed-vcns`. It
tells you what the blueprint builds, which inputs deserve a real review, how to run
Terraform or the local Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/externally-managed-vcns` |
| Best fit | Normalizes existing VCN, subnet, DRG, and route-target IDs so downstream blueprints can consume brownfield networking cleanly. |
| Terraform shape | Terraform resources declared in main.tf |
| Inputs to settle first | `vcn_ids`, `subnet_ids`, `drg_id`, `route_target_ids` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_ids`, `subnet_ids`, `drg_id`, `route_target_ids` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Normalizes existing VCN, subnet, DRG, and route-target IDs so downstream blueprints can
consume brownfield networking cleanly.

## When To Use This Deployment

- Networking already exists outside this repo.
- You need a consistent output contract without creating VCNs.
- Brownfield resources must be handed off to extensions or workload blueprints.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Composition | `main.tf` | Review the local Terraform graph |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/networking/externally-managed-vcns/
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
| `vcn_ids` | Externally managed VCN OCIDs keyed by logical name. |
| `subnet_ids` | Externally managed subnet OCIDs keyed by logical name. |
| `drg_id` | Externally managed DRG OCID, when this blueprint is documenting or consuming an existing hub. |
| `route_target_ids` | Externally managed route target OCIDs keyed by logical name, for example firewall private IPs or DRG attachments. |

### Enable Flags And Switches

No dedicated inputs in this group.

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of externally managed resource identifiers passed into this blueprint. |
| `vcn_ids` | Externally managed VCN OCIDs keyed by logical name. |
| `subnet_ids` | Externally managed subnet OCIDs keyed by logical name. |
| `drg_id` | Externally managed DRG OCID. |
| `route_target_ids` | Externally managed route target OCIDs keyed by logical name. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/networking/externally-managed-vcns
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/networking/externally-managed-vcns
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Deploy or identify the target compartment.
2. Review CIDRs, subnets, gateways, route tables, DNS, and inspection choices.
3. Populate `terraform.tfvars` with customer-specific network values.
4. Run plan and review traffic path changes.
5. Apply, then hand VCN, subnet, DRG, DNS, or inspection outputs to workloads and extensions.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Confirm every imported OCID belongs to the right compartment and region.
- Do not assume this blueprint owns lifecycle of external resources.
- Keep output names stable for downstream consumers.
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
