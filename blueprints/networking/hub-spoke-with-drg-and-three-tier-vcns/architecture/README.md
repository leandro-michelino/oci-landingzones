# Hub-Spoke DRG And Three-Tier VCN Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates a hub VCN, DRG, spoke VCNs, hub and spoke DRG attachments, and tiered subnets for centralized connectivity.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates a hub VCN, DRG, spoke VCNs, hub and spoke DRG attachments, and tiered subnets for centralized connectivity. |
| Terraform components | `hub_vcn`, `drg`, `spoke_vcns`, `oci_core_drg_attachment.hub`, `oci_core_drg_attachment.spokes` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `hub_subnet_ids`, `spoke_vcn_ids`, `spoke_subnet_ids`, ... |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Hub-Spoke DRG And Three-Tier VCNs                                                                 |
|                                                                                                  |
|  Internet / OCI Services / On-Premises                                                            |
|       |             |                    |                                                       |
|       | IGW/NAT/SGW |                    | DRG route attachments                                  |
|       v             v                    v                                                       |
|  +-------------------------------- Hub VCN -----------------------------------+                  |
|  | CIDR var.hub_vcn_cidr_block, default 10.0.0.0/16                            |                  |
|  | DMZ subnet       -> public ingress/egress through Internet Gateway           |                  |
|  | Firewall subnet  -> inspection appliance or firewall placement               |                  |
|  | Shared subnet    -> shared services and endpoints                            |                  |
|  | NAT Gateway      -> private outbound internet                                |                  |
|  | Service Gateway  -> private OCI service access                               |                  |
|  +---------------------------+-------------------------------------------------+                  |
|                              | hub DRG attachment                                                |
|                              v                                                                  |
|  +------------------------------ DRG -----------------------------------------+                  |
|  | Central route exchange between hub and all spoke VCN attachments             |                  |
|  +------------------+----------------------+----------------+-----------------+                  |
|                     |                      |                |                                    |
|                     v                      v                v                                    |
|       +----------------------+  +----------------------+  +----------------------+                 |
|       | Spoke VCN app1       |  | Spoke VCN appN       |  | Future spoke         |                 |
|       | web subnet           |  | web subnet           |  | web/app/db tiers     |                 |
|       | app subnet           |  | app subnet           |  | via var.spoke_vcns   |                 |
|       | db subnet            |  | db subnet            |  |                      |                 |
|       | SGW for OCI services |  | SGW for OCI services |  |                      |                 |
|       +----------------------+  +----------------------+  +----------------------+                 |
|                                                                                                  |
|  Traffic: north-south enters hub, routes through DRG to spokes; east-west spoke traffic crosses   |
|  the DRG so it can be centralized, inspected, or extended by companion blueprints.                 |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `hub_vcn` | `modules/networking/hub-vcn @ v0.2.0` |
| Module | `drg` | `modules/networking/drg @ v0.2.0` |
| Module | `spoke_vcns` | `modules/networking/spoke-vcn @ v0.2.0` |
| Resource | `oci_core_drg_attachment.hub` | `Declared directly in main.tf` |
| Resource | `oci_core_drg_attachment.spokes` | `Declared directly in main.tf` |

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

- The hub VCN and DRG are created before hub and spoke DRG attachments.
- Spoke VCNs attach to the DRG and use tiered web, app, and database subnets, plus service gateway access where enabled.
- North-south paths enter through hub edge services or external connectivity, then route through the DRG to spokes.
- East-west spoke traffic crosses the DRG so inspection, shared services, or future route controls can be centralized in the hub.

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
|-- hub_subnet_ids
|-- spoke_vcn_ids
|-- spoke_subnet_ids
`-- drg_attachment_ids
```


## Review Checklist

- Confirm the diagram matches `main.tf`: `hub_vcn`, `drg`, `spoke_vcns`, `oci_core_drg_attachment.hub`, `oci_core_drg_attachment.spokes`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `hub_subnet_ids`, `spoke_vcn_ids`, `spoke_subnet_ids`, `drg_attachment_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
