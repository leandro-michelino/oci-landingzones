# Private Data Platform Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This deployment README belongs only to `blueprints/data-platform/private-data-platform`. It is the run-facing guide for this blueprint; the detailed ASCII design lives beside it in `architecture/README.md`.

## Deployment Purpose

Builds a private data-platform pattern with network placement, vault/KMS, object storage, private endpoint, and streaming hooks.

## When To Use This Deployment

- Data services must stay private.
- Object Storage, Streaming, and KMS need to be reviewed as one pattern.
- Multiple data-product teams need a repeatable landing-zone shape.

## What This Deploys

The Terraform in this folder wires the following local components:

- Terraform module `network`
- Terraform module `vault`
- Terraform module `streaming`
- Terraform resource `oci_objectstorage_bucket.data`
- Terraform resource `oci_objectstorage_private_endpoint.data`
- Terraform data source `oci_objectstorage_namespace.this`

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/data-platform/private-data-platform/
|-- README.md                  This deployment guide
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

Base tenancy and naming inputs:
- `tenancy_ocid`
- `current_user_ocid`
- `region`
- `home_region`
- `oci_config_profile`
- `org`
- `environment`
- `region_key`
- `defined_tags`
- `freeform_tags`

Deployment-specific inputs to review:
- `compartment_ocid`
- `vaults`
- `vault_keys`
- `data_bucket_name`
- `bucket_kms_key_id`
- `bucket_auto_tiering`
- `bucket_storage_tier`
- `private_endpoint_name`
- `private_endpoint_prefix`
- `private_endpoint_subnet_id`
- `private_endpoint_subnet_key`
- `private_endpoint_nsg_ids`
- `create_stream_pool`
- `stream_pool_id`
- `stream_pool_name`
- `streaming_kms_key_id`
- `streaming_private_endpoint_subnet_id`
- `streaming_private_endpoint_nsg_ids`
- ... plus 1 more deployment-specific inputs in `variables.tf`

Important enable flags and switches:
- `enable_vault`
- `enable_default_vault`
- `enable_default_key`
- `enable_data_bucket`
- `enable_bucket_events`
- `enable_bucket_versioning`
- `enable_object_storage_private_endpoint`
- `enable_streaming`

Review `terraform.tfvars.example` first, then create a local ignored `terraform.tfvars` for real OCIDs, CIDRs, names, recipients, and enable flags.

## Outputs And Hand-Off

This deployment exports the following outputs from `outputs.tf`:

- `blueprint_name`
- `name_prefix`
- `resource_ids`
- `vcn_id`
- `subnet_ids`
- `vault_ids`
- `vault_key_ids`
- `data_bucket_name`
- `object_storage_private_endpoint_id`
- `stream_pool_id`
- `stream_ids`

Use these outputs as the contract for downstream blueprints, runbooks, customer notes, or manual hand-off. If an output name changes, update dependent documentation and consumers in the same change.

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
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for customer-facing or shared environments.

## Deployment Order

1. Deploy core and private networking first.
2. Review object storage, private endpoint, vault, and streaming settings.
3. Populate `terraform.tfvars` with data-platform inputs.
4. Run plan and review data access paths.
5. Apply, then hand outputs to data product teams.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and output contract, operational boundaries, review checklist, and the expected Terraform + Ansible output at the end of the deployment.

## Review Before Apply

- Confirm private endpoint subnet and DNS behavior.
- Review bucket naming, encryption, and access policies.
- Check streaming partitions, retention, and cost impact.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
