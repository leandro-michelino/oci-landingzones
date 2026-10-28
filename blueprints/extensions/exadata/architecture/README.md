# Exadata Extension Architecture

This is the deployment architecture for `blueprints/extensions/exadata`. It keeps the design reviewable in GitHub, terminals, pull requests, runbooks, and customer-safe notes without a diagramming tool.

## Deployment Purpose

Creates OCI Cloud Exadata Infrastructure in a selected availability domain for database platform capacity.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/extensions/exadata` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates OCI Cloud Exadata Infrastructure in a selected availability domain for database platform capacity. |
| Terraform components | `oci_database_cloud_exadata_infrastructure.this` |
| Primary architecture view | The diagram shows source-defined components and configuration associations; it is not runtime evidence. |


## Architecture

![Source-bounded exadata architecture](architecture.png)

[Edit the overview and native detail pages](architecture.drawio) · [Source resource inventory](resource-inventory.json)

The main draw.io document includes declaration-detail and existing-resource input pages.
These enumerate source declarations and references, not deployed instance counts.

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_database_cloud_exadata_infrastructure.this` | `Declared directly in main.tf` |

## Request And Deployment Flow

- Operator supplies the target compartment, availability domain, shape and capacity; no existing network input is consumed.
- Terraform creates the optional service resource graph declared in main.tf.
- Outputs expose only the IDs, names or endpoints declared in `outputs.tf`; they do not establish downstream application connectivity.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Plain lines show declared ID/configuration associations; no application data flow is configured by this entry point.
- Resources use the selected compartment, with a tenancy fallback that requires review. Existing networks and service identities are operator inputs only where declared.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

- No resources are created by default: `enable_exadata_infrastructure=false`.
- The two plain connectors show availability-domain selection and nested customer contact configuration. Contacts are not a messaging resource.
- There is no `maintenance_window` block, VM cluster, database, backup policy, network or database traffic configuration. Capacity and placement inputs default to null.

- Diagram/source review: 2026-10-28. Historical provider and infrastructure validation evidence remains unchanged. No cloud operation or runtime test was run for this conversion.

## Operational Boundaries

- This extension can run extension-only with supplied brownfield OCI IDs, or as
  base-plus-extension using outputs from core, networking, ownership, or
  operations blueprints.
- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_database_cloud_exadata_infrastructure.this`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
