# Azure + OCI Cross-Cloud DR Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for
`blueprints/disaster-recovery/azure-oci-cross-cloud-dr`. It is intentionally
Architecture-first so it is easy to review in GitHub, terminals, pull requests,
runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Implements a cross-cloud DR pattern where OCI is primary and Azure is standby,
with DNS failover runbook contracts and optional interconnect or
without-interconnect operation modes.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | OCI-primary to Azure-standby DR with contract outputs for connectivity, DNS failover, and runbook execution. |
| Terraform components | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_app`, `oci_core_subnet.primary_app`, `oci_objectstorage_namespace.this`, `oci_objectstorage_bucket.dr_evidence`, `oci_ons_notification_topic.dr_alert`, `terraform_data.connectivity_contract`, `terraform_data.dns_failover_contract`, `terraform_data.runbook_contract` |
| Primary architecture view | The Architecture diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |

## Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Azure + OCI Cross-Cloud DR                                                                              |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {OCI primary cloud boundary}                                                                             |
|         |                                                                                                |
|         |-- [Primary VCN + route table + security list + app subnet]                                    |
|         |-- [Object Storage namespace]                                                                   |
|         |-- [DR evidence bucket]                                                                         |
|         |-- [DR alert topic]                                                                             |
|         `-- [terraform_data contracts]                                                                   |
|               |-- connectivity mode: interconnect or without-interconnect                                |
|               |-- DNS failover: app FQDN, primary endpoint, standby endpoint                            |
|               `-- runbook: drill cadence, RTO/RPO, failover/failback steps                              |
|                                                                                                          |
| {Azure standby cloud boundary}                                                                            |
|         |                                                                                                |
|         v                                                                                                |
| (Standby app endpoint)                                                                                   |
|                                                                                                          |
| [Clients] -> [DNS steering layer] -> OCI primary endpoint                                                |
|                               `-> Azure standby endpoint on failover                                    |
|                                                                                                          |
| Guardrail: OCI remains primary in this blueprint variant.                                                |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_app`, `oci_core_subnet.primary_app` | Deploy-and-use OCI primary networking stack for DR workloads. |
| Resource | `terraform_data.oci_network_contract` | OCI network contract output for operations and downstream hand-off. |
| Data source | `oci_objectstorage_namespace.this` | Read during plan/apply for evidence bucket namespace. |
| Resource | `oci_objectstorage_bucket.dr_evidence` | Optional evidence bucket for drills and incidents. |
| Resource | `oci_ons_notification_topic.dr_alert` | Optional DR alert topic for operator notifications. |
| Resource | `terraform_data.connectivity_contract` | Connectivity mode contract including interconnect IDs when provided. |
| Resource | `terraform_data.dns_failover_contract` | DNS failover runbook contract for primary/standby cutover. |
| Resource | `terraform_data.runbook_contract` | Runbook metadata for drill cadence and recovery targets. |

## Request And Deployment Flow

- Operator sets connectivity mode and endpoint assumptions in local tfvars.
- Terraform creates optional OCI primary networking, evidence, and alert resources.
- Terraform publishes connectivity, DNS failover, and runbook contracts as outputs.
- Runbook owners consume outputs for drills, failover, and failback procedures.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the application path shown in the Architecture diagram: client traffic targets OCI primary and shifts to Azure standby during runbook-driven failover.
- Trust boundaries are the OCI tenancy boundary, Azure boundary represented by external standby endpoint IDs, and optional interconnect boundary represented by FastConnect + ExpressRoute partner links.
- Secrets, OCIDs, endpoint URLs, circuit IDs, and operational contacts belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter
during review, plan, and hand-off.

- The blueprint keeps OCI as primary through variable validation and output contracts.
- Connectivity can run with partner interconnect (`interconnect`) or explicitly without interconnect (`without-interconnect`) for staged or constrained environments.
- The DNS failover contract captures endpoint and TTL assumptions so operational teams can align cutover timing with runbook tests.
- The runbook contract stores drill cadence and RTO/RPO targets so governance checks can compare planned versus measured recovery behavior.
- Azure resources are provisioned through the local Azure session artifacts (`azure/main.bicep` and `ansible/azure-*.yml`) and referenced in Terraform by standby endpoint values.
- `hello-world/index.html` is included as a lightweight drill/demo status page that mirrors the same primary/standby assumptions.
- Azure Container Apps capacity is regional. Treat
  `ManagedEnvironmentCapacityHeavyUsageError` as a regional capacity issue, not
  as a blueprint contract failure; delete the failed test resource group and
  retry in an approved alternate region.

## Operational Boundaries

- This extension can run extension-only with supplied endpoint and connectivity identifiers, or as part of a broader base-plus-extension operating model.
- Keep customer-specific OCIDs, CIDRs, circuit IDs, endpoint URLs, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so provider files and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check runbook objective targets and endpoint assumptions whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_app`, `oci_core_subnet.primary_app`, `oci_objectstorage_namespace.this`, `oci_objectstorage_bucket.dr_evidence`, `oci_ons_notification_topic.dr_alert`, `terraform_data.connectivity_contract`, `terraform_data.dns_failover_contract`, `terraform_data.runbook_contract`.
- Confirm OCI is primary and Azure is standby for this environment.
- Confirm connectivity mode selection and interconnect IDs where applicable.
- Confirm DNS endpoint and TTL assumptions support the intended cutover model.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
