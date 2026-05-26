# Azure + OCI AI Gateway

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/ai/azure-oci-ai-gateway`.
It tells you what the blueprint builds, which inputs deserve a real review, how
to run Terraform or the local Ansible wrappers, and where to find the detailed
Architecture design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/ai/azure-oci-ai-gateway` |
| Best fit | End-to-end Azure + OCI AI gateway where OCI API Gateway routes requests to OCI Generative AI and Azure OpenAI by region, cost, or data residency policy. |
| Terraform shape | `oci_core_vcn.gateway`, `oci_core_route_table.gateway`, `oci_core_security_list.gateway`, `oci_core_subnet.gateway`, `oci_apigateway_gateway.this`, `oci_apigateway_deployment.this`, `oci_apigateway_usage_plan.this`, `oci_objectstorage_bucket.audit`, `oci_logging_log_group.routing`, `terraform_data.connectivity_contract`, `terraform_data.routing_contract`, `terraform_data.azure_contract` |
| Inputs to settle first | `connectivity_mode`, `fastconnect_virtual_circuit_id`, `expressroute_circuit_id`, `oci_generative_ai_inference_url`, `azure_openai_inference_url`, `routing_strategy_region_provider`, `routing_strategy_cost_provider`, `routing_strategy_data_residency_provider`, `azure_openai_endpoint` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `oci_network_contract`, `connectivity_contract`, `routing_contract`, `gateway_route_map`, `provider_endpoints`, `azure_contract` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Implements a full Azure + OCI AI gateway pattern with deploy-and-use OCI
networking, OCI API Gateway route wiring, Azure OpenAI and API Management
deployment sessions, and explicit routing contracts for region, cost, and data
residency decisions.

## When To Use This Deployment

- You need one routing front door across OCI Generative AI and Azure OpenAI.
- Platform teams need policy-driven routing decisions by region, cost, and
  data residency.
- Cross-cloud connectivity context must support either partner interconnect or
  explicit no-interconnect mode.
- You want both Terraform and Azure deployment sessions in one operator folder.

## Practical Use Cases

This blueprint is a good fit when the business wants AI choices without making
every application team learn every provider integration detail. It gives teams a
single gateway contract, then lets the platform route requests to OCI Generative
AI or Azure OpenAI based on policy.

Examples:

- **Regional AI front door:** route Madrid or EU workloads to OCI Generative AI
  while keeping an Azure OpenAI route available for teams that already use an
  Azure model family.
- **Cost-aware model routing:** send everyday summarization or extraction
  traffic to the cheaper approved provider, while reserving a premium model path
  for regulated or customer-facing workflows.
- **Data residency control:** keep sensitive prompts on the provider and region
  approved by governance, with the routing choice documented in Terraform
  outputs instead of buried in application code.
- **AI platform migration:** expose the same `/chat`, `/embed`, or
  `/summarize` style gateway route while moving workloads gradually from one AI
  backend to another.
- **Demo and enablement lab:** use the hello-world app and gateway route map to
  show developers how cross-cloud AI routing works before wiring production
  models.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the
