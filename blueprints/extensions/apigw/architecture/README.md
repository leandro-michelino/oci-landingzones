# API Gateway Extension Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/apigw`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Adds OCI API Gateway and deployment routes so application APIs can be exposed through a managed gateway endpoint.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/extensions/apigw` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Adds OCI API Gateway and deployment routes so application APIs can be exposed through a managed gateway endpoint. |
| Terraform components | `oci_apigateway_gateway.this`, `oci_apigateway_deployment.this` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| API Gateway Extension                                                                                    |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Existing compartment / VCN / subnet / service boundary as required}                                     |
|         |                                                                                                |
|         v                                                                                                |
| [API Gateway]                                                                                            |
|         |-- gateway endpoint in supplied subnet/network context                                          |
|         |-- deployment with path prefix and route definitions                                            |
|         |-- backend targets owned by application teams                                                   |
|         `-- tags, compartment scope, and optional private access controls                                |
|                  |                                                                                       |
|                  v                                                                                       |
| [clients] -> [gateway endpoint] -> [deployment routes] -> [private or public backends]                   |
|                                                                                                          |
| Review focus: gateway endpoint type, route auth, backend URLs, subnet/NSG posture, and IAM policy scope. |
| Hand-off: service IDs, endpoint names, private access IDs, and operational references for application    |
| teams.                                                                                                   |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_apigateway_gateway.this` | `Declared directly in main.tf` |
| Resource | `oci_apigateway_deployment.this` | `Declared directly in main.tf` |

## Request And Deployment Flow

- Operator supplies the existing network, compartment, service, or backend IDs required by the extension.
- Terraform creates the optional service resource graph declared in main.tf.
- Outputs expose service IDs, endpoint names, or attachment IDs for applications and runbooks.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- The gateway can be created here or an existing gateway_id can be supplied, which changes whether this folder owns the gateway lifecycle.
- Private gateways depend on the supplied subnet_id and NSG IDs; public gateways depend on endpoint_type and certificate choices.
- Each route maps a path/method pair to the configured backend type, backend URL or status, and timeout behavior.
- The deployment endpoint is the main consumer hand-off for clients, app teams, DNS records, and monitoring.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_apigateway_gateway.this`, `oci_apigateway_deployment.this`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
