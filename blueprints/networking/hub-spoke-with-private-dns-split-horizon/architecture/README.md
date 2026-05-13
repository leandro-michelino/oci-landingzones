# Hub-Spoke Private DNS Split Horizon Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/hub-spoke-with-private-dns-split-horizon`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Adds private DNS zones, a private view, and resolver attachments across the hub and spoke VCNs.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-private-dns-split-horizon` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Adds private DNS zones, a private view, and resolver attachments across the hub and spoke VCNs. |
| Terraform components | `network`, `private_dns` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `spoke_vcn_ids`, `private_view_id`, `private_zone_ids`, `vcn_resolver_ids` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Hub-Spoke Private DNS Split Horizon                                                               |
|                                                                                                  |
|  Workloads in hub and spoke VCNs                                                                  |
|       | DNS query for private zone names                                                          |
|       v                                                                                          |
|  +---------------------------- VCN DNS Resolvers -----------------------------+                 |
|  | Hub resolver and each spoke resolver                                        |                 |
|  | Resolver IDs come from the created hub/spoke network                        |                 |
|  +-------------------------------+---------------------------------------------+                 |
|                                  | private view attachment                                       |
|                                  v                                                                  |
|  +---------------------------- OCI Private DNS -------------------------------+                 |
|  | Private view                                                              |                 |
|  | Private zones from var.private_zones                                       |                 |
|  | attach_private_view_to_vcn_resolvers controls resolver associations         |                 |
|  +-------------------------------+---------------------------------------------+                 |
|                                  | answer differs from public DNS                                 |
|                                  v                                                                  |
|  Private service endpoints, shared services, and spoke workloads                                   |
|                                                                                                  |
|  Traffic: workload -> VCN resolver -> private view/zone -> private IP target in hub or spoke.      |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `private_dns` | `modules/networking/dns @ v0.2.0` |

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

- The hub-spoke network creates VCN resolvers first, then private DNS creates zones and a private view.
- attach_private_view_to_vcn_resolvers controls whether the view is associated with hub and spoke resolvers.
- Workloads resolve private names through their VCN resolver and receive answers from the attached private view.
- Review split-horizon records, zone ownership, resolver attachments, and any on-premises forwarding design before apply.

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
|-- spoke_vcn_ids
|-- private_view_id
|-- private_zone_ids
`-- vcn_resolver_ids
```


## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `private_dns`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `spoke_vcn_ids`, `private_view_id`, `private_zone_ids`, `vcn_resolver_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
