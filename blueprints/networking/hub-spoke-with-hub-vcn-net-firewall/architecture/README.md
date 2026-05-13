# Hub-Spoke OCI Network Firewall Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/hub-spoke-with-hub-vcn-net-firewall`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Adds OCI Network Firewall in the hub VCN firewall subnet for centralized north-south and east-west inspection.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-hub-vcn-net-firewall` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Adds OCI Network Firewall in the hub VCN firewall subnet for centralized north-south and east-west inspection. |
| Terraform components | `network`, `network_firewall` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `hub_subnet_ids`, `network_firewall_id`, `network_firewall_private_ip` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Hub-Spoke OCI Network Firewall                                                                    |
|                                                                                                  |
|  Internet / On-prem / Spoke traffic                                                               |
|             |                                                                                    |
|             v                                                                                    |
|  +-------------------------------- Hub VCN -----------------------------------+                  |
|  | DMZ subnet       -> ingress/egress edge                                      |                  |
|  | Firewall subnet  -> OCI Network Firewall private endpoint                    |                  |
|  | Shared subnet    -> shared services                                          |                  |
|  | IGW, NAT Gateway, Service Gateway                                            |                  |
|  +------------------------------+---------------------------------------------+                  |
|                                 | traffic selected by route tables                              |
|                                 v                                                                  |
|  +----------------------- OCI Network Firewall -------------------------------+                  |
|  | network_firewall_policy_id is supplied by the caller                         |                  |
|  | network_firewall_private_ip becomes the inspection route target              |                  |
|  +------------------------------+---------------------------------------------+                  |
|                                 | allowed traffic                                                |
|                                 v                                                                  |
|  +---------------- DRG ----------------+       +---------------- Spoke VCNs ----------------+    |
|  | hub/spoke attachments                |<----->| web, app, database tiers                  |    |
|  +--------------------------------------+       +------------------------------------------+    |
|                                                                                                  |
|  Traffic: route tables steer north-south and east-west packets through the firewall private IP.    |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `network_firewall` | `modules/networking/net-firewall @ v0.2.0` |

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

- The hub-spoke network is created first, then OCI Network Firewall is placed in the selected hub firewall subnet.
- network_firewall_policy_id is supplied by the caller and should be reviewed before traffic is routed to the firewall private IP.
- Route tables decide which north-south and east-west flows use the firewall as the inspection target.
- Review route symmetry, service gateway exceptions, and spoke-to-spoke paths so packets return through the expected inspection path.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `network_firewall`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `hub_subnet_ids`, `network_firewall_id`, `network_firewall_private_ip`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
