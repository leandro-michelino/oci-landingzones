# CIS Basic Identity Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/identity/cis-basic`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates baseline IAM groups, dynamic groups, and policies suitable for CIS-aligned landing-zone administration.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/identity/cis-basic` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates baseline IAM groups, dynamic groups, and policies suitable for CIS-aligned landing-zone administration. |
| Terraform components | `groups`, `dynamic_groups`, `policies` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `cis_level`, `resource_ids`, `group_ids`, `group_names`, `dynamic_group_ids`, `policy_ids` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| CIS Basic Identity                                                                                |
|                                                                                                  |
|  Human administrators, break-glass users, automation principals                                    |
|                 |                                                                                |
|                 v                                                                                |
|  +---------------------------- OCI IAM Home Region ----------------------------+                  |
|  | Groups                                                                     |                  |
|  | - default CIS-aligned admin, security, network, app, auditor groups         |                  |
|  |                                                                            |                  |
|  | Dynamic Groups                                                              |                  |
|  | - workload/resource principal matching rules                                |                  |
|  |                                                                            |                  |
|  | Policies                                                                    |                  |
|  | - group_names + dynamic_group_names -> tenancy/compartment permissions      |                  |
|  +-------------------------------+--------------------------------------------+                  |
|                                  | permissions gate all resource plane actions                    |
|                                  v                                                                  |
|                         Landing-zone compartments and OCI services                                |
|                                                                                                  |
|  Flow: create groups and dynamic groups first, then policies referencing those names.              |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `groups` | `../../../modules/iam/groups` |
| Module | `dynamic_groups` | `../../../modules/iam/dynamic-groups` |
| Module | `policies` | `../../../modules/iam/policies` |

## Request And Deployment Flow

- Provider authentication uses the home-region IAM plane.
- Terraform creates domains, groups, dynamic groups, or policies in dependency order.
- Outputs expose identity IDs, names, URLs, and policy IDs for operators and downstream blueprints.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- Groups and dynamic groups are created before policies so policy statements can reference stable principal names.
- This deployment lives in the IAM control plane and does not create data-plane traffic, but it gates who can operate the landing zone.
- Policy scope should be reviewed against target compartments and least-privilege requirements before apply.
- Outputs expose group, dynamic group, and policy identifiers for governance review and downstream automation.

- The output contract at the end of this page is the hand-off surface for downstream blueprints, runbooks, and customer notes.

## State, Inputs, And Outputs

```text
Input sources
|-- terraform.tfvars.example documents expected values for this deployment
|-- local ignored tfvars provide tenancy, compartment, CIDR, endpoint, and service-specific values
|-- environment variables may provide OCI authentication and guarded Ansible confirms
|
Terraform state
|-- backend is disabled for local validation and blueprint-local runners by default
|-- production state backends should be configured outside this reusable blueprint folder
|-- generated .terraform directories, lock files, plans, state files, and local tfvars stay out of git
|
Output contract
|-- blueprint_name
|-- name_prefix
|-- cis_level
|-- resource_ids
|-- group_ids
|-- group_names
|-- dynamic_group_ids
`-- policy_ids
```


## Review Checklist

- Confirm the diagram matches `main.tf`: `groups`, `dynamic_groups`, `policies`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `cis_level`, `resource_ids`, `group_ids`, `group_names`, `dynamic_group_ids`, `policy_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
