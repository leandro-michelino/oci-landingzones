# Azure Session - DR Standby Deployment

This folder contains the Azure standby deployment artifacts for the
`azure-oci-cross-cloud-dr` blueprint.

## What It Deploys

- Azure VNet and delegated Container Apps subnet
- Azure route table associated to the standby subnet
- Azure network security group associated to the standby subnet
- Log Analytics workspace
- Azure Container Apps managed environment
- Public Azure Container App running hello-world image

The output `azureStandbyEndpoint` is a real public HTTPS endpoint that can be
used as the standby target in DNS failover drills.

## Prerequisites

- Azure CLI logged in (`az login`)
- Correct subscription selected (`az account set --subscription <id>`)
- Environment variables exported for the Ansible wrappers

## Parameters

Start from `parameters.example.json` and copy to a local file (for example
`parameters.dev.json`) with your real names and tags.

## Outputs To Feed Terraform

Use Azure deployment output in Terraform tfvars:

- `azureStandbyEndpoint` -> `azure_standby_endpoint`
- `standbyVnetId`, `standbySubnetId`, `standbyRouteTableId`, and
  `standbyNetworkSecurityGroupId` for network operations and DR runbooks.

## Session Commands

```bash
cd blueprints/disaster-recovery/azure-oci-cross-cloud-dr

export AZURE_DR_RESOURCE_GROUP=rg-oci-azure-dr-standby-dev
export AZURE_DR_LOCATION=westeurope
export AZURE_DR_PARAMETERS_FILE=azure/parameters.example.json

ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```
