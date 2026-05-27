# OCI NoSQL Database Architecture

This page is the deployment architecture for `blueprints/data-platform/nosql`.
It is intentionally Architecture-first so it is easy to review in GitHub,
terminals, pull requests, runbooks, and customer-safe notes without a diagramming
tool.

## Deployment Purpose

Implements a managed OCI NoSQL table pattern with optional secondary index,
optional cross-region replica, and deploy-and-use app networking for consumers.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/data-platform/nosql` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Build a production-ready NoSQL table contract plus optional index/replica and app network hand-off. |
| Terraform components | `oci_core_vcn.app`, `oci_core_route_table.app`, `oci_core_security_list.app`, `oci_core_subnet.app`, `oci_nosql_table.this`, `oci_nosql_index.secondary`, `oci_nosql_table_replica.this`, `oci_ons_notification_topic.alert`, `terraform_data.app_network_contract`, `terraform_data.nosql_contract` |
| Primary architecture view | The Architecture diagram below shows dependency order and table/consumer flow for this deployment. |

## Architecture

```text
+--------------------------------------------------------------------------------------------------------------+
| OCI NoSQL Database Blueprint                                                                                 |
+--------------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow                  |
|                                                                                                              |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                              |
|         |                    |                         |                                                     |
|         | validates docs      | init/validate/plan      | OCI API calls                                      |
|         v                    v                         v                                                     |
| {OCI tenancy boundary}                                                                                       |
|   |                                                                                                          |
|   |-- [App VCN + route table + security list + subnet] (optional)                                           |
|   |-- [NoSQL table]                                                                                          |
|   |      |-- schema from DDL                                                                                 |
|   |      `-- capacity limits (read/write/storage)                                                            |
|   |-- [NoSQL secondary index] (optional)                                                                     |
|   |-- [NoSQL table replica] (optional cross-region)                                                          |
|   |-- [Notifications topic] (optional)                                                                       |
|   `-- [terraform_data contracts + optional IAM policy]                                                       |
|          |-- app network hand-off                                                                            |
|          `-- table capacity and replication contract                                                         |
|                                                                                                              |
| [Consumer app tier] -> NoSQL SDK/API -> [NoSQL table]                                                       |
+--------------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.app`, `oci_core_route_table.app`, `oci_core_security_list.app`, `oci_core_subnet.app` | Optional app-network resources for NoSQL consumer workloads. |
| Resource | `oci_nosql_table.this` | Core table resource with schema and capacity limits. |
| Resource | `oci_nosql_index.secondary` | Optional secondary index for access patterns. |
| Resource | `oci_nosql_table_replica.this` | Optional replica for regional resilience. |
| Resource | `oci_ons_notification_topic.alert` | Optional notifications topic for NoSQL operations. |
| Resource | `oci_identity_policy.access` | Optional policy shell for operators and app access groups. |
| Resource | `terraform_data.app_network_contract` | Network ID contract output for downstream wiring. |
| Resource | `terraform_data.nosql_contract` | Schema/capacity/replica contract output for hand-off. |

## Request And Deployment Flow

- Operator sets schema, capacity, and replica intent in local tfvars.
- Terraform creates optional app-network resources first.
- Terraform creates the NoSQL table and optional index/replica resources.
- Terraform emits hand-off contracts for downstream operations and app teams.
- Operators use outputs for app integration, IAM review, and runbook updates.

## Traffic And Trust Boundaries

- Control plane traffic is local/CI authentication into OCI provider and
  Terraform runner through Ansible wrappers.
- Data plane traffic is application-to-NoSQL API traffic governed by app-side
  subnet and security controls when app-network resources are enabled.
- Trust boundaries include compartment ownership, optional policy ownership,
  and optional cross-region replica boundary.
- Secrets and private identifiers belong in ignored local tfvars or secure
  pipeline variable stores.

## Detailed Architecture Notes

These notes expand the diagram with design details usually needed in reviews.

- The DDL statement is the table schema contract and should be reviewed with the app team.
- Capacity limits are explicit outputs so FinOps and operations can track agreed thresholds.
- Secondary index creation is optional and intentionally requires explicit column input.
- Replica creation is optional and enforces a target region when enabled.
- App-network resources are optional because some consumers already run in existing VCN estates.
- Optional IAM policy statements let teams codify access in the same blueprint when desired.

## Operational Boundaries

- This blueprint supports extension-only use with existing compartment and network standards.
- Apply and destroy are approval-gated operations; use guarded Ansible playbooks.
- Keep tenancy-specific OCIDs, DDL variants, and access statements in local ignored tfvars.
- Re-run plan whenever DDL, capacity, index, or replica settings change.
- Use the output contracts in downstream runbooks and app onboarding checklists.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_core_vcn.app`, `oci_core_route_table.app`, `oci_core_security_list.app`, `oci_core_subnet.app`, `oci_nosql_table.this`, `oci_nosql_index.secondary`, `oci_nosql_table_replica.this`, `oci_ons_notification_topic.alert`, `terraform_data.app_network_contract`, `terraform_data.nosql_contract`.
- Confirm DDL, key model, and index expectations are approved by the app owner.
- Confirm capacity and storage limits are realistic for expected workload.
- Confirm replica region intent and change-management path when replica is enabled.
- Confirm app-network ingress and route assumptions when network resources are enabled.
- Confirm policy statements map to intended operator and consumer groups.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared runner.
