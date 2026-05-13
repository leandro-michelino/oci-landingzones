# Workload Vending Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/operating-entity/workload-vending`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates a workload compartment tree, workload IAM groups, and scoped policies for repeatable application onboarding.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/operating-entity/workload-vending` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates a workload compartment tree, workload IAM groups, and scoped policies for repeatable application onboarding. |
| Terraform components | `compartments`, `groups`, `policies` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`, `compartment_names`, `group_ids`, `group_names`, ... |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Workload Vending                                                                                  |
|                                                                                                  |
|  App onboarding request                                                                           |
|       | workload_code, workload_name, child_compartments                                          |
|       v                                                                                          |
|  +---------------------------- Workload Root -----------------------------+                      |
|  | Parent compartment or supplied parent_compartment_ocid                  |                      |
|  |   `-- Workload root compartment                                        |                      |
|  |       |-- network                                                      |                      |
|  |       |-- app                                                          |                      |
|  |       |-- data                                                         |                      |
|  |       `-- custom children from var.child_compartments                   |                      |
|  +-------------------------------+----------------------------------------+                      |
|                                  | compartment_names                                           |
|                                  v                                                                |
|  +------------------------------- IAM ------------------------------------+                      |
|  | Workload admin/operator/viewer groups                                   |                      |
|  | Policies scoped to the workload compartment tree                         |                      |
|  +-------------------------------+----------------------------------------+                      |
|                                  | permissions                                               |
|                                  v                                                                |
|  Workload team deploys VCN, platform extensions, and app resources using the vended boundary       |
|                                                                                                  |
|  Flow: Terraform creates the workload boundary and then exports IDs for the app pipeline.          |
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

- The workload root and child compartments are created first, followed by workload-specific groups and scoped policies.
- This deployment is the application-team onboarding path for repeatable workload boundaries.
- It does not create network resources; it prepares the compartment and IAM scope where network and app blueprints can land.
- Review workload_code, workload_name, child compartment shape, and policy scope before handing the boundary to an app team.

## Review Checklist

- Confirm the diagram matches `main.tf`: `compartments`, `groups`, `policies`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`, `compartment_names`, `group_ids`, `group_names`, `policy_ids`, `policy_statements`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
