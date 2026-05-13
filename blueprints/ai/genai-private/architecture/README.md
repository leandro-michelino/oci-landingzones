# OCI Generative AI Private Landing Zone Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/ai/genai-private`. It is intentionally ASCII-first so it is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys a private OCI Generative AI endpoint pattern with optional archive bucket and scoped IAM policy.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/ai/genai-private` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Deploys a private OCI Generative AI endpoint pattern with optional archive bucket and scoped IAM policy. |
| Terraform components | `oci_generative_ai_generative_ai_private_endpoint.this`, `oci_objectstorage_bucket.archive`, `oci_identity_policy.access` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic or control flow for this exact deployment. |

## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| OCI Generative AI Private Landing Zone                                                           |
|                                                                                                  |
|  App or notebook subnet
|         |
|         v
|  private endpoint and service gateway route
|         |
|         v
|  OCI Generative AI
|         |
|         v
|  archive bucket for prompts and datasets
|         |
|         v
|  IAM policy scope
|                                                                                                  |
|  Control: Terraform creates enabled resources from variables and returns stable hand-off outputs. |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_generative_ai_generative_ai_private_endpoint.this` | Declared directly in `main.tf` |
| Resource | `oci_objectstorage_bucket.archive` | Declared directly in `main.tf` |
| Resource | `oci_identity_policy.access` | Declared directly in `main.tf` |

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

- Confirm private endpoint subnet and DNS prefix.
- Confirm model access statements match approved groups.
- Confirm archive bucket lifecycle and KMS settings before enabling storage.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_generative_ai_generative_ai_private_endpoint.this`, `oci_objectstorage_bucket.archive`, `oci_identity_policy.access`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
