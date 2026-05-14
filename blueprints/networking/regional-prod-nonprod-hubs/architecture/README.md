# Regional Prod Nonprod Hubs Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/regional-prod-nonprod-hubs`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates separate prod and nonprod hub-spoke networks in the same region with distinct CIDR spaces and environment tags.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/regional-prod-nonprod-hubs` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates separate prod and nonprod hub-spoke networks in the same region with distinct CIDR spaces and environment tags. |
| Terraform components | `prod_network`, `nonprod_network` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Regional Prod Nonprod Hubs                                                                               |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {One OCI region / separated operating environments}                                                      |
|         |                                                                                                |
|         +--> [prod hub-spoke network]                                                                    |
|         |      hub VCN -> DRG -> prod spokes -> prod route/security controls                             |
|         |                                                                                                |
|         `--> [nonprod hub-spoke network]                                                                 |
|                hub VCN -> DRG -> nonprod spokes -> nonprod route/security controls                       |
|                                                                                                          |
| Boundary: prod and nonprod keep separate hubs, DRGs, route tables, gateways, and attachment maps.        |
| Review focus: CIDR non-overlap, policy separation, shared-service exceptions, and promotion path         |
| controls.                                                                                                |
| Hand-off: environment-specific hub, DRG, spoke, subnet, route, and gateway IDs.                          |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `prod_network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `nonprod_network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |

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

- Production and nonproduction networks are separate hub-spoke module instances in the same region.
- Each side has distinct hub CIDRs, spoke CIDRs, subnets, DRGs, and environment tags.
- There is no shared DRG between prod and nonprod in this deployment, so connectivity remains separated unless another layer connects them.
- Review CIDR separation, tags, route tables, and any future peering requirement before adding workloads.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `prod_network`, `nonprod_network`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
