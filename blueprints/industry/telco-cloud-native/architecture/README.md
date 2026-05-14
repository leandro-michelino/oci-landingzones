# Telco Cloud Native Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/industry/telco-cloud-native`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Combines hub-spoke networking, Vault/KMS, OKE, monitoring, and OS management for telco cloud-native workload foundations.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/industry/telco-cloud-native` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Combines hub-spoke networking, Vault/KMS, OKE, monitoring, and OS management for telco cloud-native workload foundations. |
| Terraform components | `network`, `vault`, `oke`, `monitoring`, `os_management` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Telco Cloud Native                                                                                       |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Telco cloud-native landing-zone boundary}                                                               |
|         |                                                                                                |
|         +--> [hub-spoke network]                                                                         |
|         |      DRG, hub subnets, spoke subnets, service gateway, and controlled egress                   |
|         |                                                                                                |
|         +--> [Vault/KMS]                                                                                 |
|         |      key material for platform and workload services                                           |
|         |                                                                                                |
|         +--> [OKE cluster and node pool]                                                                 |
|         |      private worker placement, service load balancer subnet decisions, CNI review              |
|         |                                                                                                |
|         +--> [monitoring alarms] -> notification path for platform operators                             |
|         `--> [OS Management]    -> managed groups and scheduled patch jobs                               |
|                                                                                                          |
| Traffic flow: ingress/shared services -> hub -> DRG -> spoke/OKE workloads.                              |
| Operations flow: alarms and patch jobs return to platform owners for closed-loop operations.             |
| Hand-off: network IDs, OKE IDs, vault/key IDs, monitoring IDs, and OS management IDs.                    |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `../../networking/hub-spoke-with-drg-and-three-tier-vcns` |
| Module | `vault` | `../../../modules/security/vault` |
| Module | `oke` | `../../extensions/oke` |
| Module | `monitoring` | `../../../modules/operations/monitoring` |
| Module | `os_management` | `../../../modules/operations/os-management` |

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

- The hub-spoke network is created first and feeds hub subnet IDs into the OKE endpoint, service load balancer, and node pool choices.
- Vault/KMS provides key-management foundations for platform services that require encryption controls.
- Monitoring and OS Management add operational signals and instance management around the telco workload platform.
- CNF traffic should be reviewed across OKE endpoint access, service load balancer subnets, node subnets, DRG paths, NAT, and service gateway routes.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `vault`, `oke`, `monitoring`, `os_management`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
