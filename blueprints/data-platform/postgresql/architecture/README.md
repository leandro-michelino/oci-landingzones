# PostgreSQL Landing Zone Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/data-platform/postgresql`. It is intentionally ASCII-first so it is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys a private OCI PostgreSQL DB system with network controls, storage durability settings, backup/maintenance policy hooks, optional restore source, and optional scoped IAM policy.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/data-platform/postgresql` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Provides a private managed PostgreSQL database foundation for application teams. |
| Terraform components | `oci_psql_db_system.this`, `oci_identity_policy.access` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic or control flow for this exact deployment. |

## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| PostgreSQL Landing Zone                                                                                  |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Database compartment / private network boundary}                                                        |
|         |                                                                                                |
|         +--> (private database subnet)                                                                   |
|         |        |                                                                                       |
|         |        v                                                                                       |
|         |   [PostgreSQL DB system]                                                                       |
|         |        |-- primary private endpoint                                                            |
|         |        |-- optional reader endpoint                                                            |
|         |        |-- NSGs allow app subnets or approved admin paths only                                |
|         |        |-- regionally durable or AD-scoped storage                                           |
|         |        `-- maintenance and backup policy                                                       |
|         |                                                                                                |
|         +--> (Vault secret or secure tfvars)                                                             |
|         |        `-- admin credential source                                                             |
|         |                                                                                                |
|         `--> [IAM access policy]                                                                         |
|                  optional DBA, operator, or application statements                                       |
|                                                                                                          |
| Data path: app subnet -> NSG-approved PostgreSQL private endpoint on port 5432.                          |
| Operations path: DBA/operator -> approved private access path -> PostgreSQL service control plane.       |
| Hand-off: DB system ID, state, instance details, admin username, and optional access policy ID.          |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_psql_db_system.this` | Declared directly in `main.tf` |
| Resource | `oci_identity_policy.access` | Optional scoped IAM policy declared directly in `main.tf` |

## Request And Deployment Flow

- Operator supplies tenancy values, private subnet, NSGs, version, shape, storage, backup, and credential settings.
- Terraform creates the PostgreSQL DB system, network details, storage details, optional management policy, optional source restore settings, and optional IAM policy.
- Outputs expose DB system ID, state, instance details, admin username, and policy ID for app teams and runbooks.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is application traffic to the private PostgreSQL endpoint, typically on port 5432 and scoped by NSGs.
- Trust boundaries are the tenancy, compartment, private subnet, NSG, credential source, storage durability boundary, and IAM policy edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, database passwords, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

- Keep PostgreSQL in a private subnet and expose it only to app subnets or approved admin paths.
- Prefer Vault secret references for admin credentials when the deployment process can read approved secret OCIDs.
- Review storage durability and availability domain placement together; regional durability and AD-specific placement are different operational choices.
- Use backup and maintenance policy settings deliberately so restore and maintenance expectations are visible before apply.
- Use IAM policy statements only for approved DBA, operator, or application groups.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_psql_db_system.this`, `oci_identity_policy.access`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
