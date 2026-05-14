# CIS Level 1 Landing Zone Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/cis/level1`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Builds the core landing-zone foundation with CIS Level 1-oriented governance, security, logging, IAM, and operations controls.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/cis/level1` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Builds the core landing-zone foundation with CIS Level 1-oriented governance, security, logging, IAM, and operations controls. |
| Terraform components | `core` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| CIS Level 1 Landing Zone                                                                                 |
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
| CIS overlay: Level 1 defaults bias toward evidence, audit retention, Cloud Guard, and tighter review     |
| gates.                                                                                                   |
| Control flow: compartments first, then tagging/governance/security, then IAM policy bindings.            |
| Signal flow: logs, events, alarms, findings, and budget alerts return to governance operators.           |
| Hand-off: compartment IDs, IAM names, policy IDs, log groups, topics, vault/key IDs, and guardrail IDs.  |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `core` | `blueprints/core @ v0.2.0` |

## Request And Deployment Flow

- The wrapper passes cis_level = level1 into the core blueprint.
- Core creates the baseline compartment, IAM, logging, Cloud Guard, Vault, scanning, budgets, events, and monitoring controls.
- Outputs are the same core hand-off contract so Level 1 can feed later network and workload deployments.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- This deployment is a thin CIS Level 1 wrapper around the core foundation, so the operational graph is inherited from blueprints/core.
- The wrapper passes cis_level = level1 to tune the foundation posture while keeping the downstream output contract stable.
- Level 1 review should focus on baseline IAM separation, audit/log retention choices, tagging, monitoring, Cloud Guard, Vault/KMS, and enabled scan targets.
- Downstream network and workload blueprints consume the same core outputs regardless of whether the baseline came from core, CIS Level 1, or CIS Level 2.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `core`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
