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


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Multi Operating Entities                                                                                 |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Operating model compartment boundary}                                                                   |
|         |                                                                                                |
|         v                                                                                                |
| [multi-entity compartment structure]                                                                     |
|         |-- parent or entity compartment                                                                 |
|         |-- workload compartments and optional child boundaries                                          |
|         `-- naming and tag alignment for ownership reporting                                             |
|                  |                                                                                       |
|                  +--> [groups] admin, operator, auditor, and workload-facing groups                      |
|                  `--> [policies] scoped permissions for the owned compartment tree                       |
|                                                                                                          |
| Control flow: compartment tree -> groups -> policies.                                                    |
| Ownership flow: platform creates the boundary, then hands the approved scope to the operating entity or  |
| workload team.                                                                                           |
| Hand-off: compartment IDs/names, group IDs/names, policy IDs, and policy statement review material.      |
+----------------------------------------------------------------------------------------------------------+
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

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `entity_compartments`, `groups`, `policies`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
