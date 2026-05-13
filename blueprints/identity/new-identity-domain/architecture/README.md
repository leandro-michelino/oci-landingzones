# New Identity Domain Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/identity/new-identity-domain`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates a single OCI IAM identity domain with optional regional replication.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/identity/new-identity-domain` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates a single OCI IAM identity domain with optional regional replication. |
| Terraform components | `oci_identity_domain.this`, `oci_identity_domain_replication_to_region.replicas` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| New Identity Domain                                                                               |
|                                                                                                  |
|  Identity administrator                                                                           |
|       | enable_identity_domain                                                                    |
|       v                                                                                          |
|  +---------------------------- OCI IAM Identity Domain -------------------------+                 |
|  | Single domain in target compartment                                          |                 |
|  | - display name and description from variables                                |                 |
|  | - home region from home_region or region                                     |                 |
|  | - license type and admin contact fields                                      |                 |
|  | - login visibility and primary email controls                                |                 |
|  +--------------------------------+---------------------------------------------+                 |
|                                   | for_each replica_regions                                      |
|                                   v                                                                  |
|  +------------------------ Domain Replication To Region ------------------------+                 |
|  | Creates one replication target per requested region                          |                 |
|  +----------------------------------------------------------------------------+                 |
|                                                                                                  |
|  Flow: domain creation completes before replication resources reference the domain ID.             |
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

- This deployment creates one identity domain when enable_identity_domain is true.
- Replica regions are created after the domain exists and should be aligned with regional availability and recovery needs.
- Admin user fields, notification behavior, login visibility, and primary email requirements should be reviewed before apply.
- The identity domain ID and URL are the primary hand-offs for identity operations, federation, and application onboarding.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_identity_domain.this`, `oci_identity_domain_replication_to_region.replicas`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
