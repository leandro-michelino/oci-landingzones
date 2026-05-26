# Azure Session - AKS Secondary Deployment

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder contains the Azure deployment artifacts for the AKS secondary side
of the `aks-oke-active-passive` blueprint.

## What It Deploys

- Azure VNet and AKS subnet
- Azure route table associated to AKS subnet
- Azure network security group associated to AKS subnet
- `Microsoft.ContainerService/managedClusters` AKS cluster
- System node pool
- Control-plane endpoint and cluster ID outputs

## Prerequisites

- Azure CLI logged in (`az login`)
- Correct subscription selected (`az account set --subscription <id>`)
- Environment variables exported for the Ansible wrappers
- AKS Kubernetes version verified in the target region before apply

## Parameters

Start from `parameters.example.json` and copy to a local file (for example
`parameters.dev.json`) with your real values.
Keep `kubernetesVersion` on the latest minor version that is also supported by
the paired OKE region. The example remains `1.36` as the intended baseline;
override both AKS and OKE to the newest common supported minor version if a
region has not exposed `1.36` yet.

## Outputs To Feed Terraform

Use the Azure outputs from deployment and map them into Terraform tfvars:

- `aksClusterId` -> `aks_cluster_id`
- `aksClusterName` -> `aks_cluster_name`
- `aksVnetId`, `aksSubnetId`, `aksRouteTableId`, and `aksNetworkSecurityGroupId`
  as network hand-off IDs for operations and runbooks.

You can derive `aks_resource_group_name` from the RG used by the Azure session.

## Session Commands

```bash
cd blueprints/extensions/aks-oke-active-passive

export AZURE_AKS_RESOURCE_GROUP=rg-aks-oci-secondary-dev
export AZURE_AKS_LOCATION=westeurope
export AZURE_AKS_PARAMETERS_FILE=azure/parameters.example.json

ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```
