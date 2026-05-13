# Streaming Extension Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/streaming`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates an OCI Streaming stream pool and streams, with optional KMS encryption and private endpoint settings.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/extensions/streaming` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates an OCI Streaming stream pool and streams, with optional KMS encryption and private endpoint settings. |
| Terraform components | `oci_streaming_stream_pool.this`, `oci_streaming_stream.this` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `stream_pool_id`, `stream_ids` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Streaming Extension                                                                               |
|                                                                                                  |
|  Producers                                                   Consumers                            |
|      | put messages                                             ^ get messages                    |
|      v                                                          |                                 |
|  +----------------------------- OCI Streaming -----------------------------+                     |
|  | Stream Pool                                                             |                     |
|  | - created or referenced by stream_pool_id                                |                     |
|  | - optional custom encryption key from KMS                                 |                     |
|  | - optional private endpoint settings: subnet_id + NSG IDs                 |                     |
|  | - optional Kafka-compatible settings                                      |                     |
|  |                                                                         |                     |
|  |  stream: each key in var.streams -> partitions + retention hours          |                     |
|  +------------------------------+------------------------------------------+                     |
|                                 | private endpoint path when configured                           |
|                                 v                                                                 |
|                         Existing VCN subnet / NSGs                                                |
|                                                                                                  |
|  Traffic: app producers -> stream endpoint; consumer groups read from stream partitions.           |
|  Control: Terraform creates the stream pool first, then one stream per var.streams entry.          |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_streaming_stream_pool.this` | `Declared directly in main.tf` |
| Resource | `oci_streaming_stream.this` | `Declared directly in main.tf` |

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

- The stream pool can be created here or referenced by stream_pool_id, which changes lifecycle ownership.
- KMS encryption, private endpoint subnet ID, NSG IDs, and Kafka-compatible settings are pool-level controls.
- Each entry in var.streams creates a stream with its own partition count and retention hours.
- Producer and consumer teams should use the stream IDs and stream pool ID outputs rather than discovering resources manually.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_streaming_stream_pool.this`, `oci_streaming_stream.this`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `stream_pool_id`, `stream_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
