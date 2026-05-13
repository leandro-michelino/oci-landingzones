# Standalone Three-Tier VCN Custom Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/standalone-three-tier-vcn-custom`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates a configurable standalone three-tier workload VCN with caller-controlled CIDRs, gateways, subnets, route tables, and security lists.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/standalone-three-tier-vcn-custom` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates a configurable standalone three-tier workload VCN with caller-controlled CIDRs, gateways, subnets, route tables, and security lists. |
| Terraform components | `workload_vcn` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Standalone Three-Tier VCN Custom                                                                  |
|                                                                                                  |
|  Internet clients / private workloads / OCI services                                              |
|       |                       |                         |                                       |
|       | IGW when enabled      | NAT when enabled        | SGW when enabled                       |
|       v                       v                         v                                       |
|  +--------------------------- Workload VCN ---------------------------+                         |
|  | VCN CIDR blocks from var.vcn_cidr_blocks                            |                         |
|  | DNS label from var.vcn_dns_label                                    |                         |
|  |                                                                    |                         |
|  |  public or private web subnet -> app subnet -> database subnet       |                         |
|  |  additional/custom subnets from var.subnets                          |                         |
|  |  route_tables and security_lists are caller-defined                  |                         |
|  +---------------------------+----------------------------------------+                         |
|                              |                                                                  |
|                              v                                                                  |
|          Downstream apps consume vcn_id, subnet_ids, route_table_ids, gateway_ids                 |
|                                                                                                  |
|  Traffic: exactly follows caller-defined subnet, route table, gateway, and security-list maps.     |
|  Control: one spoke-vcn module owns all network resources for this standalone deployment.          |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `workload_vcn` | `modules/networking/spoke-vcn @ v0.2.0` |

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

- This VCN lets the caller control CIDR blocks, gateways, route tables, subnets, and security lists.
- Web, app, database, or custom subnet roles come from var.subnets rather than fixed assumptions.
- Packet paths follow the caller-defined route table map, so ingress, egress, NAT, service gateway, and private routes must be reviewed together.
- This is the flexible standalone pattern for application teams that need a VCN without a hub-spoke dependency.

## Review Checklist

- Confirm the diagram matches `main.tf`: `workload_vcn`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
