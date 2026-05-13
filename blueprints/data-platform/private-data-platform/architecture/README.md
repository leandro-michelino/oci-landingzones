# Private Data Platform Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/data-platform/private-data-platform`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates a private data landing zone with a private VCN, Vault/KMS, Object Storage bucket access through a private endpoint, and optional Streaming.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/data-platform/private-data-platform` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates a private data landing zone with a private VCN, Vault/KMS, Object Storage bucket access through a private endpoint, and optional Streaming. |
| Terraform components | `oci_objectstorage_namespace.this`, `network`, `vault`, `oci_objectstorage_bucket.data`, `oci_objectstorage_private_endpoint.data`, `streaming` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Private Data Platform                                                                             |
|                                                                                                  |
|  Data producers / analytics jobs / private applications                                           |
|                 |                                                                                |
|                 v                                                                                |
|  +----------------------------- Private VCN -----------------------------+                       |
|  | No Internet Gateway; service access stays private                     |                       |
|  | Private endpoint subnet hosts Object Storage private endpoint          |                       |
|  | Optional NAT Gateway supports controlled outbound updates if enabled   |                       |
|  | Service Gateway supports private OCI service access                    |                       |
|  +------------------+-------------------------------+--------------------+                       |
|                     |                               |                                            |
|                     | bucket private access          | stream private access when configured      |
|                     v                               v                                            |
|  +---------------------------+        +-------------------------------+                         |
|  | Object Storage Bucket     |        | OCI Streaming                 |                         |
|  | NoPublicAccess            |        | Stream Pool                   |                         |
|  | versioning/events optional|        | Streams with partitions       |                         |
|  | KMS key from Vault or var |        | Optional private endpoint     |                         |
|  +-------------+-------------+        +---------------+---------------+                         |
|                |                                      |                                         |
|                v                                      v                                         |
|        +---------------+                      +---------------+                                  |
|        | Vault / KMS   | encrypts bucket and stream pool when keys are enabled                    |
|        +---------------+                                                                          |
|                                                                                                  |
|  Traffic: private subnet workload -> private endpoint/service gateway -> Object Storage/Streaming.|
|  Control: Terraform creates network first, then Vault/KMS, then bucket/private endpoint/streams.  |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Data source | `oci_objectstorage_namespace.this` | `Read during plan/apply` |
| Module | `network` | `../../../blueprints/networking/standalone-private-endpoint-only` |
| Module | `vault` | `../../../modules/security/vault` |
| Resource | `oci_objectstorage_bucket.data` | `Declared directly in main.tf` |
| Resource | `oci_objectstorage_private_endpoint.data` | `Declared directly in main.tf` |
| Module | `streaming` | `../../../blueprints/extensions/streaming` |

## Request And Deployment Flow

- Operator reviews tfvars, enable flags, and required external IDs.
- Terraform creates resources in the dependency order declared by main.tf.
- Outputs expose the hand-off contract for the next deployment, app team, or runbook.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- The private endpoint VCN is created before data services so Object Storage and Streaming can use private network paths.
- Vault/KMS supplies the default key path for the bucket and stream pool unless explicit KMS key IDs are supplied.
- Object Storage remains NoPublicAccess; access should flow through the object storage private endpoint, service gateway, and configured NSGs.
- Streaming can be private-endpoint enabled and should share the same private subnet and key-management review as the bucket path.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_objectstorage_namespace.this`, `network`, `vault`, `oci_objectstorage_bucket.data`, `oci_objectstorage_private_endpoint.data`, `streaming`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
