# Multi-Tenancy Shared Services Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/multi-tenancy-shared-services`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates a hub-spoke shared services network and private DNS view that can serve multiple tenants or workload groups.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/multi-tenancy-shared-services` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates a hub-spoke shared services network and private DNS view that can serve multiple tenants or workload groups. |
| Terraform components | `network`, `shared_dns` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `spoke_vcn_ids`, `private_view_id`, `private_zone_ids` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Multi-Tenancy Shared Services                                                                     |
|                                                                                                  |
|  Tenant/workload spokes                                                                           |
|       | DRG route exchange and DNS queries                                                        |
|       v                                                                                          |
|  +---------------------------- Hub-Spoke Network -----------------------------+                  |
|  | Hub VCN: shared subnet for services, DMZ/firewall subnet options             |                  |
|  | Spoke VCNs: tenant or workload networks                                      |                  |
|  | DRG: centralized connectivity between hub and spokes                         |                  |
|  +-------------------------------+--------------------------------------------+                  |
|                                  |                                                                  |
|                                  v                                                                  |
|  +--------------------------- Shared Private DNS -----------------------------+                  |
|  | Private view named shared                                                   |                  |
|  | Private zones from var.private_zones                                         |                  |
|  | View is attached to hub and spoke VCN resolvers                              |                  |
|  +-------------------------------+--------------------------------------------+                  |
|                                  |                                                                  |
|                                  v                                                                  |
|  Shared services endpoints, private application records, service discovery                          |
|                                                                                                  |
|  Traffic: tenants route to shared services through DRG and resolve shared names through the        |
|  attached private DNS view.                                                                        |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `shared_dns` | `modules/networking/dns @ v0.2.0` |

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

- The hub-spoke network provides shared routing between tenant/workload spokes and the hub shared services subnet.
- Private DNS creates a shared view and zones, then attaches that view to hub and spoke resolvers.
- Tenant workloads reach shared services through DRG routes and resolve service names through the shared private DNS view.
- Review tenant isolation, shared service CIDRs, resolver attachments, and zone ownership before onboarding tenants.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `shared_dns`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `spoke_vcn_ids`, `private_view_id`, `private_zone_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
