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
