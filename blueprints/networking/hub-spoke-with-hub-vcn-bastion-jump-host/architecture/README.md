# Hub-Spoke Bastion Jump Host Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Adds OCI Bastion access to the hub-spoke landing-zone network so administrators can reach private targets without public host exposure.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Adds OCI Bastion access to the hub-spoke landing-zone network so administrators can reach private targets without public host exposure. |
| Terraform components | `network`, `bastion` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Hub-Spoke Bastion Jump Host                                                                       |
|                                                                                                  |
|  Administrator workstation                                                                        |
|       | allowed by client_cidr_block_allow_list                                                   |
|       v                                                                                          |
|  +----------------------------- OCI Bastion -----------------------------+                       |
|  | Bastion service endpoint created in selected hub subnet                |                       |
|  | max_session_ttl_in_seconds controls session lifetime                   |                       |
|  +-------------------------------+---------------------------------------+                       |
|                                  | managed session to private targets                             |
|                                  v                                                                  |
|  +-------------------------------- Hub VCN -----------------------------------+                  |
|  | DMZ/firewall/shared subnets, gateways, DRG attachment                       |                  |
|  +-------------------------------+--------------------------------------------+                  |
|                                  | DRG                                                               |
|                                  v                                                                  |
|  +------------------------------- Spoke VCNs ---------------------------------+                  |
|  | private web/app/db hosts stay without public SSH/RDP exposure               |                  |
|  +----------------------------------------------------------------------------+                  |
|                                                                                                  |
|  Traffic: admin -> Bastion session -> private IP target in hub or spoke through routed network.    |
|  Control: hub-spoke network is created first; Bastion uses module.network.hub_subnet_ids.          |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `bastion` | `modules/security/bastion @ v0.2.0` |

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

- The hub-spoke network is created first, then OCI Bastion is placed in the selected hub subnet.
- client_cidr_block_allow_list and max_session_ttl_in_seconds define the administrative access envelope.
- Bastion sessions reach private IP targets through the routed hub/spoke network without assigning public IPs to targets.
- Review the bastion subnet, route tables, NSGs/security lists, and target host access before enabling production sessions.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `bastion`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
