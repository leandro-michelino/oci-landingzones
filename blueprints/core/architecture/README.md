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


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Core Landing Zone                                                                                        |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {OCI tenancy / home region IAM / target region services}                                                 |
|         |                                                                                                |
|         +--> [compartment tree]                                                                          |
|         |      root or parent compartment                                                                |
|         |      +-- governance                                                                            |
|         |      +-- security                                                                              |
|         |      +-- network                                                                               |
|         |      `-- workloads                                                                             |
|         |                                                                                                |
|         +--> [identity layer]                                                                            |
|         |      groups -> dynamic groups -> scoped IAM policies                                           |
|         |                                                                                                |
|         +--> [governance layer]                                                                          |
|         |      tags -> log groups -> service logs -> events -> monitoring -> budgets                     |
|         |                                                                                                |
|         +--> [security layer]                                                                            |
|                Cloud Guard -> Vault/KMS -> Security Zones -> Vulnerability Scanning                      |
|                                                                                                          |
| Control flow: compartments first, then tagging/governance/security, then IAM policy bindings.            |
| Signal flow: logs, events, alarms, findings, and budget alerts return to governance operators.           |
| Hand-off: foundation IDs are consumed by networking, operating-entity, compliance, data, and extension   |
| blueprints.                                                                                              |
+----------------------------------------------------------------------------------------------------------+
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

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `compartments`, `tagging`, `logging`, `cloud_guard`, `vault`, `security_zones`, `vss`, `budgets`, `events`, `monitoring`, `groups`, `dynamic_groups`, `policies`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
