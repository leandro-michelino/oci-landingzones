# Hub-Spoke Multicloud Interconnect Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/hub-spoke-with-multicloud-interconnect`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Adds both FastConnect and IPSec connectivity to a hub-spoke DRG for private and backup multicloud routes.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-multicloud-interconnect` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Adds both FastConnect and IPSec connectivity to a hub-spoke DRG for private and backup multicloud routes. |
| Terraform components | `network`, `fastconnect`, `ipsec_vpn` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Hub-Spoke Multicloud Interconnect                                                                 |
|                                                                                                  |
|  Remote cloud / on-prem network                                                                   |
|        | primary private path                         | backup or alternate encrypted path       |
|        v                                              v                                          |
|  +---------------- OCI FastConnect VC ----------------+   +---------------- OCI IPSec VPN ------+|
|  | provider service ID/key, BGP ASN, bandwidth        |   | CPE IP + remote cloud CIDR routes    ||
|  +-----------------------------+----------------------+   +------------------+------------------+|
|                                |                                             |                   |
|                                +-------------------+-------------------------+                   |
|                                                    v                                             |
|  +-------------------------------------------- DRG ---------------------------------------------+|
|  | Route exchange between FastConnect, IPSec, hub VCN, and all spoke attachments                 ||
|  +------------------------------+----------------------------------------------+----------------+|
|                                 |                                              |                 |
|                                 v                                              v                 |
|                     Hub VCN DMZ/firewall/shared                    Spoke web/app/db tiers         |
|                                                                                                  |
|  Traffic: remote cloud routes prefer FastConnect when designed that way; IPSec can provide        |
|  encrypted backup or separate CIDR reachability through the same DRG.                             |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `fastconnect` | `modules/networking/fastconnect @ v0.2.0` |
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

- The hub-spoke network exposes the DRG ID, then FastConnect and IPSec resources attach to the same transit point.
- FastConnect provides the private provider path while IPSec can provide encrypted backup or separate remote CIDR reachability.
- remote_cloud_cidr_blocks, customer BGP ASN, provider service details, and CPE address define the multicloud edge.
- Review route preference, failover behavior, and overlapping CIDRs before advertising production routes.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `fastconnect`, `ipsec_vpn`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
