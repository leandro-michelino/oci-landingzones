# Private Data Platform Landing Zone

Start here for `blueprints/data-platform/private-data-platform`: what it builds, which inputs deserve a careful look, how to run Terraform or the local Ansible wrappers, and where the detailed architecture notes live.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/data-platform/private-data-platform` |
| Best fit | Builds a private data-platform pattern with network placement, vault/KMS, object storage, private endpoint, and streaming hooks. |
| Terraform shape | Private network module, optional Vault/KMS, Object Storage bucket and private endpoint, optional Streaming, plus managed endpoint NSGs when using the created subnet. |
| Inputs to settle first | `compartment_ocid`, `vaults`, `vault_keys`, `data_bucket_name`, `bucket_kms_key_id`, `bucket_auto_tiering`, `bucket_storage_tier`, plus 12 more |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_id`, `subnet_ids`, `vault_ids`, `vault_key_ids`, plus 4 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Builds a private data-platform pattern with network placement, vault/KMS, object storage,
private endpoint, and streaming hooks.

The private VCN, subnets, security list, route table, and service gateway are always created. The Networking module now selects immutable revision `c07231c91d146265a46836757f3c399861a59fff`, which preserves its resource addresses, adds regional Oracle Services Network HTTPS egress, and suppresses drift from OCI provenance tags. Review an existing deployment's plan before apply because its baseline egress rule may update. Vault and Streaming stay pinned to `v0.2.0` to preserve their resource addresses. Vault/key, bucket, Object Storage private endpoint, and Streaming remain enabled by their existing defaults; explicitly set their `enable_*` inputs to `false` for a network-only plan. Review every paid service before applying.

## When To Use This Deployment

- Data services must stay private.
- Object Storage, Streaming, and KMS need to be reviewed as one pattern.
- Multiple data-product teams need a repeatable landing-zone shape.

## Use Cases

| Use Case | Why This Blueprint Fits |
| --- | --- |
| Private data-product foundation | Creates network, bucket, private endpoint, Vault/KMS, and Streaming hooks as one reusable platform base. |
| Secure ingestion landing zone | Combines Object Storage and Streaming so producers can land batch files and event streams privately. |
| Analytics staging area | Provides a private bucket, subnet contracts, and encryption hooks for downstream analytics or lakehouse services. |
| Multi-team data platform starter | Gives platform teams a repeatable pattern with named outputs for data, app, and endpoint subnets. |
| Governance and audit readiness | Captures encryption, private endpoint, bucket events, stream retention, and tags before production rollout. |

## What This Deploys

Everything needed for this deployment starts in this folder: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | Private endpoint network foundation module. |
| Module | `vault` | Vault and KMS module. |
| Module | `streaming` | Streaming extension module. |
| Resource | `oci_objectstorage_bucket.data` | Declared directly in `main.tf` |
| Resource | `oci_objectstorage_private_endpoint.data` | Declared directly in `main.tf` |
| Resource | `oci_core_network_security_group.object_storage_endpoint` | Managed HTTPS NSG when the Object Storage endpoint uses the created subnet and no existing NSG is supplied. |
| Resource | `oci_core_network_security_group.streaming_endpoint` | Managed REST/Kafka NSG when a new stream pool uses the created subnet and no existing NSG is supplied. |
| Data source | `data.oci_objectstorage_namespace.this` | Read during plan/apply |

Use `variables.tf` as the input contract, then keep real OCIDs, CIDRs, names, and enable flags in an ignored local `terraform.tfvars`.

## Folder Contract

