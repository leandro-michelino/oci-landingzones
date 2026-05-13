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
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_id`, `subnet_ids`, `zpr_configuration_id`, `zpr_policy_ids` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Standalone Three-Tier VCN ZPR                                                                     |
|                                                                                                  |
|  Application traffic                                                                              |
|       |                                                                                            |
|       v                                                                                            |
|  +----------------------------- Workload VCN -----------------------------+                     |
|  | Internet Gateway, NAT Gateway, and Service Gateway enabled              |                     |
|  | Web subnet -> App subnet -> DB subnet                                  |                     |
|  | Subnets from var.subnets                                               |                     |
|  +------------------------------+----------------------------------------+                     |
|                                 | protected by ZPR configuration/policies                     |
|                                 v                                                               |
|  +-------------------------- Zero Trust Packet Routing -------------------+                     |
|  | enable_zpr_configuration controls tenancy/network configuration         |                     |
|  | enable_zpr_policies controls policy creation                           |                     |
|  | var.zpr_policies describes allowed subjects/resources/flows             |                     |
|  +------------------------------+----------------------------------------+                     |
|                                 |                                                               |
|                                 v                                                               |
|  Allowed flows: client -> web, web -> app, app -> db, private tiers -> OCI services               |
|                                                                                                  |
|  Traffic: normal VCN routes carry packets; ZPR policies decide which packets are authorized.      |
+--------------------------------------------------------------------------------------------------+
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

## Review Checklist

- Confirm the diagram matches `main.tf`: `workload_vcn`, `zpr`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_id`, `subnet_ids`, `zpr_configuration_id`, `zpr_policy_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
