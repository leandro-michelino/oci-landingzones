# Hub-Spoke FastConnect Virtual Circuit Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Adds an OCI FastConnect virtual circuit to the hub-spoke DRG for private on-premises or provider connectivity.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Adds an OCI FastConnect virtual circuit to the hub-spoke DRG for private on-premises or provider connectivity. |
| Terraform components | `network`, `fastconnect` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Hub-Spoke FastConnect Virtual Circuit                                                             |
|                                                                                                  |
|  Customer router / provider edge                                                                  |
|       | private peering, BGP ASN, provider service key                                            |
|       v                                                                                          |
|  +--------------------------- OCI FastConnect ---------------------------+                       |
|  | Virtual Circuit                                                       |                       |
|  | - bandwidth_shape_name and virtual_circuit_type from variables        |                       |
|  | - customer_bgp_asn and provider service details                       |                       |
|  +-------------------------------+---------------------------------------+                       |
|                                  | attaches to DRG                                                |
|                                  v                                                                  |
|  +-------------------------------- DRG ---------------------------------------+                  |
|  | central route exchange between FastConnect, hub VCN, and spokes             |                  |
|  +-------------------------------+--------------------------------------------+                  |
|                                  |                                                                  |
|  +-------------------- Hub VCN --------------------+   +-------------------- Spoke VCNs --------+|
|  | DMZ, firewall, shared, IGW, NAT, SGW             |<->| web/app/db workload tiers             ||
|  +--------------------------------------------------+   +---------------------------------------+|
|                                                                                                  |
|  Traffic: on-prem/private provider routes -> FastConnect VC -> DRG -> hub/spoke CIDRs.            |
|  Control: hub-spoke network exposes drg_id; FastConnect module creates the virtual circuit.        |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `fastconnect` | `modules/networking/fastconnect @ v0.2.0` |

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

- The hub-spoke network exposes the DRG ID, then FastConnect creates a virtual circuit against that DRG.
- Provider service ID, service key, BGP ASN, bandwidth shape, and virtual circuit type define the provider edge relationship.
- On-premises routes enter the DRG through FastConnect and can reach hub or spoke CIDRs depending on route table design.
- Review DRG route tables and customer/provider BGP settings before treating the path as production-ready.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `fastconnect`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
