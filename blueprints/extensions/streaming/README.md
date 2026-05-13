# Streaming Extension

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/extensions/streaming`. It tells you what
the blueprint builds, which inputs deserve a real review, how to run Terraform or the local
Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/extensions/streaming` |
| Best fit | Adds OCI Streaming resources with stream pool and stream outputs for event-driven or data-platform workloads. |
| Terraform shape | `oci_streaming_stream_pool.this`, `oci_streaming_stream.this` |
| Inputs to settle first | `compartment_ocid`, `create_stream_pool`, `stream_pool_id`, `stream_pool_name`, `kms_key_id`, `private_endpoint_subnet_id`, `private_endpoint_nsg_ids`, plus 2 more |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `stream_pool_id`, `stream_ids` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Adds OCI Streaming resources with stream pool and stream outputs for event-driven or
data-platform workloads.

## When To Use This Deployment

- Applications need managed streaming.
- Retention, partitions, and access policies need a reusable pattern.
- Streaming outputs must be handed off to producers and consumers.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_streaming_stream_pool.this` | Declared directly in `main.tf` |
| Resource | `oci_streaming_stream.this` | Declared directly in `main.tf` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/extensions/streaming/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed ASCII architecture for this deployment
|-- main.tf                    Terraform modules, resources, and data sources
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    `-- destroy.yml            Guarded destroy
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored `terraform.tfvars` with
real OCIDs, CIDRs, names, recipients, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
| --- | --- |
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region name. |
| `home_region` | OCI tenancy home region. |
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `compartment_ocid` | Compartment OCID where Streaming resources are created. Defaults to tenancy_ocid for validation-only tests. |
| `create_stream_pool` | Create a stream pool when enable_streaming is true. Disable when using an existing stream pool. |
| `stream_pool_id` | Existing stream pool OCID used when create_stream_pool is false. |
| `stream_pool_name` | Optional stream pool name override. |
| `kms_key_id` | Optional Vault key OCID for stream pool encryption. |
| `private_endpoint_subnet_id` | Optional subnet OCID for private stream pool access. |
| `private_endpoint_nsg_ids` | Optional NSG OCIDs for the stream pool private endpoint. |
| `kafka_settings` | Optional Kafka-compatible stream pool settings. |
| `streams` | Streams to create when enable_streaming is true. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_streaming` | Create OCI Streaming resources. Disabled by default to avoid cost in smoke tests. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `stream_pool_id` | Created or referenced stream pool OCID. |
| `stream_ids` | Stream OCIDs keyed by logical stream name. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/extensions/streaming
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/extensions/streaming
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Deploy core and the required network foundation first.
2. Confirm service-specific quotas, cost, and dependencies.
3. Populate `terraform.tfvars` with subnet, compartment, and service values.
4. Run plan and review optional resource enable flags.
5. Apply only after the platform or service owner approves the output shape.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Confirm partition count and retention.
- Review private access and IAM policies.
- Check throughput and cost expectations before apply.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required
architecture README sections, `terraform init -backend=false`, `terraform validate`, root
Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and
cleanup of generated Terraform artifacts.
