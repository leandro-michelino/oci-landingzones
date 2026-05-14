# Custom Identity Domain Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/identity/custom-identity-domain`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates one or more OCI IAM identity domains with optional replica regions from a structured identity domain map.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/identity/custom-identity-domain` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates one or more OCI IAM identity domains with optional replica regions from a structured identity domain map. |
| Terraform components | `oci_identity_domain.this`, `oci_identity_domain_replication_to_region.replicas` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Custom Identity Domain                                                                                   |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {OCI IAM home region / identity domain boundary}                                                         |
|         |                                                                                                |
|         v                                                                                                |
| [identity domains for_each map]                                                                          |
|         |-- display name, description, license type, admin contact                                       |
|         |-- login visibility, primary email, notification behavior                                       |
|         `-- compartment placement and lifecycle controls                                                 |
|                  |                                                                                       |
|                  v                                                                                       |
| [domain replication to regions]                                                                          |
|         |-- one replica resource per requested region                                                    |
|         `-- depends on the domain ID created above                                                       |
|                                                                                                          |
| Control flow: create domain first, then regional replicas.                                               |
| Trust boundary: authentication, federation, and application onboarding begin at the domain edge.         |
| Hand-off: domain IDs, URLs, names, and replica region IDs for identity operations.                       |
+----------------------------------------------------------------------------------------------------------+
```

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
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
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
