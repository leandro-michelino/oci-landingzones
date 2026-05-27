# Azure Session - Hub-Spoke With Azure vWAN ExpressRoute

This folder contains the Azure-side deployment artifacts for
`blueprints/networking/hub-spoke-with-azure-vwan-expressroute`.

## What This Azure Session Deploys

- Azure Virtual WAN and Virtual Hub.
- Virtual Hub route table labelled for OCI transit.
- Optional Virtual WAN ExpressRoute Gateway and ExpressRoute connection.
- Azure VNets connected to the Virtual Hub.
- NSG rules that allow private traffic from OCI hub and spoke CIDRs.

## Inputs To Review

- `ociAddressPrefixes` should include the OCI hub VCN CIDR and every OCI spoke CIDR advertised toward Azure.
- `spokeVnets` should list each Azure VNet, subnet, vHub connection, and OCI spoke mapping.
- `expressRouteCircuitPeeringId` should reference the Azure private peering ID for the ExpressRoute connection.
- Keep `expressRouteAuthorizationKey` in a local parameters file or pipeline secret.

## Outputs To Copy Back Into Terraform

- `azureVirtualWanId`
- `azureVirtualHubId`
- `azureVirtualHubRouteTableId`
- `azureExpressRouteGatewayId`
- `azureExpressRouteConnectionId`
- `azureVnetPeerings`

Use those values in local Terraform variables such as `azure_virtual_wan_id`,
`azure_virtual_hub_id`, `azure_expressroute_gateway_id`, and `azure_vnet_peerings`.

## Run The Azure Session

```bash
cd blueprints/networking/hub-spoke-with-azure-vwan-expressroute
export AZURE_HUB_SPOKE_VWAN_RESOURCE_GROUP=rg-oci-hub-spoke-vwan-dev
export AZURE_HUB_SPOKE_VWAN_LOCATION=westeurope
export AZURE_HUB_SPOKE_VWAN_PARAMETERS_FILE=azure/parameters.local.json

ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```

Simulation mode validates wrapper wiring without calling Azure:

```bash
AZURE_SIMULATE_ONLY=true ansible-playbook -i localhost, ansible/azure-plan.yml
```

## Vinhedo/Campinas Interconnect Test Notes

The latest live test on 2026-05-27 confirmed the pairable ExpressRoute and
FastConnect shape for this Azure session:

- Azure ExpressRoute: `brazilsouth` resources, Oracle Cloud FastConnect
  provider, Campinas peering location, `Local_UnlimitedData`, `1 Gbps`.
- OCI FastConnect: `sa-vinhedo-1`, Microsoft Azure provider service, `1 Gbps`,
  target compartment `Leandro_Michelino`.
- Azure Private Peering should be aligned to the provider-key values returned by
  OCI: peer ASN `31898`, VLAN `33`, primary pair `10.255.0.1/30` and
  `10.255.0.2/30`, secondary pair `10.255.0.5/30` and `10.255.0.6/30`.
- Leave the Azure shared key empty for this provider-key flow.

The Azure vWAN ExpressRoute Gateway reached `Succeeded`, OCI FastConnect reached
`PROVISIONED`, the provider state was `ACTIVE`, BGP was `UP`, and Azure showed
one ExpressRoute Gateway connection. Bidirectional packet testing still needs a
successful temporary VM launch on both sides; the validation run was blocked by
an Azure CLI VM-create runtime error and OCI compute authorization in the target
compartment.
