# Oracle Functions Extension

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/extensions/functions`.
It tells you what the blueprint builds, which inputs deserve a real review, how
to run Terraform or the local Ansible wrappers, and where to find the detailed
ASCII design.

## At A Glance

| Item | Details |
|---|---|
| Folder | `blueprints/extensions/functions` |
| Best fit | OCI-native serverless functions with optional OCIR repository, private application subnet, API Gateway routes, Events triggers, and scoped IAM. |
| Terraform shape | `oci_artifacts_container_repository.this`, `oci_functions_application.this`, `oci_functions_function.this`, `oci_apigateway_gateway.this`, `oci_apigateway_deployment.this`, `oci_events_rule.this`, `oci_identity_policy.access` |
| Inputs to settle first | Compartment, private subnet, NSGs, function image URL, API Gateway exposure, Events trigger conditions, and IAM policy statements. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `container_repository_url`, `functions_app_id`, `function_ids`, `function_invoke_endpoints`, `api_gateway_route_url`, `event_rule_ids`, `access_policy_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys the OCI Functions foundation for a landing zone. The blueprint can create
an Artifact Registry container repository, a Functions application in approved
subnets, one or more functions from OCIR-compatible images, optional API Gateway
routes, optional OCI Events rules that invoke functions, and optional IAM policy
statements for deployers, invokers, and service principals.

## When To Use This Deployment

- Small event-driven code should run without a VM, Container Instance, or OKE
  cluster.
- A private function runtime needs subnet and NSG placement managed with the
  rest of the landing zone.
- API Gateway should expose selected functions as reviewed HTTP routes.
- OCI Events should invoke automation functions for Object Storage, compute,
  monitoring, or governance workflows.
- App teams need a repeatable image, function, route, event, and IAM hand-off.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the
OCI resource graph, while the local Ansible files provide the same
plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_artifacts_container_repository.this` | Optional OCIR-compatible repository for function images. |
| Resource | `oci_functions_application.this` | Optional Functions application attached to supplied subnets and NSGs. |
| Resource | `oci_functions_function.this` | Function resources created from approved container images. |
| Resource | `oci_apigateway_gateway.this` | Optional API Gateway for HTTP ingress. |
| Resource | `oci_apigateway_deployment.this` | Optional API routes that use Oracle Functions backends. |
| Resource | `oci_events_rule.this` | Optional event triggers that invoke functions. |
| Resource | `oci_identity_policy.access` | Optional IAM policy statements for operators and service principals. |

The sample function under `samples/hello-python/` is intentionally small. Use it
to prove the build, push, and Terraform image hand-off path before swapping in a
real workload.

## Folder Contract

```text
blueprints/extensions/functions/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed ASCII architecture for this deployment
|-- main.tf                    Terraform resources
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
|-- samples/
|   `-- hello-python/          Minimal Python FDK image sample
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    `-- destroy.yml            Guarded destroy
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real OCIDs, image URLs, event filters, and policy
statements.

### Base Tenancy And Naming

| Input | What To Decide |
|---|---|
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region name. |
| `home_region` | OCI tenancy home region. |
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `compartment_ocid` | Compartment where Functions, repository, gateway, and event resources are created. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
|---|---|
| `enable_container_repository`, `repository_name`, `repository_display_name` | Whether Terraform creates the image repository and which repository path is used. |
| `enable_application`, `create_application`, `application_id` | Whether Terraform creates the Functions application or uses an existing one. |
| `application_subnet_ids`, `application_network_security_group_ids` | Private runtime placement and NSG controls for Functions. |
| `image_policy_enabled`, `image_policy_kms_key_ids` | Whether signed image enforcement is enabled for the application. |
| `functions` | Function image URL, memory, timeout, config, tracing, concurrency, and async destinations. |
| `enable_api_gateway`, `create_gateway`, `gateway_id`, `gateway_subnet_id` | Whether API Gateway is created or referenced and where it is placed. |
| `enable_api_gateway_deployment`, `default_api_function_key`, `api_routes` | Function-backed HTTP route shape. |
| `enable_event_rules`, `event_rules` | OCI Events conditions and function actions. |
| `policy_statements` | Optional IAM statements for deployers, invokers, Events, API Gateway, and Functions service access. |

