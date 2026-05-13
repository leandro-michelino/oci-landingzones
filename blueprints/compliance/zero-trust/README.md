# Zero Trust Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/compliance/zero-trust`. It tells you
what the blueprint builds, which inputs deserve a real review, how to run Terraform or the
local Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/compliance/zero-trust` |
| Best fit | Creates a private, segmented, identity-aware landing-zone pattern with ZPR, network controls, and least-privilege boundaries called out up front. |
| Terraform shape | `core`, `network` |
| Inputs to settle first | `parent_compartment_ocid`, `network_compartment_ocid`, `default_security_zone_recipe_id`, `zpr_policies` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`, `vcn_id`, `subnet_ids`, plus 1 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Creates a private, segmented, identity-aware landing-zone pattern with ZPR, network
controls, and least-privilege boundaries called out up front.

## When To Use This Deployment

- Trust must be earned at each network and identity boundary.
- Private access, segmentation, and inspected paths are explicit design goals.
- ZPR, NSGs, IAM, and network placement need to be reviewed together.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `core` | `../../../blueprints/core` |
| Module | `network` | `../../../blueprints/networking/standalone-three-tier-vcn-zpr` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/compliance/zero-trust/
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
| `parent_compartment_ocid` | Parent compartment OCID for the zero-trust landing zone root compartment. Defaults to tenancy_ocid when omitted. |
| `network_compartment_ocid` | Optional compartment OCID for zero-trust network resources. Defaults to the network compartment created by core. |
| `default_security_zone_recipe_id` | Security Zone recipe OCID used by the default Security Zone. |
| `zpr_policies` | ZPR policies keyed by logical name. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_delete` | Allow Terraform to delete compartments during destroy. Review carefully for production. |
| `enable_tagging` | Create the landing zone tag namespace, tag definitions, and tag defaults. |
| `enable_tag_defaults` | Create tag defaults for zero-trust landing zone compartments. |
| `vault_enabled` | Create OCI Vault resources through the core blueprint. |
| `enable_default_vault_key` | Create a default KMS key when the default vault is created. |
| `security_zones_enabled` | Create OCI Security Zones through the core blueprint. |
| `vss_enabled` | Create Vulnerability Scanning Service resources through the core blueprint. |
| `enable_default_host_scan` | Create the default VSS host scan recipe and target. |
| `enable_events` | Create OCI Events and Notifications resources through the core blueprint. |
| `monitoring_enabled` | Create OCI Monitoring resources through the core blueprint. |
| `enable_zpr_configuration` | Enable Zero Trust Packet Routing configuration. |
| `enable_zpr_policies` | Create ZPR policy statements for the zero-trust network. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `root_compartment_id` | OCID of the zero-trust landing zone root compartment. |
| `compartment_ids` | Map of zero-trust landing zone compartment keys to OCIDs. |
| `vcn_id` | Zero-trust workload VCN OCID. |
| `subnet_ids` | Zero-trust workload subnet OCIDs keyed by tier. |
| `zpr_policy_ids` | ZPR policy OCIDs keyed by logical name. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/compliance/zero-trust
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/compliance/zero-trust
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Confirm the selected compliance profile.
2. Review tenancy-wide controls, monitoring, vault, VSS, and event settings.
3. Populate `terraform.tfvars` with security and notification inputs.
4. Run plan and review control impact.
5. Apply only after the security owner accepts the profile.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Confirm ZPR configuration and policy readiness.
- Review private endpoint and service gateway paths.
- Avoid treating the internal network as an implicit trust zone.
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