```text
blueprints/data-platform/private-data-platform/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
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
| `compartment_ocid` | Compartment OCID where private data platform resources are created. Defaults to tenancy_ocid. |
| `vaults` | Additional OCI Vaults keyed by logical name. |
| `vault_keys` | KMS keys keyed by logical name. |
| `data_bucket_name` | Optional Object Storage bucket name. |
| `bucket_kms_key_id` | Optional KMS key OCID for Object Storage bucket encryption. |
| `bucket_auto_tiering` | Object Storage auto-tiering setting. |
| `bucket_storage_tier` | Object Storage tier for the data bucket. |
| `private_endpoint_name` | Optional Object Storage private endpoint name. |
| `private_endpoint_prefix` | Object Storage private endpoint prefix. |
| `private_endpoint_subnet_id` | Optional subnet OCID for the Object Storage private endpoint. |
| `private_endpoint_subnet_key` | Subnet key from the private network module used when private_endpoint_subnet_id is omitted. |
| `private_endpoint_nsg_ids` | Optional NSG OCIDs for the Object Storage private endpoint. |
| `private_endpoint_allowed_client_cidrs` | Approved TCP/443 client CIDRs for the managed Object Storage endpoint NSG. Empty denies ingress; existing NSGs need separately managed rules. |
| `create_stream_pool` | Create a stream pool when enable_streaming is true. |
| `stream_pool_id` | Existing stream pool OCID used when create_stream_pool is false. |
| `stream_pool_name` | Optional stream pool name. |
| `streaming_kms_key_id` | Optional KMS key OCID for stream pool encryption. |
| `streaming_private_endpoint_subnet_id` | Optional subnet OCID for Streaming private endpoint access. |
| `streaming_private_endpoint_nsg_ids` | Optional NSG OCIDs for the Streaming private endpoint. |
| `streaming_allowed_client_cidrs` | Approved TCP/443 REST and TCP/9092 Kafka client CIDRs for the managed Streaming NSG. Empty denies ingress. |
| `streams` | Streams to create for private data pipelines. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_vault` | Create Vault resources for platform encryption. |
| `enable_default_vault` | Create the default platform vault. |
| `enable_default_key` | Create the default platform KMS key. |
| `enable_data_bucket` | Create the private data platform Object Storage bucket. |
| `enable_bucket_events` | Enable Object Storage events on the data bucket. |
| `enable_bucket_versioning` | Enable Object Storage bucket versioning. |
| `enable_object_storage_private_endpoint` | Create an Object Storage private endpoint. |
| `enable_streaming` | Create OCI Streaming resources for private data pipelines. |

An Object Storage private endpoint requires the managed bucket. A supplied external endpoint subnet also requires explicit NSG IDs. A new private stream pool uses the network module's `endpoints` subnet by default; a supplied external subnet requires explicit NSG IDs. Existing stream pools can be public or private and must be checked separately.

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `vcn_id` | Private data platform VCN OCID. |
| `subnet_ids` | Private data platform subnet OCIDs keyed by role. |
| `vault_ids` | Vault OCIDs keyed by logical name. |
| `vault_key_ids` | KMS key OCIDs keyed by logical name. |
| `data_bucket_name` | Created Object Storage bucket name, or null when disabled. |
| `object_storage_private_endpoint_id` | Object Storage private endpoint OCID. |
| `stream_pool_id` | Streaming stream pool OCID. |
| `stream_ids` | Stream OCIDs keyed by logical name. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/data-platform/private-data-platform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/data-platform/private-data-platform
ansible-playbook -i localhost, -c local ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, -c local ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, -c local ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer or shared environments.

## Deployment Order

1. Deploy core and private networking first.
2. Review object storage, private endpoint, vault, and streaming settings.
3. Populate `terraform.tfvars` with data-platform inputs.
4. Run plan and review data access paths.
5. Apply, then hand outputs to data product teams.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Confirm private endpoint subnet and DNS behavior.
- Confirm the endpoint NSG allows only approved client CIDRs. The managed Object Storage endpoint receives TCP/443 ingress rules only when `private_endpoint_allowed_client_cidrs` is set ([Oracle Object Storage guidance](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/private-endpoints.htm)).
- Confirm Streaming REST TCP/443 and Kafka TCP/9092 access separately ([Oracle Streaming troubleshooting](https://docs.oracle.com/en-us/iaas/Content/Streaming/Reference/troubleshootingstreaming.htm)).
- Review bucket naming, encryption, and access policies.
- Check streaming partitions, retention, and cost impact.
- The Object Storage private endpoint uses a private IP inside the VCN. Service gateway routing is a separate path to Oracle Services Network endpoints; its packet flow has not been validated in this blueprint.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-changed.sh
```

Use `./scripts/validate-all.sh` before release work or broad shared changes.

The 2026-10-15 local checks passed `terraform init`, `terraform validate`, and four plan-only regression cases with OCI provider 9.9.0. They do not establish endpoint traffic, DNS, data transfer, or successful paid-service provisioning. An attempted mock apply on 2026-10-15 unexpectedly reached the nested network module's own OCI provider and returned `404 NotAuthorizedOrNotFound` against a placeholder compartment; the test stopped, Terraform retained no test state, and an API inventory of the authorized São Paulo compartment found no VCN. Keep tests of this legacy provider-configured module in plan mode unless fully isolated provider injection is established.
