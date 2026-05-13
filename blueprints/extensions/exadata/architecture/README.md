# Exadata Extension Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/exadata`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates OCI Cloud Exadata Infrastructure in a selected availability domain for database platform capacity.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/extensions/exadata` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates OCI Cloud Exadata Infrastructure in a selected availability domain for database platform capacity. |
| Terraform components | `oci_database_cloud_exadata_infrastructure.this` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `cloud_exadata_infrastructure_id` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Exadata Extension                                                                                 |
|                                                                                                  |
|  Operator / database platform team                                                                |
|       |                                                                                          |
|       v                                                                                          |
|  +--------------------------- OCI Region / AD --------------------------+                        |
|  | Compartment selected by compartment_ocid or tenancy fallback          |                        |
|  |                                                                       |                        |
|  |  +---------------- OCI Cloud Exadata Infrastructure ----------------+ |                        |
|  |  | shape, compute_count, storage_count                              | |                        |
|  |  | database_server_type and storage_server_type when supplied         | |                        |
|  |  | customer contacts for Oracle service communications                | |                        |
|  |  +-----------------------------+------------------------------------+ |                        |
|  |                                |                                      |                        |
|  |                                v                                      |                        |
|  |  Future hand-off: VM clusters, databases, backup, and network attach  |                        |
|  +-----------------------------------------------------------------------+                        |
|                                                                                                  |
|  Traffic: this deployment creates infrastructure capacity; application/database traffic starts     |
|  after VM clusters and database resources are attached by follow-on work.                         |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_database_cloud_exadata_infrastructure.this` | `Declared directly in main.tf` |

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

- This deployment creates the Exadata infrastructure capacity only; VM clusters, databases, backup policy, and application connectivity are follow-on work.
- Availability domain, shape, compute count, storage count, and server types should be reviewed for quota, cost, and regional availability before apply.
- Customer contacts are part of the operational support path and should be accurate before the infrastructure is created.
- The main hand-off is the Cloud Exadata Infrastructure OCID for database platform teams.

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
`-- cloud_exadata_infrastructure_id
```


## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_database_cloud_exadata_infrastructure.this`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `cloud_exadata_infrastructure_id`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
