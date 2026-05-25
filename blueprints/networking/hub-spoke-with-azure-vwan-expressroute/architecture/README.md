# Hub-Spoke With Azure vWAN ExpressRoute Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for
`blueprints/networking/hub-spoke-with-azure-vwan-expressroute`. It keeps the
Azure Virtual WAN model explicit while preserving the OCI hub-spoke foundation.

## Deployment Purpose

Connect an OCI hub-spoke network to Azure Virtual WAN through Azure ExpressRoute
Gateway and OCI FastConnect, with Azure VNets connected to the Virtual Hub and
mapped to OCI spoke VCNs for route governance.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-azure-vwan-expressroute` owns the OCI Terraform folder and Azure deployment session. |
| Purpose | OCI hub DRG to Azure vWAN/vHub private transit with ExpressRoute Gateway and VNet connections. |
| Terraform components | `network`, `fastconnect`, `ipsec_vpn`, `terraform_data.azure_vwan_contract` |
| Azure components | `Microsoft.Network/virtualWans`, `virtualHubs`, `expressRouteGateways`, `hubVirtualNetworkConnections`, `virtualNetworks`, `networkSecurityGroups` |
| Primary architecture view | The diagram below shows the OCI hub-spoke domain, Azure vWAN domain, and cross-cloud traffic path. |

## Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Hub-Spoke With Azure vWAN ExpressRoute                                                                   |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI]                                                                                          |
|     |                                                                                                    |
|     |-- OCI Terraform runner -> [OCI provider]                                                           |
|     |-- Azure Ansible runner -> [Azure CLI + Bicep deployment]                                           |
|                                                                                                          |
| {OCI network compartment / selected OCI region}                                                          |
|     |                                                                                                    |
|     v                                                                                                    |
| [OCI Hub VCN]                                                                                            |
|     |-- [dmz subnet]                                                                                     |
|     |-- [firewall subnet]                                                                                |
|     |-- [shared subnet]                                                                                  |
|     `-- [gateway set]                                                                                    |
|              |                                                                                           |
|              v                                                                                           |
| [OCI DRG] <-> [hub attachment] <-> [OCI spoke attachments]                                               |
|     |                              |                                                                      |
|     |                              +--> [OCI spoke VCN app1] web -> app -> db                            |
|     |                              +--> [OCI spoke VCN app2] web -> app -> db                            |
|     |                              `--> [future OCI spoke] same attachment contract                       |
|     |                                                                                                    |
|     `--> [OCI FastConnect virtual circuit] <-> (provider / cross-cloud private exchange)                 |
|                                                   |                                                      |
|                                                   v                                                      |
| {Azure subscription / resource group / region}                                                           |
|                                                   |                                                      |
| [Azure ExpressRoute circuit private peering] <-> [Azure vWAN ExpressRoute Gateway]                       |
|                                                   |                                                      |
|                                                   v                                                      |
|                                           [Azure Virtual Hub]                                             |
|                                                   |                                                      |
|                                  [vHub route table: oci-transit]                                         |
|                                                   |                                                      |
|              +------------------------------------+------------------------------------+                |
|              |                                    |                                    |                |
|       [Azure VNet app1]                    [Azure VNet app2]                   [future Azure VNet]       |
|              |                                    |                                    |                |
|       vHub VNet connection                 vHub VNet connection                same connection pattern   |
|                                                                                                          |
| Optional backup: [OCI IPSec] <-> [Azure VPN edge supplied outside or layered later]                      |
| Hand-off: OCI hub/spoke IDs, DRG ID, FastConnect ID, Azure vWAN/vHub/ER Gateway IDs, VNet mappings.      |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | Creates OCI hub VCN, DRG, spoke VCNs, subnets, and DRG attachments. |
| Module | `fastconnect` | Creates OCI FastConnect virtual circuit for Azure ExpressRoute private path. |
| Module | `ipsec_vpn` | Optional backup or test tunnel metadata and OCI IPSec resources. |
| Resource | `terraform_data.azure_vwan_contract` | Captures Azure vWAN, vHub, ExpressRoute Gateway, CIDRs, and spoke-to-VNet mappings. |
| Azure template | `azure/main.bicep` | Creates Azure vWAN/vHub, ExpressRoute Gateway, vHub route table, VNets, NSGs, and vHub VNet connections. |

## Request And Deployment Flow

- Operator reviews OCI and Azure CIDRs, route domains, and ExpressRoute ownership.
- Azure session creates or updates Virtual WAN, Virtual Hub, ExpressRoute Gateway, and Azure VNets.
- OCI Terraform creates the hub-spoke topology and FastConnect resources.
- Azure deployment outputs are copied into local Terraform variables for a complete `azure_vwan_contract`.
- Operators validate BGP route exchange, vHub route table association, and spoke-to-VNet reachability.

## Traffic And Trust Boundaries

- OCI control plane operations use the OCI provider credentials configured for this folder.
- Azure control plane operations use Azure CLI credentials through the shared Azure deployment runner.
- OCI data plane traffic leaves spoke VCNs through the DRG and FastConnect virtual circuit.
- Azure data plane traffic leaves connected VNets through Virtual Hub, ExpressRoute Gateway, and ExpressRoute private peering.
- Trust boundaries are the OCI tenancy, network compartment, VCNs, DRG, Azure subscription, resource group, Virtual Hub, and ExpressRoute circuit.
- Secrets, authorization keys, provider service keys, OCIDs, and customer-specific CIDRs belong in ignored local files or pipeline secrets.

## Detailed Architecture Notes

- OCI remains the hub-spoke owner: the DRG attaches to the hub and each spoke VCN.
- Azure vWAN is explicit: Azure VNets connect to the Virtual Hub instead of being modeled as generic remote CIDRs.
- ExpressRoute Gateway is the Azure transit edge for the private interconnect path.
- FastConnect is the OCI transit edge for the private interconnect path.
- `azure_vnet_peerings` maps Azure VNet CIDRs to OCI spoke keys so runbooks can reason about app-to-app routes.
- `enable_route_contract_validation` can be disabled for early offline plans before real ExpressRoute IDs exist.
- Optional IPSec is kept separate so a customer can add backup connectivity without changing the vWAN contract.

## Operational Boundaries

- Keep the Azure Bicep parameters aligned with Terraform CIDRs before running Azure what-if.
- Run Azure what-if before Azure apply, then copy the Azure output IDs back into Terraform variables.
- Treat Terraform apply, Azure apply, and destroy operations as approval-gated.
- Re-check overlapping CIDRs, route propagation labels, BGP ASN ownership, and ExpressRoute authorization before production route advertisement.
- Update this architecture file whenever `main.tf`, `variables.tf`, `outputs.tf`, or `azure/main.bicep` changes.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `fastconnect`, `ipsec_vpn`, and `terraform_data.azure_vwan_contract`.
- Confirm the diagram matches `azure/main.bicep`: vWAN, vHub, vHub route table, ExpressRoute Gateway, VNet connections, VNets, subnets, and NSGs.
- Confirm OCI hub and spoke CIDRs are advertised to Azure and Azure VNet CIDRs are advertised to OCI.
- Confirm ExpressRoute private peering and FastConnect provider details are paired correctly.
- Confirm Azure vHub route table labels and propagated route settings match the intended route domain.
- Confirm no local tfvars, plan files, provider service keys, or ExpressRoute authorization keys are committed.
