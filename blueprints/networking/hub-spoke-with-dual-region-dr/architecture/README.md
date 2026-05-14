# Dual Region Hub-Spoke DR Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/hub-spoke-with-dual-region-dr`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates matching hub-spoke network foundations in primary and secondary OCI regions for regional disaster recovery patterns.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-dual-region-dr` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates matching hub-spoke network foundations in primary and secondary OCI regions for regional disaster recovery patterns. |
| Terraform components | `primary_network`, `secondary_network` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Dual Region Hub-Spoke DR                                                                                 |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Primary region}                                      {Secondary region}                                 |
|         |                                                     |                                          |
|         v                                                     v                                          |
| [primary hub-spoke network]                         [secondary hub-spoke network]                        |
|         |-- hub VCN / DRG / spoke VCNs                       |-- hub VCN / DRG / spoke VCNs              |
|         |-- primary route tables and gateways                 |-- secondary route tables and gateways    |
|         `-- primary hand-off IDs                              `-- secondary hand-off IDs                 |
|                 |                                                     |                                  |
|                 +---------------- paired design review ----------------+                                 |
|                                                                                                          |
| Traffic stance: regional traffic stays local until a DR, replication, or routing layer intentionally     |
| links regions.                                                                                           |
| Review focus: CIDR non-overlap, route symmetry, DNS strategy, failover runbooks, and region-specific     |
| service limits.                                                                                          |
| Hand-off: primary and secondary network IDs for DR, replication, and application deployment layers.      |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `primary_network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `secondary_network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |

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

- The primary and secondary hub-spoke networks are independent module instances with separate region and region_key values.
- Each region receives its own hub VCN, DRG, spoke VCNs, subnets, gateways, and DRG attachments.
- Cross-region replication, DNS steering, and disaster recovery orchestration are intentionally external layers that consume these network outputs.
- The key review is CIDR separation and operational parity between primary and secondary regions.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `primary_network`, `secondary_network`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
