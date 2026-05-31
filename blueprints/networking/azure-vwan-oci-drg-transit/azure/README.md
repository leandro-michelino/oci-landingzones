# Azure Session - vWAN + DRG Transit

This folder contains Azure artifacts used by
`blueprints/networking/azure-vwan-oci-drg-transit`.

## What This Azure Session Creates

- Azure Virtual WAN and Virtual Hub resources for transit aggregation.
- Azure vHub route table and VNet connection for route-domain policy.
- Azure VNet, workload subnet, NSG, and route table for transit edge controls.
- Optional Azure VPN Gateway resources for IPSec fallback path.
- Optional Local Network Gateway and VPN Connection toward OCI CPE endpoint.

The OCI side remains primary and is created by Terraform in the parent
blueprint folder.

## Required Inputs

- `ociCpePublicIp` as OCI fallback tunnel endpoint public IP.
- `ociAddressPrefixes` as OCI CIDRs advertised toward Azure.
- `fallbackSharedKey` as tunnel shared key.

## Input Guardrails

- Keep `virtualHubAddressPrefix` outside the VNet CIDR range. Example:
  `virtualHubAddressPrefix=10.89.255.0/24` with `vnetCidr=10.88.0.0/16`.
- For Azure plus OCI fallback interoperability, keep `fallbackSharedKey`
  alphanumeric only (letters and numbers) so the same key can be applied on OCI
  tunnel PSKs.

## Outputs To Pair With Terraform Contracts

- `azureVirtualWanId`, `azureVirtualHubId`, `azureVirtualHubRouteTableId`, `azureVirtualHubConnectionId`
- `azureWorkloadVnetId`, `azureWorkloadSubnetId`, `azureWorkloadRouteTableId`, `azureNetworkSecurityGroupId`
- `azureVpnGatewayId`, `azureVpnConnectionId`, `azureVpnGatewayPublicIp`

Use these values with Terraform outputs from the parent blueprint for runbook
handoff and route troubleshooting.

## Run The Azure Session

```bash
cd blueprints/networking/azure-vwan-oci-drg-transit
export AZURE_VWAN_TRANSIT_RESOURCE_GROUP=rg-oci-azure-vwan-transit-dev
export AZURE_VWAN_TRANSIT_LOCATION=brazilsouth
export AZURE_VWAN_TRANSIT_DEPLOYMENT_NAME=oci-azure-vwan-transit-whatif

ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```

After `azure-destroy.yml`, wait for resource-group deletion to finish before
declaring cleanup complete:

```bash
az group show -n "$AZURE_VWAN_TRANSIT_RESOURCE_GROUP" --query "properties.provisioningState" -o tsv
az group wait --name "$AZURE_VWAN_TRANSIT_RESOURCE_GROUP" --deleted
```

For simulation-only checks without cloud-side execution:

```bash
AZURE_SIMULATE_ONLY=true ansible-playbook -i localhost, ansible/azure-plan.yml
```
