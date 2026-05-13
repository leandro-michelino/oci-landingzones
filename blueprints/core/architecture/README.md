# Core Landing Zone Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/core`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates the shared OCI foundation: compartments, tags, logging, Cloud Guard, Vault, security zones, scanning, budgets, events, monitoring, groups, dynamic groups, and IAM policies.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/core` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates the shared OCI foundation: compartments, tags, logging, Cloud Guard, Vault, security zones, scanning, budgets, events, monitoring, groups, dynamic groups, and IAM policies. |
| Terraform components | `compartments`, `tagging`, `logging`, `cloud_guard`, `vault`, `security_zones`, `vss`, `budgets`, `events`, `monitoring`, `groups`, `dynamic_groups`, `policies` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `cis_level`, `root_compartment_id`, `compartment_ids`, `network_compartment_id`, `security_compartment_id`, `governance_compartment_id`, ... |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Core Landing Zone                                                                                |
|                                                                                                  |
|  Operator / CI / Ansible                                                                         |
|          | terraform plan/apply                                                                  |
|          v                                                                                       |
|  +-------------------------- OCI Tenancy / Home Region IAM ---------------------------+          |
|  | Compartments                                                                       |          |
|  |   root/parent -> governance, security, network, workloads                          |          |
|  | IAM                                                                                |          |
|  |   admin groups + dynamic groups -> policies scoped to compartments                 |          |
|  | Tagging                                                                            |          |
|  |   namespace, tag definitions, tag defaults applied to landing-zone compartments     |          |
|  +-------------------------------+----------------------------------------------------+          |
|                                  |                                                               |
|                                  v                                                               |
|  +---------------------- Governance Compartment ----------------------+                           |
|  | Logging: log groups, service logs, VCN flow-log targets, saved searches            |           |
|  | Audit retention: tenancy audit configuration                                       |           |
|  | Budgets: cost targets and alert rules                                              |           |
|  | Events + Notifications: event rules -> ONS topics/subscriptions                    |           |
|  | Monitoring: alarms -> notification topics/subscriptions                            |           |
|  +-------------------------------+----------------------------------------------------+          |
|                                  | signals, alarms, events                                      |
|                                  v                                                               |
|  +----------------------- Security Compartment -----------------------+                           |
|  | Cloud Guard configuration and targets watch the root/landing-zone compartments      |           |
|  | Vault/KMS creates vaults and master encryption keys for downstream resources        |           |
|  | Security Zones attach recipes to protected compartments when enabled                |           |
|  | Vulnerability Scanning Service creates host/container scan recipes and targets      |           |
|  +-------------------------------+----------------------------------------------------+          |
|                                  | outputs consumed by network, app, data, compliance blueprints |
|                                  v                                                               |
|  resource_ids, compartment_ids, policy_ids, vault_key_ids, log_group_ids, alarm_ids               |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `compartments` | `modules/iam/compartments @ v0.2.0` |
| Module | `tagging` | `modules/governance/tagging @ v0.2.0` |
| Module | `logging` | `modules/governance/logging @ v0.2.0` |
| Module | `cloud_guard` | `modules/security/cloud-guard @ v0.2.0` |
| Module | `vault` | `modules/security/vault @ v0.2.0` |
| Module | `security_zones` | `modules/security/security-zones @ v0.2.0` |
| Module | `vss` | `modules/security/vss @ v0.2.0` |
| Module | `budgets` | `modules/governance/budgets @ v0.2.0` |
| Module | `events` | `modules/governance/events @ v0.2.0` |
| Module | `monitoring` | `modules/operations/monitoring @ v0.2.0` |
| Module | `groups` | `modules/iam/groups @ v0.2.0` |
| Module | `dynamic_groups` | `modules/iam/dynamic-groups @ v0.2.0` |
| Module | `policies` | `modules/iam/policies @ v0.2.0` |

## Request And Deployment Flow

- Provider authentication targets the tenancy and home-region IAM provider.
- Compartment creation runs before tagging, governance, security, and IAM policy resources that reference those compartments.
- Security and governance services publish IDs for downstream network, identity, compliance, and workload deployments.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- Compartment creation is the root dependency for tagging, security, governance, operations, and IAM policy scope.
- Home-region IAM resources create groups, dynamic groups, and policies while regional services create logging, monitoring, events, Vault/KMS, VSS, and budgets.
- Cloud Guard, Security Zones, and VSS protect the root or workload compartments, while logging and monitoring provide the operational signal path.
- Downstream deployments should consume compartment_ids, policy_ids, log group IDs, vault key IDs, and alarm/topic IDs instead of hard-coding foundation resources.

## Review Checklist

- Confirm the diagram matches `main.tf`: `compartments`, `tagging`, `logging`, `cloud_guard`, `vault`, `security_zones`, `vss`, `budgets`, `events`, `monitoring`, `groups`, `dynamic_groups`, `policies`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `cis_level`, `root_compartment_id`, `compartment_ids`, `network_compartment_id`, `security_compartment_id`, `governance_compartment_id`, `workloads_compartment_id`, `compartment_names`, `tag_namespace_id`, `tag_namespace_name`, ....
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
