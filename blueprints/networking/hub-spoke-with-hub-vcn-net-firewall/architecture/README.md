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


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Hub-Spoke OCI Network Firewall                                                                           |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Network compartment / selected region}                                                                  |
|         |                                                                                                |
|         v                                                                                                |
| [Hub VCN]                                                                                                |
|         |-- [dmz subnet]      -> public ingress/egress only when approved                                |
|         |-- [firewall subnet] -> inspection or appliance insertion point                                 |
|         |-- [shared subnet]   -> shared services, endpoints, DNS, or bastion                             |
|         `-- [gateway set]     -> IGW / NAT / SGW according to route design                               |
|                  |                                                                                       |
|                  v                                                                                       |
| [DRG] <-> [hub attachment] <-> [spoke attachments]                                                       |
|   |             |                    |                                                                   |
|   |             |                    +--> [spoke VCN A] web -> app -> db                                 |
|   |             |                    +--> [spoke VCN B] web -> app -> db                                 |
|   |             |                    `--> [future spoke] same attachment contract                        |
|   |                                                                                                      |
|   `--> [OCI Network Firewall] -> firewall policy -> inspected north-south/east-west paths                |
|                                                                                                          |
| Pattern extension: firewall subnet and policy become the approved inspection point.                      |
| North-south: external or service traffic enters the hub, then routes through DRG attachments to spokes.  |
| East-west: spoke-to-spoke traffic centralizes through the DRG and any hub inspection controls.           |
| Hand-off: hub/spoke VCN IDs, DRG IDs, attachment IDs, subnet maps, route targets, and service edge IDs.  |
+----------------------------------------------------------------------------------------------------------+
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
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
