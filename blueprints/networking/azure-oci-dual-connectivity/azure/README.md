# Azure Session - Dual Connectivity Fallback Edge

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder contains Azure deployment artifacts used by
`blueprints/networking/azure-oci-dual-connectivity`.

## What This Azure Session Deploys

- Azure VNet, workload subnet, route table, and NSG for connectivity edge controls.
- Optional Azure VPN Gateway resources for IPSec fallback path.
- Optional Local Network Gateway + VPN Connection toward OCI CPE endpoint.

The OCI side remains primary and is available by Terraform in the parent
blueprint folder.

## Required Inputs

- `ociCpePublicIp` as the OCI fallback tunnel endpoint public IP.
- `ociAddressPrefixes` as OCI CIDRs advertised toward Azure.
- `fallbackSharedKey` as the tunnel shared key.

## Outputs To Pair With Terraform Contracts

- `azureWorkloadVnetId`, `azureWorkloadSubnetId`, `azureRouteTableId`, `azureNetworkSecurityGroupId`
- `azureVpnGatewayId`, `azureVpnConnectionId`, `azureVpnGatewayPublicIp`

Use these values with Terraform outputs from the parent blueprint for runbook
handoff and route troubleshooting.

## Run The Azure Session

```bash
cd blueprints/networking/azure-oci-dual-connectivity
export AZURE_CONNECTIVITY_RESOURCE_GROUP=rg-oci-azure-connectivity-dev
export AZURE_CONNECTIVITY_LOCATION=westeurope
export AZURE_CONNECTIVITY_DEPLOYMENT_NAME=oci-azure-connectivity-whatif

ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```

For simulation-only checks without cloud-side execution:

```bash
AZURE_SIMULATE_ONLY=true ansible-playbook -i localhost, ansible/azure-plan.yml
```
