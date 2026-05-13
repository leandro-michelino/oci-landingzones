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
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `identity_domain_ids`, `identity_domain_urls`, `replica_region_ids` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Custom Identity Domains                                                                           |
|                                                                                                  |
|  Identity administrators                                                                          |
|        | var.identity_domains map                                                                 |
|        v                                                                                          |
|  +---------------------------- OCI IAM Identity Domains ------------------------+                 |
|  | for_each identity_domains                                                   |                 |
|  |                                                                            |                 |
|  |  +---------------- Identity Domain: key A ----------------+                 |                 |
|  |  | compartment, display name, home region, license type    |                 |                 |
|  |  | admin email/name/user, login visibility, email rules    |                 |                 |
|  |  +---------------------------+-----------------------------+                 |                 |
|  |                              | replica regions from domain map                                |                 |
|  |                              v                                                                 |                 |
|  |  +---------------- Identity Domain Replication ----------------------------+ |                 |
|  |  | one oci_identity_domain_replication_to_region per configured replica    | |                 |
|  |  +-----------------------------------------------------------------------+ |                 |
|  +----------------------------------------------------------------------------+                 |
|                                                                                                  |
|  Flow: Terraform creates each identity domain, then creates regional replicas for that domain.     |
+--------------------------------------------------------------------------------------------------+
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

- The output contract at the end of this page is the hand-off surface for downstream blueprints, runbooks, and customer notes.

## State, Inputs, And Outputs

```text
Input sources
|-- terraform.tfvars.example documents expected values for this deployment
|-- local ignored tfvars provide tenancy, compartment, CIDR, endpoint, and service-specific values
|-- environment variables may provide OCI authentication and guarded Ansible confirms
|
Terraform state
|-- backend is disabled for local validation and blueprint-local runners by default
|-- production state backends should be configured outside this reusable blueprint folder
|-- generated .terraform directories, lock files, plans, state files, and local tfvars stay out of git
|
Output contract
|-- blueprint_name
|-- name_prefix
|-- resource_ids
|-- identity_domain_ids
|-- identity_domain_urls
`-- replica_region_ids
```


## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_identity_domain.this`, `oci_identity_domain_replication_to_region.replicas`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `identity_domain_ids`, `identity_domain_urls`, `replica_region_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
