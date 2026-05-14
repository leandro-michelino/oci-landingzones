# Oracle Functions Extension Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/functions`.
It is intentionally ASCII-first so it is easy to review in GitHub, terminals,
pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys an OCI Functions extension with optional image repository, private
Functions application, function resources, API Gateway routes, Events triggers,
and scoped IAM policy hand-offs.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/extensions/functions` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Runs OCI-native serverless functions from approved container images, with optional HTTP and event-driven invocation paths. |
| Terraform components | `oci_artifacts_container_repository.this`, `oci_functions_application.this`, `oci_functions_function.this`, `oci_apigateway_gateway.this`, `oci_apigateway_deployment.this`, `oci_events_rule.this`, `oci_identity_policy.access` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and invocation paths for this exact deployment. |

## ASCII Architecture

```text
+------------------------------------------------------------------------------------------------------------------+
| Oracle Functions Extension                                                                                        |
+------------------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow                         |
|                                                                                                                  |
| [Operator / CI]                                                                                                  |
|      |                                                                                                           |
|      | terraform plan/apply or guarded Ansible runner                                                            |
|      v                                                                                                           |
| [Terraform OCI provider]                                                                                         |
|      |                                                                                                           |
|      +--> [Artifact Registry container repository, optional]                                                      |
|      |        |-- repository path: <region>.ocir.io/<namespace>/<name-prefix>/<repository_name>                  |
|      |        |-- mutable or immutable tags by input                                                             |
|      |        `-- image README metadata when supplied                                                            |
|      |                                                                                                           |
|      +--> (function image built outside Terraform)                                                               |
|      |        |                                                                                                  |
|      |        +--> sample: samples/hello-python/                                                                 |
|      |        |       |-- Python FDK handler                                                                       |
|      |        |       |-- Dockerfile based on Fn Python images                                                       |
|      |        |       `-- pushed to OCIR before function create/update                                         |
|      |        |                                                                                                  |
|      |        `--> [Function image tag and optional digest]                                                       |
|      |                                                                                                           |
|      +--> {application compartment}                                                                              |
|      |        |                                                                                                  |
|      |        +--> (private subnet IDs)                                                                          |
|      |        |        |                                                                                         |
|      |        |        +--> [Functions application]                                                             |
|      |        |        |       |-- optional NSGs                                                                      |
|      |        |        |       |-- optional application config                                                          |
|      |        |        |       |-- optional signed image policy                                                         |
|      |        |        |       `-- optional tracing and syslog                                                     |
|      |        |        |                                                                                         |
|      |        |        `--> [OCI Functions]                                                                  |
|      |        |                |-- image URL required for each function                                                  |
|      |        |                |-- memory and timeout per function                                                       |
|      |        |                |-- optional provisioned concurrency                                                       |
|      |        |                |-- optional success or failure destinations                                               |
|      |        |                `-- invoke endpoint output                                                            |
|      |        |                                                                                                  |
|      |        +--> [API Gateway, optional]                                                                       |
|      |        |       |-- private or public endpoint type                                                       |
|      |        |       |-- subnet, NSGs, optional certificate                                                     |
|      |        |       `-- [API deployment] -> ORACLE_FUNCTIONS_BACKEND -> [OCI Function]                    |
|      |        |                                                                                                  |
|      |        +--> [OCI Events rules, optional]                                                                  |
|      |        |       |-- event condition from local tfvars                                                      |
|      |        |       `-- FAAS action -> [OCI Function]                                                   |
|      |        |                                                                                                  |
|      |        `--> [IAM access policy, optional]                                                                 |
|      |                |-- deployer and invoker groups                                                           |
|      |                |-- Functions service network access                                                       |
|      |                |-- Events and API Gateway invoke permissions where required                               |
|      |                `-- OCIR repository permissions                                                            |
|      |                                                                                                           |
| HTTP path: client -> API Gateway route -> Oracle Functions backend -> selected function.                         |
| Event path: OCI service event -> Events rule condition -> FAAS action -> selected function.                      |
| Image path: local build or CI -> OCIR repository -> Functions application pulls approved image.                  |
| Control path: Terraform creates repository, application, functions, routes, event rules, and policies.           |
| Hand-off: repository URL, application ID, function IDs/endpoints, route URL, event rule IDs, policy ID.          |
+------------------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_artifacts_container_repository.this` | Optional image repository for the function image hand-off. |
| Resource | `oci_functions_application.this` | Optional Functions application attached to supplied subnets and NSGs. |
| Resource | `oci_functions_function.this` | Functions created from approved image URLs. |
| Resource | `oci_apigateway_gateway.this` | Optional gateway for HTTP ingress. |
| Resource | `oci_apigateway_deployment.this` | Optional route table using Oracle Functions backends. |
| Resource | `oci_events_rule.this` | Optional event rules with FAAS actions. |
| Resource | `oci_identity_policy.access` | Optional IAM policy for deploy, invoke, repository, and service permissions. |

## Request And Deployment Flow

- Operator or CI builds the function image from a reviewed source tree such as
  `samples/hello-python/`.
- The image is pushed to OCIR or another approved Functions-compatible image
  location.
- Terraform creates or references the Functions application in approved private
  subnets.
- Terraform creates one or more functions using explicit image URLs from local
  ignored tfvars.
- Terraform optionally creates API Gateway resources and routes HTTP requests to
  function backends.
- Terraform optionally creates OCI Events rules that invoke functions through
  FAAS actions.
- Outputs expose repository, application, function, route, event, and policy
  identifiers for downstream runbooks and application teams.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI
  provider and the Ansible Terraform runner.
- Image traffic moves from local build or CI to OCIR, then from Functions to the
  image repository when the function is created or updated.
- HTTP traffic enters through API Gateway only when the gateway deployment is
  enabled and routes are defined.
- Event traffic enters through OCI Events only when event rules and FAAS actions
  are enabled.
- Runtime egress leaves the function application subnets and must be reviewed
  through route tables, service gateway or NAT behavior, NSGs, and downstream
  service policies.
- Trust boundaries are the tenancy, application compartment, private subnets,
  NSGs, OCIR repository, API Gateway, Events rules, IAM policy, and downstream
  services reached by the function.
- Image credentials, OCIDs, event filters, customer route targets, function
  config values, and IAM group names belong in ignored local tfvars or secure
  pipeline variables.

## Detailed Architecture Notes

- Function source build is outside Terraform on purpose. Terraform consumes an
  approved image URL so plan output shows exactly which function image will run.
- Each function requires an explicit image URL. Use immutable tags or image
  digest review when the environment needs stricter change control.
- Keep API Gateway disabled until endpoint type, certificates, route paths,
  methods, and caller authentication are reviewed.
- Keep Events rules disabled until the event condition is narrow and tested.
  Broad filters can create surprising invocation volume.
- Use application-level signed image policy when image provenance matters and
  the KMS key process is ready.
- Use provisioned concurrency only for latency-sensitive paths. It is useful,
  but it changes cost behavior.
- Async success and failure destinations are available per function for queues,
  streams, topics, or channels when downstream processing needs explicit
  hand-off.
- IAM policy statements stay input-driven so customers can choose existing
  dynamic groups, identity domains, and compartment boundaries.

## Operational Boundaries

- Keep customer-specific OCIDs, DNS names, event filters, image URLs, IAM group
  names, contacts, and secrets in ignored local tfvars or approved pipeline
  variables.
- Run plan from this blueprint folder so provider files and local Ansible
  runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible
  playbooks or a reviewed Terraform workflow.
- Re-check image tags, route exposure, event trigger conditions, IAM scopes,
  subnet egress, and output hand-offs whenever inputs change.
- Build and push functions before Terraform apply when creating or updating
  function resources.
- Keep generated `.terraform` directories, lock files, tfstate, plans, local
  tfvars, and registry credentials out of git.

## Review Checklist

- Confirm the diagram matches `main.tf`: repository, application, function, API
  Gateway, deployment, Events rule, and IAM policy resources.
- Confirm every function image exists in the target registry and is approved for
  the environment.
- Confirm the Functions application subnets and NSGs match the private runtime
  design.
- Confirm API Gateway endpoint type, route path, method list, backend function,
  certificate, and authentication model are intentional.
- Confirm Events conditions are scoped to the exact service, compartment,
  bucket, topic, or resource signals expected.
- Confirm IAM statements grant only the deploy, invoke, network, and repository
  access required.
- Confirm tracing, syslog, async destinations, and provisioned concurrency match
  the workload support model.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml`
  still point at the shared Terraform runner.
