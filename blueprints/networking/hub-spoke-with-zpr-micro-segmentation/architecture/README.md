# Hub-Spoke ZPR Micro-Segmentation Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/hub-spoke-with-zpr-micro-segmentation`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Adds Zero Trust Packet Routing configuration and policies to a hub-spoke network for micro-segmented traffic control.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-zpr-micro-segmentation` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Adds Zero Trust Packet Routing configuration and policies to a hub-spoke network for micro-segmented traffic control. |
| Terraform components | `network`, `zpr` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Hub-Spoke ZPR Micro-Segmentation                                                                  |
|                                                                                                  |
|  Hub-spoke network                                                                                |
|       | hub and spoke VCN IDs                                                                     |
|       v                                                                                          |
|  +----------------------------- Network Data Plane ----------------------------+                 |
|  | Hub VCN: DMZ/firewall/shared subnets, gateways, DRG attachment              |                 |
|  | Spoke VCNs: web/app/db tiers, spoke DRG attachments                         |                 |
|  +-------------------------------+---------------------------------------------+                 |
|                                  | protected resource scope                                      |
|                                  v                                                                  |
|  +------------------------- Zero Trust Packet Routing -------------------------+                 |
|  | ZPR configuration                                                           |                 |
|  | ZPR policies from var.zpr_policies                                          |                 |
|  | Controls allowed communication between resources, networks, and services     |                 |
|  +-------------------------------+---------------------------------------------+                 |
|                                  | allowed flows only                                             |
|                                  v                                                                  |
|  Workload flows: web -> app, app -> db, spoke -> shared services, hub -> OCI services              |
|                                                                                                  |
|  Traffic: route tables still move packets; ZPR policies provide additional packet authorization.   |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
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

- The hub-spoke network creates the normal packet path, then ZPR configuration and policies define additional communication authorization.
- ZPR policies should describe allowed flows between hub services, spoke web/app/db tiers, and OCI services.
- Route tables and DRG attachments still move packets; ZPR decides whether the packet is allowed by policy.
- Review policy scope and default-deny effects carefully before applying to shared or production compartments.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `zpr`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
