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
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `hub_subnet_ids`, `oke_cluster_id`, `oke_node_pool_id`, ... |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Telco Cloud Native                                                                                |
|                                                                                                  |
|  Operators / CNF platform teams                                                                   |
|       |                                                                                          |
|       v                                                                                          |
|  +---------------------------- Hub-Spoke Network -----------------------------+                  |
|  | Hub VCN + DRG + DMZ/firewall/shared subnets                                 |                  |
|  | Spoke VCNs with web/app/db style tiers                                      |                  |
|  | IGW/NAT/SGW provide controlled internet and OCI service paths                |                  |
|  +--------------------+--------------------------+-----------------------------+                  |
|                       |                          |                                                |
|                       v                          v                                                |
|  +--------------------------+       +----------------------------+                                |
|  | OKE Cluster              |       | Vault / KMS                 |                                |
|  | endpoint in hub subnet   |       | keys for platform services  |                                |
|  | service LB subnet        |       +----------------------------+                                |
|  | node pool subnet         |                                                                  |
|  +-----------+--------------+       +----------------------------+                                |
|              |                      | Monitoring + OS Management  |                                |
|              v                      | alarms, topics, jobs, groups|                                |
|       CNF workloads                 +----------------------------+                                |
|                                                                                                  |
|  Traffic: operators -> OKE endpoint; clients -> service LB; nodes -> VCN routes and OCI services. |
|  Control: network outputs feed OKE subnet IDs; Vault, Monitoring, and OS Management share tags.    |
+--------------------------------------------------------------------------------------------------+
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

- The output contract at the end of this page is the hand-off surface for downstream blueprints, runbooks, and customer notes.

## State, Inputs, And Outputs

```text
Input sources
|-- terraform.tfvars.example documents expected values for this deployment
|-- local ignored tfvars provide tenancy, compartment, CIDR, endpoint, and service-specific values
|-- environment variables may provide OCI authentication and guarded Ansible confirms
|
Terraform state
|-- backend is disabled for local validation and blueprint-local runners by default
|-- production state backends should be configured outside this reusable blueprint folder
|-- generated .terraform directories, lock files, plans, state files, and local tfvars stay out of git
|
Output contract
|-- blueprint_name
|-- name_prefix
|-- resource_ids
|-- hub_vcn_id
|-- drg_id
|-- hub_subnet_ids
|-- oke_cluster_id
|-- oke_node_pool_id
|-- vault_ids
|-- monitoring_alarm_ids
`-- os_management_resource_ids
```


## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `vault`, `oke`, `monitoring`, `os_management`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `hub_subnet_ids`, `oke_cluster_id`, `oke_node_pool_id`, `vault_ids`, `monitoring_alarm_ids`, `os_management_resource_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
