# SCCA Cloud Native Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/compliance/scca-cloud-native`. It tells
you what the blueprint builds, which inputs deserve a real review, how to run Terraform or
the local Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/compliance/scca-cloud-native` |
| Best fit | Combines core governance, controlled networking, and operations hooks for a SCCA-style cloud-native landing-zone pattern. |
| Terraform shape | `core`, `network`, `os_management` |
| Inputs to settle first | `parent_compartment_ocid`, `network_compartment_ocid`, `default_security_zone_recipe_id`, `os_managed_instance_groups`, `os_scheduled_jobs` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`, `network_resource_ids`, `os_management_resource_ids` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Combines core governance, controlled networking, and operations hooks for a SCCA-style
cloud-native landing-zone pattern.

## When To Use This Deployment

- A regulated workload needs a SCCA-style control boundary.
- Security, network, and platform teams need one reviewable composition.
- OS Management, network inspection, and baseline controls are part of the landing-zone conversation.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `core` | `../../../blueprints/core` |
| Module | `network` | `../../../blueprints/networking/hub-spoke-with-hub-vcn-net-firewall` |
| Module | `os_management` | `../../../modules/operations/os-management` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/compliance/scca-cloud-native/
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
| `parent_compartment_ocid` | Parent compartment OCID for the SCCA landing zone root compartment. Defaults to tenancy_ocid when omitted. |
| `network_compartment_ocid` | Optional compartment OCID for network resources. Defaults to the network compartment created by core. |
| `default_security_zone_recipe_id` | Security Zone recipe OCID used by the default Security Zone. |
| `os_managed_instance_groups` | OS Management Hub managed instance groups keyed by logical name. |
| `os_scheduled_jobs` | OS Management Hub scheduled jobs keyed by logical name. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_delete` | Allow Terraform to delete compartments during destroy. Review carefully for production. |
| `enable_tagging` | Create the landing zone tag namespace, tag definitions, and tag defaults. |
| `enable_tag_defaults` | Create tag defaults for SCCA landing zone compartments. |
| `vault_enabled` | Create OCI Vault resources through the core blueprint. |
| `enable_default_vault_key` | Create a default KMS key when the default vault is created. |
| `security_zones_enabled` | Create OCI Security Zones through the core blueprint. |
| `vss_enabled` | Create Vulnerability Scanning Service resources through the core blueprint. |
| `enable_default_host_scan` | Create the default VSS host scan recipe and target. |
| `enable_events` | Create OCI Events and Notifications resources through the core blueprint. |
| `monitoring_enabled` | Create OCI Monitoring resources through the core blueprint. |
| `enable_network_firewall` | Create OCI Network Firewall resources in the SCCA hub. |
| `enable_os_management` | Create OS Management Hub resources for SCCA operations. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `root_compartment_id` | OCID of the SCCA landing zone root compartment. |
| `compartment_ids` | Map of SCCA landing zone compartment keys to OCIDs. |
| `network_resource_ids` | SCCA inspected network resource identifiers. |
| `os_management_resource_ids` | OS Management Hub resource identifiers. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/compliance/scca-cloud-native
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/compliance/scca-cloud-native
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

- Confirm the selected inspection model and OS Management scope.
- Review optional paid services and quotas before enabling them.
- Treat the architecture page as the customer review artifact.
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
