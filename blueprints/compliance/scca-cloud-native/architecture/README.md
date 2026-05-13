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
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`, `network_resource_ids`, `os_management_resource_ids` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| SCCA Cloud Native                                                                                 |
|                                                                                                  |
|  Operator / CI                                                                                    |
|       |                                                                                          |
|       v                                                                                          |
|  +--------------------------- Core Level 2 Foundation ---------------------------+                |
|  | Compartments: governance, security, network, workloads                        |                |
|  | IAM: groups, dynamic groups, policies                                         |                |
|  | Security: Cloud Guard, Vault/KMS, Security Zones, VSS                         |                |
|  | Governance/Ops: logging, audit retention, budgets, events, monitoring         |                |
|  +----------------------------+--------------------------------------------------+                |
|                               | network_compartment_id, security outputs                         |
|                               v                                                                  |
|  +----------------------------- Hub VCN ----------------------------------------+                |
|  | DMZ subnet -> IGW for approved public ingress/egress                          |                |
|  | Firewall subnet -> OCI Network Firewall + firewall policy                     |                |
|  | Shared subnet -> shared services and operational endpoints                    |                |
|  | NAT Gateway + Service Gateway for controlled outbound and OCI service access  |                |
|  +-----------------------------+------------------------------------------------+                |
|                                | DRG attachments                                                 |
|                                v                                                                 |
|  +------------------- DRG -------------------+        +-------------------------+                |
|  | routes on-prem, hub, and spokes            |<------>| Spoke VCNs              |                |
|  | east-west paths are centralized through hub |        | web -> app -> db tiers  |                |
|  +-------------------+------------------------+        +------------+------------+                |
|                      | inspection path                                    |                      |
|                      v                                                    v                      |
|              OCI Network Firewall                              OS Management Hub                 |
|              policy checks traffic                            managed groups + jobs              |
|                                                                                                  |
|  Traffic: internet/on-prem -> DRG or IGW -> hub -> firewall -> spoke web/app/db tiers.            |
|  Ops: instance patching jobs and security signals return to governance outputs.                   |
+--------------------------------------------------------------------------------------------------+
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

## Review Checklist

- Confirm the diagram matches `main.tf`: `core`, `network`, `os_management`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`, `network_resource_ids`, `os_management_resource_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
