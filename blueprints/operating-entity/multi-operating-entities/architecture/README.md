# Multi Operating Entities Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/operating-entity/multi-operating-entities`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates multiple operating entity compartment trees, shared IAM groups, and policies from a single deployment input.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/operating-entity/multi-operating-entities` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates multiple operating entity compartment trees, shared IAM groups, and policies from a single deployment input. |
| Terraform components | `entity_compartments`, `groups`, `policies` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `entity_compartment_ids`, `entity_compartment_names`, `entity_group_ids`, `entity_group_names`, `entity_policy_ids`, ... |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Multi Operating Entities                                                                          |
|                                                                                                  |
|  Platform owner                                                                                   |
|       | entities map / default_workload_compartments                                             |
|       v                                                                                          |
|  +-------------------------- Entity Compartment Forest --------------------+                     |
|  | for_each local.entities                                                 |                     |
|  |                                                                        |                     |
|  | Entity A root -> child workload compartments                            |                     |
|  | Entity B root -> child workload compartments                            |                     |
|  | Entity N root -> child workload compartments                            |                     |
|  +-------------------------------+----------------------------------------+                     |
|                                  | entity compartment names and IDs                           |
|                                  v                                                               |
|  +------------------------------- IAM ------------------------------------+                     |
|  | Shared groups generated for each entity                                 |                     |
|  | Policies scope each group to its matching entity compartments           |                     |
|  +-------------------------------+----------------------------------------+                     |
|                                  | permissions                                              |
|                                  v                                                               |
|  Entity teams receive isolated roots while central operators keep one repeatable vending pattern   |
|                                                                                                  |
|  Flow: all entity compartment trees are created, then groups, then entity-scoped policies.         |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `entity_compartments` | `modules/iam/compartments @ v0.2.0` |
| Module | `groups` | `modules/iam/groups @ v0.2.0` |
| Module | `policies` | `modules/iam/policies @ v0.2.0` |

## Request And Deployment Flow

- Operator supplies the entity or workload shape and parent compartment.
- Terraform creates the compartment boundary, then IAM groups, then scoped policies.
- Outputs hand compartment IDs, group names, and policy statements to platform and app teams.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- Each entity in the input map receives its own compartment tree through for_each.
- Groups and policies are generated to keep entity permissions scoped to the matching entity boundary.
- This deployment is useful when the platform team wants one repeatable onboarding action for multiple business units.
- Review naming, parent compartments, and group-policy mappings carefully because mistakes can affect multiple entities at once.

## Review Checklist

- Confirm the diagram matches `main.tf`: `entity_compartments`, `groups`, `policies`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `entity_compartment_ids`, `entity_compartment_names`, `entity_group_ids`, `entity_group_names`, `entity_policy_ids`, `entity_policy_statements`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
