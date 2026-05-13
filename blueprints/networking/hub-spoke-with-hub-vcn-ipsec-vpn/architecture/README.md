# Hub-Spoke IPSec VPN Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Adds an OCI IPSec VPN and customer-premises equipment definition to the hub-spoke DRG.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Adds an OCI IPSec VPN and customer-premises equipment definition to the hub-spoke DRG. |
| Terraform components | `network`, `ipsec_vpn` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `spoke_vcn_ids`, `ipsec_id`, `cpe_id` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Hub-Spoke IPSec VPN                                                                               |
|                                                                                                  |
|  On-premises network CIDRs                                                                        |
|       | static routes: var.on_premises_cidr_blocks                                               |
|       v                                                                                          |
|  +---------------- Customer-Premises Equipment ----------------+                                 |
|  | cpe_ip_address, cpe_is_private                              |                                 |
|  +----------------------------+--------------------------------+                                 |
|                               | IPSec tunnels                                                    |
|                               v                                                                  |
|  +------------------------- OCI IPSec VPN ---------------------+                                  |
|  | VPN connection bound to module.network.drg_id                |                                  |
|  +----------------------------+--------------------------------+                                  |
|                               | route propagation/static routes                                  |
|                               v                                                                  |
|  +------------------------------ DRG -----------------------------------------+                  |
|  | connects VPN, hub VCN, and spoke VCN attachments                            |                  |
|  +------------------+-------------------------------------------+--------------+                  |
|                     v                                           v                                 |
|              Hub VCN DMZ/firewall/shared                 Spoke VCN web/app/db tiers               |
|                                                                                                  |
|  Traffic: on-prem -> IPSec tunnel -> DRG -> hub/spoke; return traffic follows DRG VPN routes.     |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `ipsec_vpn` | `modules/networking/ipsec-vpn @ v0.2.0` |

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

- The hub-spoke network exposes the DRG ID, then the IPSec module creates CPE and VPN resources.
- cpe_ip_address, cpe_is_private, and on_premises_cidr_blocks define the remote network endpoint and route set.
- VPN traffic enters the DRG and can reach hub or spoke CIDRs according to DRG and VCN route tables.
- Review tunnel status, shared route intent, and return paths before moving workloads onto the VPN path.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `ipsec_vpn`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `spoke_vcn_ids`, `ipsec_id`, `cpe_id`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
