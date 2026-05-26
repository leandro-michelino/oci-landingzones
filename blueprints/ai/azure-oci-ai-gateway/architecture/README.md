# Azure + OCI AI Gateway Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for
`blueprints/ai/azure-oci-ai-gateway`. It is intentionally Architecture-first so
it is easy to review in GitHub, terminals, pull requests, runbooks, and
customer notes without a diagramming tool.

## Deployment Purpose

Implements a multi-provider AI gateway across OCI Generative AI and Azure
OpenAI with explicit routing policies for region, cost, and data residency.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/ai/azure-oci-ai-gateway` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Build OCI gateway infrastructure and route contracts while supporting full Azure deployment sessions for OpenAI and API gateway endpoints. |
| Terraform components | `oci_core_vcn.gateway`, `oci_core_route_table.gateway`, `oci_core_security_list.gateway`, `oci_core_subnet.gateway`, `oci_apigateway_gateway.this`, `oci_apigateway_deployment.this`, `oci_apigateway_usage_plan.this`, `oci_objectstorage_namespace.this`, `oci_objectstorage_bucket.audit`, `oci_logging_log_group.routing`, `terraform_data.connectivity_contract`, `terraform_data.routing_contract`, `terraform_data.azure_contract` |
| Primary architecture view | The Architecture diagram below shows OCI and Azure boundaries, control flow, and policy route outcomes for this deployment. |

## Architecture

```text
+----------------------------------------------------------------------------------------------------------------+
| Azure + OCI AI Gateway                                                                                         |
+----------------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow                     |
|                                                                                                                |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                                |
|         |                    |                         |                                                       |
|         | validates docs      | init/validate/plan      | OCI API calls                                        |
|         v                    v                         v                                                       |
| {OCI cloud boundary}                                                                                           |
|   |                                                                                                            |
|   |-- [Gateway VCN + route table + security list + subnet]                                                    |
|   |-- [OCI API Gateway]                                                                                        |
|   |      |-- /ai/providers/oci            -> OCI Generative AI backend URL                                    |
|   |      |-- /ai/providers/azure          -> Azure OpenAI backend URL                                         |
|   |      |-- /ai/route/region             -> selected provider for region policy                              |
|   |      |-- /ai/route/cost               -> selected provider for cost policy                                |
|   |      `-- /ai/route/data-residency     -> selected provider for residency policy                           |
|   |-- [Usage plans and quotas]                                                                                |
|   |-- [Audit bucket]                                                                                           |
|   `-- [Routing log group + IAM policy + terraform_data contracts]                                              |
|          |-- connectivity contract: interconnect or without-interconnect                                       |
|          |-- routing contract: region/cost/residency provider decisions                                        |
|          `-- azure contract: OpenAI/APIM/hello endpoint metadata                                               |
|                                                                                                                |
| {Azure cloud boundary}                                                                                         |
|   |                                                                                                            |
|   |-- [VNet + subnet + route table + NSG]                                                                     |
|   |-- [Azure OpenAI account (+ optional model deployment)]                                                     |
|   |-- [API Management gateway endpoint]                                                                        |
|   `-- [Container App hello-world endpoint]                                                                     |
|                                                                                                                |
| [Client app] -> [OCI API Gateway] -> [Selected provider backend by route policy]                               |
|                                                                                                                |
| Connectivity context:                                                                                          |
|   interconnect mode     => FastConnect + ExpressRoute identifiers required                                     |
|   without-interconnect  => identifiers intentionally unset                                                     |
+----------------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.gateway`, `oci_core_route_table.gateway`, `oci_core_security_list.gateway`, `oci_core_subnet.gateway` | Deploy-and-use OCI network stack for gateway routing and ingress controls. |
| Resource | `oci_apigateway_gateway.this` | OCI API Gateway front door for AI traffic. |
| Resource | `oci_apigateway_deployment.this` | Deploys provider and policy routes for region/cost/residency steering. |
| Resource | `oci_apigateway_usage_plan.this` | Optional quota/rate controls for caller teams. |
| Data source | `oci_objectstorage_namespace.this` | Reads namespace for audit bucket creation. |
| Resource | `oci_objectstorage_bucket.audit` | Stores audit and runbook artifacts. |
| Resource | `oci_logging_log_group.routing` | Stores routing logs and operational events. |
| Resource | `oci_identity_policy.access` | Grants gateway and audit access by policy statements. |
| Resource | `terraform_data.connectivity_contract` | Encodes interconnect versus no-interconnect operating mode. |
| Resource | `terraform_data.routing_contract` | Encodes route decisions and residency metadata. |
| Resource | `terraform_data.azure_contract` | Stores Azure-side hand-off metadata for operations. |

## Request And Deployment Flow

- Operator runs Azure deployment sessions first to create OpenAI/APIM and gather endpoint outputs.
- Operator places Azure outputs and OCI backend URLs in local Terraform tfvars.
- Terraform creates OCI network, gateway resources, and route deployment.
- Terraform validates connectivity-mode and endpoint requirements using preconditions.
- Outputs publish route map, connectivity details, provider endpoint metadata, and Azure hand-off values.

## Traffic And Trust Boundaries

- Control plane traffic uses local or CI credentials for Azure CLI and OCI provider operations.
- Data plane traffic enters OCI API Gateway and then exits to OCI Generative AI or Azure OpenAI based on selected route path.
- Trust boundaries include OCI tenancy, Azure subscription boundary, and optional partner interconnect boundary.
- Secrets and private identifiers must remain in ignored local tfvars or approved secret stores.

## Detailed Architecture Notes

These notes expand the diagram with design details usually needed in reviews.

- The route pattern is explicit by path so consumers can deterministically choose policy outcomes.
- `routing_strategy_region_provider`, `routing_strategy_cost_provider`, and `routing_strategy_data_residency_provider` control which backend URL each policy path targets.
- `require_provider_endpoints=true` enforces real backend URLs before route deployment.
- Connectivity mode is modeled as a contract output and enforced by validation rules.
- OCI network resources are deploy-and-use and include route table plus security list wiring.
- Azure sessions deploy network resources, OpenAI account, API Management endpoint, and a real public hello-world endpoint.
- The local hello-world page is included for runbook rehearsals and smoke checks without requiring cloud traffic generation.
- OCI API Gateway HTTP backends should use only the scheme, host, and path.
  Query strings such as Azure OpenAI `api-version` belong on client requests,
  not in the backend URL, because OCI API Gateway rejects backend URLs with
  invalid query/path composition.
- End-to-end route validation can use expected provider auth responses. An
  Azure OpenAI `401` or OCI Generative AI `NotAuthorizedOrNotFound` response
  through the OCI Gateway proves the route reached the intended provider when
  provider credentials are intentionally not injected into the gateway.

## Operational Boundaries

- This blueprint can run extension-only with supplied IDs and endpoints or after base landing-zone blueprints.
- Apply and destroy are approval-gated actions; use guarded Ansible wrappers.
- Keep customer-specific OCIDs, backend URLs, keys, and contact details outside committed files.
- Review route policy mappings whenever cost, sovereignty, or region priorities change.
- Re-run validation scripts after changing route definitions, policy statements, or Azure template structure.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_core_vcn.gateway`, `oci_core_route_table.gateway`, `oci_core_security_list.gateway`, `oci_core_subnet.gateway`, `oci_apigateway_gateway.this`, `oci_apigateway_deployment.this`, `oci_apigateway_usage_plan.this`, `oci_objectstorage_namespace.this`, `oci_objectstorage_bucket.audit`, `oci_logging_log_group.routing`, `terraform_data.connectivity_contract`, `terraform_data.routing_contract`, `terraform_data.azure_contract`.
- Confirm connectivity mode and circuit IDs align with the intended operating model.
- Confirm provider backend URLs are real endpoints and TLS requirements are understood.
- Confirm route policy-to-provider mapping for region, cost, and data residency is intentional.
- Confirm OCI gateway exposure model and ingress CIDR values meet security requirements.
- Confirm Azure deployment outputs are captured and mirrored into Terraform inputs.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, `ansible/destroy.yml`, and `ansible/azure-*.yml` still point to the shared runners.
