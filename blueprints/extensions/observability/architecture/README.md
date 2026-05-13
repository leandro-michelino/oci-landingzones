# Observability Platform Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/observability`. It is intentionally ASCII-first so it is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys an observability layer with optional Log Analytics namespace and group, APM domain, and Operations Insights private endpoint.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/extensions/observability` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Deploys an observability layer with optional Log Analytics namespace and group, APM domain, and Operations Insights private endpoint. |
| Terraform components | `oci_log_analytics_namespace.this`, `oci_log_analytics_log_analytics_log_group.this`, `oci_apm_apm_domain.this`, `oci_opsi_operations_insights_private_endpoint.this` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic or control flow for this exact deployment. |

## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Observability Platform                                                                           |
|                                                                                                  |
|  OCI audit, VCN flow, OS, app logs
|         |
|         v
|  Log Analytics namespace and log group
|         |
|         v
|  APM domain
|         |
|         v
|  Operations Insights private endpoint
|         |
|         v
|  ONS and downstream alerts
|                                                                                                  |
|  Control: Terraform creates enabled resources from variables and returns stable hand-off outputs. |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_log_analytics_namespace.this` | Declared directly in `main.tf` |
| Resource | `oci_log_analytics_log_analytics_log_group.this` | Declared directly in `main.tf` |
| Resource | `oci_apm_apm_domain.this` | Declared directly in `main.tf` |
| Resource | `oci_opsi_operations_insights_private_endpoint.this` | Declared directly in `main.tf` |

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

- Confirm Log Analytics namespace ownership and onboarding.
- Confirm APM free tier versus paid domain.
- Confirm Operations Insights subnet, VCN, and NSGs.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_log_analytics_namespace.this`, `oci_log_analytics_log_analytics_log_group.this`, `oci_apm_apm_domain.this`, `oci_opsi_operations_insights_private_endpoint.this`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