### Enable Flags And Switches

All cost-bearing or externally reachable resources are disabled by default where
possible. Turn on only the pieces approved for the target environment.

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks,
customer notes, or manual hand-off. If an output name changes, update dependent
docs and consumers in the same change.

| Output | Hand-Off Meaning |
|---|---|
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created or referenced by this blueprint. |
| `container_repository_id` | Artifact Registry container repository OCID. |
| `container_repository_url` | OCIR-compatible repository URL for image push commands. |
| `functions_app_id` | Created or referenced Functions application OCID. |
| `functions_app_state` | Functions application lifecycle state. |
| `function_ids` | Function OCIDs keyed by logical name. |
| `function_invoke_endpoints` | Function invoke endpoints keyed by logical name. |
| `api_gateway_id` | Created or referenced API Gateway OCID. |
| `api_gateway_deployment_id` | API Gateway deployment OCID. |
| `api_gateway_route_url` | API Gateway route endpoint for function calls. |
| `event_rule_ids` | OCI Events rule OCIDs keyed by logical name. |
| `access_policy_id` | Optional IAM policy OCID. |

## Sample Function

The local sample lives here:

```text
samples/hello-python/
```

Typical flow:

```bash
cd blueprints/extensions/functions/samples/hello-python
export IMAGE_URL="eu-madrid-1.ocir.io/<namespace>/acme-prod-mad-functions/hello-python:0.1.0"
docker build -t "${IMAGE_URL}" .
docker push "${IMAGE_URL}"
```

Then place the same image URL in local `terraform.tfvars` under
`functions.hello.image`. Oracle also maintains a broader
[OCI Functions sample catalog](https://docs.oracle.com/en-us/iaas/Content/Functions/Tasks/functionsdownloadingsamples_topic-Sample_functions.htm)
and [sample repository](https://github.com/oracle-samples/oracle-functions-samples);
use those for larger patterns like API Gateway authorizers, Object Storage
events, Service Connector Hub, and database connectivity.

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/extensions/functions
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across
the repo:

```bash
cd blueprints/extensions/functions
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

This extension supports extension-only and base-plus-extension customer paths.
For extension-only use, supply existing compartment, subnet, NSG, repository,
gateway, event, and IAM values in local tfvars and run this folder directly.
For base-plus-extension use, deploy core and private networking first, then pass
their outputs here.

1. Confirm the target compartment, network/service dependencies, and ownership model.
2. Confirm subnet routing, NSGs, service gateway or NAT behavior, and registry
   access for the function runtime.
3. Build and push the function image to the approved OCIR repository.
4. Populate local ignored tfvars with application, image, route, event, and IAM
   values.
5. Run plan and review the image URL, API exposure, event trigger condition, and
   IAM statements.
6. Apply only after app, platform, and security owners approve the shape.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

## Review Before Apply

- Confirm function images are approved, tagged, and pushed before Terraform
  creates or updates functions.
- Confirm private subnets, route tables, NSGs, and egress paths support the
  runtime destinations.
- Confirm API Gateway endpoint type, subnet, routes, and certificates are
  intentional before exposing HTTP traffic.
- Confirm Events conditions are narrow enough to avoid surprise invocations.
- Confirm IAM policy statements are scoped to the smallest practical
  compartment and principal set.
- Confirm no generated Terraform files, state files, plans, local tfvars, or
  registry credentials are committed.

## Validation

From the repository root:

```bash
./scripts/validate-changed.sh
```

Use `./scripts/validate-all.sh` before release work or broad shared changes.
The validator checks Terraform formatting, required deployment README files,
required architecture README sections, `terraform init -backend=false`,
`terraform validate`, Ansible syntax, optional scanners when installed, and
cleanup of generated Terraform artifacts.
