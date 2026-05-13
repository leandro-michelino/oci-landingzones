# Single Operating Entity Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/operating-entity`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates one operating entity compartment tree with entity-specific IAM groups and scoped policies.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/operating-entity` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates one operating entity compartment tree with entity-specific IAM groups and scoped policies. |
| Terraform components | `compartments`, `groups`, `policies` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Single Operating Entity                                                                           |
|                                                                                                  |
|  Platform owner                                                                                   |
|       | entity name, workload_compartments, policy compartment                                    |
|       v                                                                                          |
|  +-------------------------- OCI Compartment Tree -------------------------+                     |
|  | Parent compartment or tenancy root                                      |                     |
|  |   `-- Operating entity root compartment                                 |                     |
|  |       |-- workload/network/security/governance children from inputs      |                     |
|  |       `-- optional custom child compartments                             |                     |
|  +-------------------------------+----------------------------------------+                     |
|                                  | compartment_names                                          |
|                                  v                                                               |
|  +------------------------------- IAM ------------------------------------+                     |
|  | Groups: entity admin/operator/viewer style groups from locals            |                     |
|  | Policies: scoped statements against the entity compartment names         |                     |
|  +-------------------------------+----------------------------------------+                     |
|                                  | permissions                                              |
|                                  v                                                               |
|  Operating entity teams deploy network, app, and data blueprints inside their compartments         |
|                                                                                                  |
|  Flow: compartments are created first, groups second, policies last because policies reference both.|
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `compartments` | `modules/iam/compartments @ v0.2.0` |
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

- The compartment tree is created first, then entity groups, then scoped policies that reference the created compartment names.
- This deployment establishes an ownership boundary for one business unit, subsidiary, or operating entity.
- It does not create network traffic; the important flow is permission delegation from tenancy IAM into the entity compartment tree.
- Downstream teams should deploy networking, data, and extensions inside the exported entity compartments.

## Review Checklist

- Confirm the diagram matches `main.tf`: `compartments`, `groups`, `policies`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
