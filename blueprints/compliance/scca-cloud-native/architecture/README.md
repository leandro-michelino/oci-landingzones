# SCCA Cloud Native Compliance Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/compliance/scca-cloud-native`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Composes the core landing-zone foundation, a firewall-centered hub-spoke network, and OS management controls for SCCA-style cloud-native workloads.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/compliance/scca-cloud-native` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Composes the core landing-zone foundation, a firewall-centered hub-spoke network, and OS management controls for SCCA-style cloud-native workloads. |
| Terraform components | `core`, `network`, `os_management` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| SCCA Cloud Native Compliance                                                                             |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {SCCA-style cloud-native boundary}                                                                       |
|         |                                                                                                |
|         +--> [core Level 2 foundation] compartments, IAM, logging, Cloud Guard, Vault, VSS, monitoring   |
|         |                                                                                                |
|         +--> [firewall-centered hub-spoke network]                                                       |
|         |      ingress/egress -> hub -> OCI Network Firewall -> DRG -> spoke web/app/db tiers            |
|         |                                                                                                |
|         `--> [OS Management Hub] managed instance groups -> scheduled patch jobs -> operator evidence    |
|                                                                                                          |
| Traffic flow: internet/on-prem -> DRG or hub edge -> firewall policy -> spoke workloads.                 |
| Operations flow: patch jobs, findings, logs, and alarms return to governance operators.                  |
| Hand-off: foundation IDs, network/firewall IDs, and OS management resource IDs.                          |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `core` | `../../../blueprints/core` |
| Module | `network` | `../../../blueprints/networking/hub-spoke-with-hub-vcn-net-firewall` |
| Module | `os_management` | `../../../modules/operations/os-management` |

## Request And Deployment Flow

- Terraform creates the core governance/security foundation first.
- The compliance network or platform layer consumes core compartment and security outputs.
- Traffic and operational signals follow the specific compliance pattern shown in the diagram.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- Core Level 2 controls are created first, then the network module consumes the core network compartment output.
- The network path centers on a hub VCN with OCI Network Firewall in the firewall subnet and spoke VCNs attached through the DRG.
- OS Management resources live in the governance compartment and provide patch/group/job control for managed instances that join the landing zone.
- North-south and east-west traffic should be reviewed against the firewall policy, DRG attachments, subnet route tables, and service gateway paths.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `core`, `network`, `os_management`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
