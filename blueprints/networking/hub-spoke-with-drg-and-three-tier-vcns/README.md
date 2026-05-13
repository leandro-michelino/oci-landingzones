# Hub-Spoke With DRG And Three-Tier VCNs

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for
`blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns`. It tells you what the
blueprint builds, which inputs deserve a real review, how to run Terraform or the local
Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns` |
| Best fit | Builds a hub VCN, DRG, spoke VCNs, and DRG attachments for a classic routed hub-spoke landing-zone network. |
| Terraform shape | `hub_vcn`, `drg`, `spoke_vcns`, `oci_core_drg_attachment.hub`, `oci_core_drg_attachment.spokes` |
| Inputs to settle first | `compartment_ocid`, `hub_vcn_dns_label`, `hub_vcn_cidr_block`, `hub_subnets`, `spoke_vcns`, `spoke_route_tables`, `spoke_security_lists` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `hub_subnet_ids`, `spoke_vcn_ids`, plus 2 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Builds a hub VCN, DRG, spoke VCNs, and DRG attachments for a classic routed hub-spoke
landing-zone network.

## When To Use This Deployment

- Multiple workload VCNs need central routing.
- A DRG is the routing hub.
- Spoke VCN subnet tiers need repeatable creation.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `hub_vcn` | `modules/networking/hub-vcn @ v0.2.0` |
| Module | `drg` | `modules/networking/drg @ v0.2.0` |
| Module | `spoke_vcns` | `modules/networking/spoke-vcn @ v0.2.0` |
| Resource | `oci_core_drg_attachment.hub` | Declared directly in `main.tf` |
| Resource | `oci_core_drg_attachment.spokes` | Declared directly in `main.tf` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/
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
| `compartment_ocid` | Compartment OCID where networking resources are deployed. Defaults to tenancy_ocid for simple tests. |
| `hub_vcn_dns_label` | DNS label for the hub VCN. |
| `hub_vcn_cidr_block` | CIDR block for the hub VCN. |
| `hub_subnets` | Hub subnet map. |
| `spoke_vcns` | Spoke VCNs keyed by workload or team name. |
| `spoke_route_tables` | Route tables applied to all spokes. |
| `spoke_security_lists` | Security lists applied to all spokes. |

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
| `resource_ids` | Map of primary resource identifiers created by this blueprint. |
| `hub_vcn_id` | Hub VCN OCID. |
| `drg_id` | DRG OCID. |
| `hub_subnet_ids` | Hub subnet OCIDs keyed by role. |
| `spoke_vcn_ids` | Spoke VCN OCIDs keyed by spoke name. |
| `spoke_subnet_ids` | Spoke subnet OCIDs keyed by spoke name. |
| `drg_attachment_ids` | DRG attachment OCIDs. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns
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

- Review CIDR overlap and route propagation.
- Confirm hub and spoke attachment intent.
- Validate inspection and DNS choices before apply.
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
