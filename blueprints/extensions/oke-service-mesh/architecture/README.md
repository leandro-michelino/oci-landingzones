# OKE Service Mesh Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/oke-service-mesh`. It is intentionally ASCII-first so it is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys the OKE service mesh add-on shell with optional APM domain for distributed tracing hand-off.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/extensions/oke-service-mesh` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Deploys the OKE service mesh add-on shell with optional APM domain for distributed tracing hand-off. |
| Terraform components | `oci_containerengine_addon.service_mesh`, `oci_apm_apm_domain.tracing` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic or control flow for this exact deployment. |

## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| OKE Service Mesh                                                                                         |
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
| [OKE Service Mesh]                                                                                       |
|         |-- service mesh add-on attached to an existing OKE cluster                                      |
|         |-- APM domain for tracing when enabled                                                          |
|         |-- mesh policies and workload namespace choices handled by platform operations                  |
|         `-- tags, compartment scope, and optional private access controls                                |
|                  |                                                                                       |
|                  v                                                                                       |
| [services in OKE] -> [mesh sidecars/policies] -> [APM tracing] -> [operator review]                      |
|                                                                                                          |
| Review focus: cluster ID, add-on version, namespace selection, mTLS posture, tracing destination, and    |
| rollout order.                                                                                           |
| Hand-off: service IDs, endpoint names, private access IDs, and operational references for application    |
| teams.                                                                                                   |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_containerengine_addon.service_mesh` | Declared directly in `main.tf` |
| Resource | `oci_apm_apm_domain.tracing` | Declared directly in `main.tf` |

## Request And Deployment Flow

- Operator supplies the existing network, compartment, service, or backend IDs required by the deployment.
- Terraform creates the optional service resource graph declared in `main.tf`.
- Outputs expose service IDs, endpoint names, or attachment IDs for applications and runbooks.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is permission and signal flow.
- Trust boundaries are the tenancy, compartment, VCN, subnet, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

- Confirm cluster ID and add-on name/version match the target OKE release.
- Confirm remove_addon_resources_on_delete behavior before destroy.
- Confirm APM domain ownership and tracing data retention.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_containerengine_addon.service_mesh`, `oci_apm_apm_domain.tracing`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
