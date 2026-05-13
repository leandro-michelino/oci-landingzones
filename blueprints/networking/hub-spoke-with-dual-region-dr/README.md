# Hub-Spoke With Dual Region DR

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for
`blueprints/networking/hub-spoke-with-dual-region-dr`. It tells you what the blueprint
builds, which inputs deserve a real review, how to run Terraform or the local Ansible
wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/hub-spoke-with-dual-region-dr` |
| Best fit | Creates paired primary and secondary hub-spoke networking for disaster-recovery-ready regional separation. |
| Terraform shape | `primary_network`, `secondary_network` |
| Inputs to settle first | `secondary_region`, `secondary_region_key`, `compartment_ocid`, `secondary_compartment_ocid` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `primary_hub_vcn_id`, `secondary_hub_vcn_id`, `primary_drg_id`, `secondary_drg_id`, plus 2 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Creates paired primary and secondary hub-spoke networking for disaster-recovery-ready
regional separation.

## When To Use This Deployment

- Network foundations are needed in two regions.
- Primary and secondary traffic paths need matching structure.
- DR planning requires region-specific outputs.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `primary_network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.1.0` |
| Module | `secondary_network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.1.0` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/networking/hub-spoke-with-dual-region-dr/
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
| `secondary_region` | Secondary OCI region for DR. |
| `secondary_region_key` | Short OCI region key for the secondary DR region. |
| `compartment_ocid` | Primary region networking compartment OCID. Defaults to tenancy_ocid for simple tests. |
| `secondary_compartment_ocid` | Secondary region networking compartment OCID. Defaults to compartment_ocid. |

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
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `primary_hub_vcn_id` | Primary hub VCN OCID. |
| `secondary_hub_vcn_id` | Secondary hub VCN OCID. |
| `primary_drg_id` | Primary DRG OCID. |
| `secondary_drg_id` | Secondary DRG OCID. |
| `primary_spoke_vcn_ids` | Primary spoke VCN OCIDs. |
| `secondary_spoke_vcn_ids` | Secondary spoke VCN OCIDs. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/networking/hub-spoke-with-dual-region-dr
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/networking/hub-spoke-with-dual-region-dr
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

- Confirm provider aliases and region variables.
- Review CIDR ranges across both regions.
- Keep primary and secondary route assumptions explicit.
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
