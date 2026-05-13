# Zero Trust Compliance Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/compliance/zero-trust`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Composes the core landing-zone foundation with a standalone three-tier VCN protected by OCI Zero Trust Packet Routing policies.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/compliance/zero-trust` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Composes the core landing-zone foundation with a standalone three-tier VCN protected by OCI Zero Trust Packet Routing policies. |
| Terraform components | `core`, `network` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Zero Trust Landing Zone                                                                           |
|                                                                                                  |
|  Operator / CI                                                                                    |
|       |                                                                                          |
|       v                                                                                          |
|  +--------------------------- Core Level 2 Foundation ---------------------------+                |
|  | Compartments, IAM, Cloud Guard, Vault/KMS, VSS, logging, events, monitoring   |                |
|  +----------------------------+--------------------------------------------------+                |
|                               | network_compartment_id                                           |
|                               v                                                                  |
|  +-------------------------- Standalone Three-Tier VCN -------------------------+                |
|  | VCN CIDR from var.vcn_cidr_block                                              |                |
|  |                                                                                              |
|  |  Internet -> IGW -> public route table -> web subnet                          |                |
|  |  web subnet -> app subnet -> db subnet                                        |                |
|  |  private tiers -> NAT Gateway for controlled outbound internet                |                |
|  |  private tiers -> Service Gateway for private OCI service access              |                |
|  +----------------------------+--------------------------------------------------+                |
|                               |                                                                  |
|                               v                                                                  |
|  +--------------------------- Zero Trust Packet Routing -------------------------+                |
|  | ZPR configuration                                                             |                |
|  | ZPR policies describing which subjects, compartments, and endpoints may talk   |                |
|  | Micro-segmentation overlays route/security-list decisions for east-west paths  |                |
|  +----------------------------+--------------------------------------------------+                |
|                               |                                                                  |
|                               v                                                                  |
|  Outputs: vcn_id, subnet_ids, zpr_policy_ids, compartment_ids, governance/security hand-offs      |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `core` | `../../../blueprints/core` |
| Module | `network` | `../../../blueprints/networking/standalone-three-tier-vcn-zpr` |

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

- Core Level 2 controls are created first, then the standalone ZPR-enabled VCN consumes the core network compartment output.
- The VCN provides web, app, and database tiers while ZPR policies provide an additional packet authorization layer over normal route and security-list behavior.
- Policy review should confirm which subjects, resources, compartments, and services are allowed to communicate before apply.
- The key hand-off is the VCN/subnet output plus ZPR configuration and policy IDs for security review and downstream workload placement.

## Review Checklist

- Confirm the diagram matches `main.tf`: `core`, `network`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
