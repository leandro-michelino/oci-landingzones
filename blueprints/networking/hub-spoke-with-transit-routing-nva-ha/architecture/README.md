# Hub-Spoke Transit Routing NVA HA Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/hub-spoke-with-transit-routing-nva-ha`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Adds highly available network virtual appliances and route target private IPs to a hub-spoke transit network.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-transit-routing-nva-ha` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Adds highly available network virtual appliances and route target private IPs to a hub-spoke transit network. |
| Terraform components | `network`, `nva_ha` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `spoke_vcn_ids`, `appliance_instance_ids`, `route_target_private_ip_ids` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Hub-Spoke Transit Routing NVA HA                                                                  |
|                                                                                                  |
|  Spoke VCNs / on-prem / hub services                                                              |
|          | selected route table targets                                                           |
|          v                                                                                        |
|  +-------------------------------- Hub VCN -----------------------------------+                  |
|  | Appliance subnets host two or more NVA instances                             |                  |
|  | Reserved route IPs provide stable next-hop targets                           |                  |
|  | Hub DRG attachment exchanges routes with spokes                              |                  |
|  +-------------------------------+--------------------------------------------+                  |
|                                  |                                                                  |
|                                  v                                                                  |
|  +----------------------- HA Network Virtual Appliances ----------------------+                  |
|  | appliance_instance_ids from var.appliances                                  |                  |
|  | route_target_private_ip_ids expose private IPs for route tables             |                  |
|  | existing_route_target_private_ip_ids can import prebuilt HA targets          |                  |
|  +-------------------------------+--------------------------------------------+                  |
|                                  | inspected/transit forwarding                                  |
|                                  v                                                                  |
|  +------------------------ DRG and Spoke Attachments -------------------------+                  |
|  | east-west and north-south transit paths can be forced through the NVAs       |                  |
|  +----------------------------------------------------------------------------+                  |
|                                                                                                  |
|  Traffic: route table -> reserved route IP/NVA -> next hop through DRG, hub, spoke, or edge.      |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `nva_ha` | `modules/networking/net-appliance @ v0.2.0` |

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

- The hub-spoke network is created first, then HA NVA instances and route target private IPs are created or referenced.
- Reserved route IPs provide stable next-hop targets that route tables can use during appliance failover.
- Traffic can be forced through NVAs for inspection or transit before returning to the DRG, hub, spoke, or edge destination.
- Review route symmetry, appliance HA behavior, health checks, and failover timing before steering production traffic.

- The output contract at the end of this page is the hand-off surface for downstream blueprints, runbooks, and customer notes.

## State, Inputs, And Outputs

```text
Input sources
|-- terraform.tfvars.example documents expected values for this deployment
|-- local ignored tfvars provide tenancy, compartment, CIDR, endpoint, and service-specific values
|-- environment variables may provide OCI authentication and guarded Ansible confirms
|
Terraform state
|-- backend is disabled for local validation and blueprint-local runners by default
|-- production state backends should be configured outside this reusable blueprint folder
|-- generated .terraform directories, lock files, plans, state files, and local tfvars stay out of git
|
Output contract
|-- blueprint_name
|-- name_prefix
|-- resource_ids
|-- hub_vcn_id
|-- drg_id
|-- spoke_vcn_ids
|-- appliance_instance_ids
`-- route_target_private_ip_ids
```


## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `nva_ha`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `spoke_vcn_ids`, `appliance_instance_ids`, `route_target_private_ip_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
