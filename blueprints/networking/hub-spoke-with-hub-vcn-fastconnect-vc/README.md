# Hub-Spoke With FastConnect Virtual Circuit

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for
`blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc`. It tells you what the
blueprint builds, which inputs deserve a real review, how to run Terraform or the local
Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc` |
| Best fit | Adds FastConnect virtual circuit integration to a hub-spoke network for dedicated hybrid connectivity. |
| Terraform shape | `network`, `fastconnect` |
| Inputs to settle first | `compartment_ocid`, `virtual_circuit_label`, `virtual_circuit_type`, `bandwidth_shape_name`, `customer_bgp_asn`, `provider_service_id`, `provider_service_key_name` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `spoke_vcn_ids`, `virtual_circuit_id`, plus 1 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Adds FastConnect virtual circuit integration to a hub-spoke network for dedicated hybrid
connectivity.

## When To Use This Deployment

- Hybrid connectivity uses FastConnect.
- DRG, hub VCN, and provider circuit state need a single blueprint.
- Network teams need explicit hand-off outputs.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.1.0` |
| Module | `fastconnect` | `modules/networking/fastconnect @ v0.1.0` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/
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
| `virtual_circuit_label` | Short semantic label for the virtual circuit. |
| `virtual_circuit_type` | FastConnect virtual circuit type. |
| `bandwidth_shape_name` | FastConnect bandwidth shape name. |
| `customer_bgp_asn` | Customer BGP ASN for the virtual circuit. |
| `provider_service_id` | Provider service OCID for partner FastConnect circuits. |
| `provider_service_key_name` | Provider service key/name supplied by the FastConnect partner. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_fastconnect` | Create the FastConnect virtual circuit. Keep false until provider and BGP details are ready. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `hub_vcn_id` | Hub VCN OCID. |
| `drg_id` | DRG OCID. |
| `spoke_vcn_ids` | Spoke VCN OCIDs keyed by spoke name. |
| `virtual_circuit_id` | FastConnect virtual circuit OCID. |
| `virtual_circuit_state` | FastConnect virtual circuit lifecycle state. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc
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

- Confirm provider, bandwidth, cross-connect, and routing details.
- Review BGP and DRG route assumptions.
- Coordinate external provider tasks outside Terraform.
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
