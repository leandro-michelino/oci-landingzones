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


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Streaming Extension                                                                                      |
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
| [OCI Streaming]                                                                                          |
|         |-- stream pool with optional custom encryption key                                              |
|         |-- one or more streams with configured partitions and retention                                 |
|         |-- optional private endpoint path through supplied VCN/subnet/NSGs                              |
|         `-- tags, compartment scope, and optional private access controls                                |
|                  |                                                                                       |
|                  v                                                                                       |
| [producers] -> [stream endpoint / private endpoint] -> [stream pool] -> [streams]                        |
| [consumers] <- [stream endpoint / private endpoint] <- [consumer group offsets]                          |
|                                                                                                          |
| Review focus: partition count, retention, KMS key, private endpoint subnet, NSGs, and producer/consumer  |
| IAM policies.                                                                                            |
| Hand-off: service IDs, endpoint names, private access IDs, and operational references for application    |
| teams.                                                                                                   |
+----------------------------------------------------------------------------------------------------------+
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

## Operational Boundaries

- This extension can run extension-only with supplied brownfield OCI IDs, or as
  base-plus-extension using outputs from core, networking, ownership, or
  operations blueprints.
- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_streaming_stream_pool.this`, `oci_streaming_stream.this`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
