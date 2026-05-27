# Azure Session - Azure OpenAI Gateway Deployment

This folder contains the Azure deployment artifacts for the Azure side of the
`azure-oci-ai-gateway` blueprint.

## What It Deploys

- Azure VNet and delegated Container Apps subnet
- Azure route table associated to the gateway subnet
- Azure network security group associated to the gateway subnet
- Log Analytics workspace
- Azure Container Apps managed environment
- Public Azure Container App running hello-world image
- Azure OpenAI account (and optional model deployment)
- Azure API Management service endpoint

The output `azureHelloWorldEndpoint` is a real public HTTPS endpoint for smoke
checks and demo flows.

## Prerequisites

- Azure CLI logged in (`az login`)
- Correct subscription selected (`az account set --subscription <id>`)
- Environment variables exported for the Ansible wrappers

## Parameters

Start from `parameters.example.json` and copy to a local file (for example
`parameters.dev.json`) with your real names, mail addresses, and tags.

## Outputs To Feed Terraform

Use Azure deployment outputs in Terraform tfvars:

- `azureOpenAiAccountId` -> `azure_openai_account_id`
- `azureOpenAiEndpoint` -> `azure_openai_endpoint`
- `azureApiManagementGatewayUrl` -> `azure_api_management_gateway_url`
- `azureHelloWorldEndpoint` -> `azure_hello_world_endpoint`

You can also store `azureVnetId`, `azureSubnetId`, `azureRouteTableId`, and
`azureNetworkSecurityGroupId` in runbooks and operation hand-off notes.

## Session Commands

```bash
cd blueprints/ai/azure-oci-ai-gateway

export AZURE_AI_GW_RESOURCE_GROUP=rg-oci-azure-ai-gw-dev
export AZURE_AI_GW_LOCATION=westeurope
export AZURE_AI_GW_PARAMETERS_FILE=azure/parameters.example.json

ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```
