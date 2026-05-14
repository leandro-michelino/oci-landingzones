# Full Stack Disaster Recovery Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/disaster-recovery/fsdr`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates OCI Full Stack Disaster Recovery protection groups, log buckets, and an optional DR plan across primary and standby regions.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/disaster-recovery/fsdr` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates OCI Full Stack Disaster Recovery protection groups, log buckets, and an optional DR plan across primary and standby regions. |
| Terraform components | `oci_objectstorage_namespace.primary`, `oci_objectstorage_namespace.standby`, `oci_objectstorage_bucket.primary_dr_logs`, `oci_objectstorage_bucket.standby_dr_logs`, `oci_disaster_recovery_dr_protection_group.primary`, `oci_disaster_recovery_dr_protection_group.standby`, `oci_disaster_recovery_dr_plan.primary` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Full Stack Disaster Recovery                                                                             |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Primary OCI provider alias}                         {Standby OCI provider alias}                        |
|         |                                                       |                                        |
|         v                                                       v                                        |
| [primary region]                                      [standby region]                                   |
|         |-- [Object Storage namespace]                         |-- [Object Storage namespace]            |
|         |-- [primary DR log bucket]                             |-- [standby DR log bucket]              |
|         `-- [primary DR protection group] <---- peer ---->       `-- [standby DR protection group]       |
|                          |                                                                               |
|                          v                                                                               |
|                  [primary DR plan]                                                                       |
|                  |-- switchover / failover / start-stop orchestration                                    |
|                  `-- members supplied from application resource IDs                                      |
|                                                                                                          |
| Control flow: log buckets first, both protection groups second, DR plan last.                            |
| Runtime flow: application replication remains outside this folder; FSDR orchestrates recovery actions.   |
| Hand-off: primary/standby protection group IDs, log bucket names, and DR plan ID.                        |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Data source | `oci_objectstorage_namespace.primary` | `Read during plan/apply` |
| Data source | `oci_objectstorage_namespace.standby` | `Read during plan/apply` |
| Resource | `oci_objectstorage_bucket.primary_dr_logs` | `Declared directly in main.tf` |
| Resource | `oci_objectstorage_bucket.standby_dr_logs` | `Declared directly in main.tf` |
| Resource | `oci_disaster_recovery_dr_protection_group.primary` | `Declared directly in main.tf` |
| Resource | `oci_disaster_recovery_dr_protection_group.standby` | `Declared directly in main.tf` |
| Resource | `oci_disaster_recovery_dr_plan.primary` | `Declared directly in main.tf` |

## Request And Deployment Flow

- Operator reviews tfvars, enable flags, and required external IDs.
- Terraform creates resources in the dependency order declared by main.tf.
- Outputs expose the hand-off contract for the next deployment, app team, or runbook.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- The primary and standby OCI providers target different regions and create region-local log buckets before DR protection groups.
- Protection group members should map to real application resources that can be moved, recovered, or orchestrated by FSDR.
- The DR plan is created only after protection groups exist and should be reviewed against the intended failover or switchover type.
- Runtime application replication is outside this folder; this deployment prepares the FSDR control plane and log locations.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_objectstorage_namespace.primary`, `oci_objectstorage_namespace.standby`, `oci_objectstorage_bucket.primary_dr_logs`, `oci_objectstorage_bucket.standby_dr_logs`, `oci_disaster_recovery_dr_protection_group.primary`, `oci_disaster_recovery_dr_protection_group.standby`, `oci_disaster_recovery_dr_plan.primary`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