OCI resource graph and cross-cloud contracts, while local Ansible files provide
a consistent plan/apply/destroy rhythm for OCI and Azure.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.gateway`, `oci_core_route_table.gateway`, `oci_core_security_list.gateway`, `oci_core_subnet.gateway` | Optional deploy-and-use OCI network stack for API Gateway placement and traffic controls. |
| Resource | `oci_apigateway_gateway.this` | Optional OCI API Gateway front door. |
| Resource | `oci_apigateway_deployment.this` | Optional route deployment for provider routes and policy routes. |
| Resource | `oci_apigateway_usage_plan.this` | Optional per-team rate and quota governance. |
| Resource | `oci_objectstorage_bucket.audit` | Optional routing evidence and audit artifact bucket. |
| Resource | `oci_logging_log_group.routing` | Optional OCI routing log group. |
| Resource | `oci_identity_policy.access` | Optional access policy for operators and callers. |
| Resource | `terraform_data.connectivity_contract` | Interconnect or no-interconnect connectivity contract. |
| Resource | `terraform_data.routing_contract` | Policy contract for region/cost/data-residency routing. |
| Resource | `terraform_data.azure_contract` | Azure-side metadata hand-off contract. |

The exact behavior is controlled by `variables.tf` and values supplied in your
local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/ai/azure-oci-ai-gateway/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
|-- main.tf                    Terraform resources and contracts
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
|-- hello-world/index.html     Sample AI gateway app page for demos and smoke tests
|-- azure/
|   |-- main.bicep             Azure OpenAI + API Management deployment template
|   |-- parameters.example.json Example Azure deployment parameters
|   `-- README.md              Azure session guide
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    |-- destroy.yml            Guarded destroy
    |-- azure-plan.yml         Azure what-if session for AI gateway side
    |-- azure-apply.yml        Azure apply session for AI gateway side
    |-- azure-destroy.yml      Azure destroy session for AI gateway side
    |-- serve-hello-world.yml  Start local hello-world endpoint
    `-- stop-hello-world.yml   Stop local hello-world endpoint
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real IDs, endpoint URLs, routing decisions, and enable
flags.

### Base Tenancy And Naming

| Input | What To Decide |
| --- | --- |
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region name. |
| `home_region` | OCI tenancy home region. |
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `enable_oci_gateway_network` | Create OCI VCN, subnet, route table, and security list for the gateway. |
| `oci_gateway_vcn_cidr` | CIDR for OCI gateway VCN. |
| `oci_gateway_subnet_cidr` | CIDR for OCI gateway subnet. |
| `oci_gateway_ingress_allowed_cidr` | Allowed source CIDR for gateway ingress (80/443). |
| `connectivity_mode` | Select `interconnect` or `without-interconnect`. |
| `fastconnect_virtual_circuit_id` | FastConnect virtual circuit OCID for interconnect mode. |
| `expressroute_circuit_id` | ExpressRoute circuit ID for interconnect mode. |
| `create_oci_api_gateway` | Create OCI API Gateway front door. |
| `oci_gateway_endpoint_type` | `PUBLIC` for internet-facing gateway or `PRIVATE` for internal-only exposure. |
| `create_oci_gateway_deployment` | Create routes under `gateway_path_prefix`. |
| `oci_generative_ai_inference_url` | OCI backend inference URL. |
| `azure_openai_inference_url` | Azure backend inference URL. |
| `routing_strategy_region_provider` | Route target for region strategy (`oci` or `azure`). |
| `routing_strategy_cost_provider` | Route target for cost strategy (`oci` or `azure`). |
| `routing_strategy_data_residency_provider` | Route target for residency strategy (`oci` or `azure`). |
| `require_provider_endpoints` | Keep true to force real backend URLs before deployment. |
| `create_oci_usage_plans` and `usage_plans` | Optional quota and rate policy map for caller groups. |
| `create_oci_audit_bucket` | Create private evidence bucket for gateway and policy artifacts. |
| `create_oci_routing_log_group` | Create log group for routing events. |
| `policy_statements` | IAM statements for gateway operators, callers, and auditors. |
| `azure_openai_account_id`, `azure_openai_endpoint`, `azure_api_management_gateway_url`, `azure_hello_world_endpoint` | Azure outputs hand-off from `azure/main.bicep` sessions. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks,
customer notes, or manual hand-off. If an output name changes, update dependent
docs and consumers in the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of OCI resource IDs and contract IDs produced by this deployment. |
| `oci_network_contract` | OCI network IDs and enable flags for operations hand-off. |
| `connectivity_contract` | Interconnect mode contract with circuit identifiers. |
| `routing_contract` | Policy route selections and residency metadata. |
| `provider_endpoints` | Raw OCI and Azure backend endpoint URLs configured for routing. |
| `gateway_route_map` | Concrete path map for provider and strategy routes. |
| `oci_gateway_id` | OCI API Gateway OCID. |
| `oci_gateway_deployment_id` | OCI API Gateway deployment OCID. |
| `oci_usage_plan_ids` | OCI usage plan IDs keyed by logical team name. |
| `oci_audit_bucket_name` | OCI audit bucket name. |
| `oci_routing_log_group_id` | OCI logging log group ID. |
| `oci_access_policy_id` | OCI IAM policy ID for gateway governance. |
| `azure_contract` | Azure deployment metadata consumed by this blueprint. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/ai/azure-oci-ai-gateway
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across
the repo:

```bash
cd blueprints/ai/azure-oci-ai-gateway
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded.

