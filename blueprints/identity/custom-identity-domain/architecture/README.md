# Custom Identity Domain Architecture

This is the deployment architecture for `blueprints/identity/custom-identity-domain`. The PNG provides a GitHub-readable preview; the draw.io source preserves editable shapes and official OCI icons.

## Deployment Purpose

Creates one or more OCI IAM identity domains with optional replica regions from a structured identity domain map.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/identity/custom-identity-domain` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates one or more OCI IAM identity domains with optional replica regions from a structured identity domain map. |
| Terraform components | `oci_identity_domain.this`, `oci_identity_domain_replication_to_region.replicas` |
| Primary architecture view | The diagram shows default enablement, compartment/IAM scope and configuration dependencies; it is not runtime evidence. |


## Architecture

![Custom Identity Domain Architecture](architecture.png)

[Editable draw.io source](architecture.drawio). Keep the source and PNG aligned
after diagram changes.

Generated with the [oci-architecture-diagrams skill](https://github.com/leandro-michelino/oci-architecture-diagrams)
and Oracle OCI Architecture Diagram Toolkit v24.2. From the repository root, run
`python3 scripts/diagrams/foundation-batch-02.py --render` after installing the
skill and official toolkit. The toolkit is not redistributed in this repository.

The view distinguishes default resources, conditional enablement, home-region
IAM, compartment hierarchy and delegated policy paths. It does not assert
workload provisioning, successful authorization or security certification.

Diagram documentation reviewed on 2026-10-28 against Terraform, variables, locals,
providers and referenced module definitions. No cloud resources were created
and no Terraform/provider validation date was updated. Arrows describe
configuration dependencies or IAM bindings, not verified packet paths.

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_identity_domain.this` | `Declared directly in main.tf` |
| Resource | `oci_identity_domain_replication_to_region.replicas` | `Declared directly in main.tf` |

## Request And Deployment Flow

- Provider authentication uses the home-region IAM plane.
- Terraform creates domains, groups, dynamic groups, or policies in dependency order.
- Outputs expose identity IDs, names, URLs, and policy IDs for operators and downstream blueprints.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the Architecture diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- Each identity domain is created from the identity_domains map, allowing different compartments, home regions, admin contacts, and license types.
- Replica resources are created per domain and per requested replica region after the source domain exists.
- The admin contact and login visibility settings directly affect initial domain administration and user experience.
- Outputs expose identity domain IDs, URLs, and replica region IDs for identity operations and federation planning.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_identity_domain.this`, `oci_identity_domain_replication_to_region.replicas`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
