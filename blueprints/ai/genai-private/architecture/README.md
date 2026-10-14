# OCI Generative AI Private Landing Zone Architecture

This is the deployment architecture for `blueprints/ai/genai-private`. It keeps the design reviewable in GitHub, terminals, pull requests, runbooks, and customer-safe notes without a diagramming tool.

## Deployment Purpose

Deploys a private OCI Generative AI endpoint pattern with optional archive bucket and scoped IAM policy.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/ai/genai-private` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Deploys a private OCI Generative AI endpoint pattern with optional archive bucket and scoped IAM policy. |
| Terraform components | `oci_generative_ai_generative_ai_private_endpoint.this`, `oci_objectstorage_bucket.archive`, `oci_identity_policy.access` |
| Primary architecture view | The Architecture diagram below shows the OCI components, dependency order, and traffic or control flow for this exact deployment. |

## Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| OCI Generative AI Private Landing Zone                                                                   |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {AI workload compartment / private subnet}                                                               |
|         |                                                                                                |
|         +--> [Generative AI private endpoint]                                                            |
|         |      private DNS prefix, subnet, NSGs, and service attachment controls                         |
|         |                                                                                                |
|         +--> [archive bucket]                                                                            |
|         |      prompt, dataset, and response archive path when enabled                                   |
|         |                                                                                                |
|         `--> [IAM access policy]                                                                         |
|                approved groups and service principals only                                               |
|                                                                                                          |
| Data path: notebook or app subnet -> private endpoint -> OCI Generative AI service.                      |
| Governance path: archive bucket and IAM policy preserve approved storage and access boundaries.          |
| Hand-off: private endpoint ID, archive bucket name, access policy ID, and resource map.                  |
+----------------------------------------------------------------------------------------------------------+
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
- Data plane traffic is the packet or service path shown in the Architecture diagram; if this deployment only creates identity or governance resources, the data plane is permission and signal flow.
- Trust boundaries are the tenancy, compartment, VCN, subnet, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

- Confirm private endpoint subnet and DNS prefix.
- Confirm model access statements match approved groups.
- Confirm archive bucket lifecycle and KMS settings before enabling storage.

## Operational Boundaries

Use OCI provider 9.9.x, the validated baseline for this blueprint. Provider
8.21.0 does not register the Generative AI private endpoint resource, even though
older generated documentation lists it. Validate provider support before planning.

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_generative_ai_generative_ai_private_endpoint.this`, `oci_objectstorage_bucket.archive`, `oci_identity_policy.access`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.

## October 2026 Configuration Review

Creates optional private transport, an archive bucket, and IAM policy. IAM policy creation uses the tenancy-home provider. A private endpoint does not prove model availability, inference, data residency, or absence of stored data; the optional bucket deliberately stores data. No endpoint or inference call was created in this review.

Validation in this round is isolated Terraform schema/lint validation and applicable mocked regressions, not a live AI deployment. All cost-bearing services, inference, ingestion, dedicated clusters, and external-cloud resources remained disabled. Providers ignore only the two OCI-managed provenance tags; customer-defined tags remain managed.