Azure full deployment session (Azure OpenAI + API Management + hello-world app):

```bash
cd blueprints/ai/azure-oci-ai-gateway
az provider register --namespace Microsoft.CognitiveServices --wait
az provider register --namespace Microsoft.ApiManagement --wait
ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```

For required Azure variables and parameters, review `azure/README.md`.
Azure session playbooks use the shared role
`ansible/roles/azure_deployment_runner` for consistent behavior.

To run the real local hello-world endpoint for this blueprint:

```bash
cd blueprints/ai/azure-oci-ai-gateway
ansible-playbook -i localhost, ansible/serve-hello-world.yml
# open http://127.0.0.1:18082
ansible-playbook -i localhost, ansible/stop-hello-world.yml
```

## Deployment Order

This extension supports extension-only and base-plus-extension customer paths.
For extension-only use, supply existing compartment, networking, gateway, and
endpoint values in local tfvars and run this folder directly. For
base-plus-extension use, deploy core and networking first, then pass outputs
here.

1. Confirm connectivity mode ownership and interconnect lifecycle responsibilities.
2. Run Azure deployment sessions and collect Azure output values.
3. Populate `terraform.tfvars` with OCI IDs, backend endpoint URLs, and routing strategy choices.
4. Run plan and review route map plus policy contract outputs.
5. Apply only after platform, security, and operations owners approve route behavior and access policy.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow,
traffic boundaries, detailed notes, and review checklist expected for this
blueprint.

## Review Before Apply

- Confirm connectivity mode and corresponding circuit values are intentional.
- Confirm OCI and Azure backend endpoints are real and reachable.
- Confirm route policies for region, cost, and data residency map to intended providers.
- Confirm OCI API Gateway exposure (`PUBLIC` or `PRIVATE`) matches the security model.
- Confirm Azure session outputs were copied into local tfvars correctly.
- Keep provider backend URLs free of query strings in gateway backend config.
  For Azure OpenAI, pass `api-version` on client calls instead of baking it
  into the OCI API Gateway backend URL.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## E2E Smoke Evidence

A real E2E smoke run should prove both cloud sides before teardown:

1. Azure what-if and apply complete in a region with capacity for Container Apps,
   Azure OpenAI, and API Management.
2. Azure Container Apps hello-world endpoint returns HTTP `200`.
3. Azure OpenAI account is `Succeeded`; APIM is `Succeeded`.
4. OCI Terraform plan and apply create API Gateway, API deployment, network,
   audit bucket, routing log group, and contracts.
5. OCI API deployment endpoint is `ACTIVE`.
6. Route samples reach the expected backend:
   - `/ai/providers/azure` and `/ai/route/cost` should return an Azure OpenAI
     response such as `401` when provider credentials are intentionally absent.
   - `/ai/providers/oci`, `/ai/route/region`, and
     `/ai/route/data-residency` should return an OCI Generative AI response
     such as `NotAuthorizedOrNotFound` when request signing/provider auth is
     intentionally absent.

Sample route check:

```bash
BASE="https://<deployment-host>.apigateway.<region>.oci.customer-oci.com/ai"
curl -sS -D /tmp/aigw.headers -o /tmp/aigw.body \
  -w 'http=%{http_code}\n' \
  -H 'content-type: application/json' \
  -X POST "$BASE/providers/azure?api-version=2024-10-21" \
  --data '{"messages":[{"role":"user","content":"hello from e2e"}],"max_tokens":8}'
```

When `deployOpenAiModel=false`, direct Azure OpenAI chat-completion samples may
return `DeploymentNotFound`; that still validates account reachability, but not
model inference. Enable a model deployment only when regional model quota is
available and the test owner accepts the cost.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files,
required architecture README sections, `terraform init -backend=false`,
`terraform validate`, root Ansible syntax, blueprint-local Ansible syntax,
optional scanners when installed, and cleanup of generated Terraform artifacts.
