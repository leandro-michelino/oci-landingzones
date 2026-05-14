# Oracle Integration Cloud Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/oic`. It is intentionally ASCII-first so it is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys an Oracle Integration Cloud instance with optional private outbound connection.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/extensions/oic` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Deploys an Oracle Integration Cloud instance with optional private outbound connection. |
| Terraform components | `oci_integration_integration_instance.this`, `oci_integration_private_endpoint_outbound_connection.this` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic or control flow for this exact deployment. |

## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Oracle Integration Cloud                                                                                 |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Existing compartment / VCN / subnet / service boundary as required}                                     |
|         |                                                                                                |
|         v                                                                                                |
| [Oracle Integration Cloud]                                                                               |
|         |-- integration instance with edition, message packs, and access type                            |
|         |-- private outbound connection when enabled                                                     |
|         |-- network path toward private SaaS, app, database, or API endpoints                            |
|         `-- tags, compartment scope, and optional private access controls                                |
|                  |                                                                                       |
|                  v                                                                                       |
| [integration designers] -> [OIC instance] -> [private outbound connection] -> [private endpoints/APIs]   |
|                                                                                                          |
| Review focus: edition, endpoint access type, outbound subnet/NSGs, route tables, DNS, and integration    |
| IAM scope.                                                                                               |
| Hand-off: service IDs, endpoint names, private access IDs, and operational references for application    |
| teams.                                                                                                   |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_integration_integration_instance.this` | Declared directly in `main.tf` |
| Resource | `oci_integration_private_endpoint_outbound_connection.this` | Declared directly in `main.tf` |

## Request And Deployment Flow

- Operator supplies the existing network, compartment, service, or backend IDs required by the deployment.
- Terraform creates the optional service resource graph declared in `main.tf`.
- Outputs expose service IDs, endpoint names, or attachment IDs for applications and runbooks.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is permission and signal flow.
- Trust boundaries are the tenancy, compartment, VCN, subnet, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

- Confirm edition, message packs, BYOL, and file server decisions.
- Confirm private outbound subnet and NSGs.
- Confirm IDCS/domain authentication inputs when required by tenancy policy.

## Operational Boundaries

- This extension can run extension-only with supplied brownfield OCI IDs, or as
  base-plus-extension using outputs from core, networking, ownership, or
  operations blueprints.
- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_integration_integration_instance.this`, `oci_integration_private_endpoint_outbound_connection.this`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
