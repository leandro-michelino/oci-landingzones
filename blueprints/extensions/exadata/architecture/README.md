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


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Exadata Extension                                                                                        |
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
| [Cloud Exadata Infrastructure]                                                                           |
|         |-- infrastructure shape, availability domain, and compute/storage capacity                      |
|         |-- maintenance window and contacts                                                              |
|         |-- network attachment decisions owned by database platform design                               |
|         `-- tags, compartment scope, and optional private access controls                                |
|                  |                                                                                       |
|                  v                                                                                       |
| [DB platform operators] -> [Exadata infrastructure] -> [VM clusters and databases added by later layers] |
|                                                                                                          |
| Review focus: capacity, AD placement, maintenance policy, support contacts, and downstream VM cluster    |
| ownership.                                                                                               |
| Hand-off: service IDs, endpoint names, private access IDs, and operational references for application    |
| teams.                                                                                                   |
+----------------------------------------------------------------------------------------------------------+
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

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_database_cloud_exadata_infrastructure.this`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
