# Standalone Three-Tier VCN ZPR Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/standalone-three-tier-vcn-zpr`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates a standalone three-tier VCN and applies Zero Trust Packet Routing configuration and policies for segmentation.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/standalone-three-tier-vcn-zpr` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates a standalone three-tier VCN and applies Zero Trust Packet Routing configuration and policies for segmentation. |
| Terraform components | `workload_vcn`, `zpr` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Standalone Three-Tier VCN ZPR                                                                            |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Workload compartment / selected region}                                                                 |
|         |                                                                                                |
|         v                                                                                                |
| [Workload VCN]                                                                                           |
|         |-- [public web subnet]  -> route table -> Internet Gateway when enabled                         |
|         |-- [private app subnet] -> route table -> NAT Gateway / Service Gateway                         |
|         `-- [private db subnet]  -> route table -> private east-west only                                |
|              |                                                                                           |
|              +--> [security lists / NSGs] gate tier-to-tier traffic                                      |
|              +--> [gateway set] IGW / NAT / SGW according to blueprint variables                         |
|                                                                                                          |
| ZPR overlay: security attributes and policies add packet-level micro-segmentation above subnet routing.  |
| North-south: client -> web tier -> app tier -> database tier.                                            |
| Service path: private subnets -> service gateway for OCI services; outbound updates use NAT when         |
| enabled.                                                                                                 |
| Hand-off: VCN, subnet, route table, security, and gateway IDs for workloads or later extensions.         |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `workload_vcn` | `modules/networking/spoke-vcn @ v0.2.0` |
| Module | `zpr` | `modules/networking/zpr @ v0.2.0` |

## Request And Deployment Flow

- Operator reviews CIDRs, subnet maps, gateway flags, route targets, and inspection requirements.
- Terraform creates the network foundation first, then dependent attachments or network services declared in main.tf.
- Traffic follows the diagrammed route path, and outputs expose VCN, subnet, DRG, gateway, DNS, inspection, or policy IDs for the next deployment.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- This deployment creates a standalone three-tier VCN and then applies ZPR configuration and policies.
- The network still provides the web/app/db packet path through normal VCN routing and gateways.
- ZPR policies add packet authorization for specific resources, subjects, compartments, and services.
- Review policy blast radius and expected web-to-app/app-to-db flows before applying to production workloads.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `workload_vcn`, `zpr`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
