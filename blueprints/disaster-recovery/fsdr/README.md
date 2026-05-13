# Full Stack Disaster Recovery

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This deployment README belongs only to `blueprints/disaster-recovery/fsdr`. It is the run-facing guide for this blueprint; the detailed ASCII design lives beside it in `architecture/README.md`.

## Deployment Purpose

Creates the OCI Full Stack Disaster Recovery scaffolding for primary and standby protection groups, log buckets, and DR plan wiring.

## When To Use This Deployment

- A workload needs OCI FSDR orchestration.
- Primary and standby regions are already selected.
- Protection groups and plan execution need a documented review path.

## What This Deploys

The Terraform in this folder wires the following local components:

- Terraform resource `oci_objectstorage_bucket.primary_dr_logs`
- Terraform resource `oci_objectstorage_bucket.standby_dr_logs`
- Terraform resource `oci_disaster_recovery_dr_protection_group.primary`
- Terraform resource `oci_disaster_recovery_dr_protection_group.standby`
- Terraform resource `oci_disaster_recovery_dr_plan.primary`
- Terraform data source `oci_objectstorage_namespace.primary`
- Terraform data source `oci_objectstorage_namespace.standby`

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/disaster-recovery/fsdr/
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
- `region`
- `oci_config_profile`
- `org`
- `environment`
- `region_key`
- `defined_tags`
- `freeform_tags`

Deployment-specific inputs to review:
- `standby_region`
- `standby_region_key`
- `compartment_ocid`
- `primary_compartment_ocid`
- `standby_compartment_ocid`
- `primary_log_bucket_name`
- `standby_log_bucket_name`
- `log_bucket_storage_tier`
- `primary_dr_protection_group_name`
- `standby_dr_protection_group_name`
- `primary_members`
- `standby_members`
- `dr_plan_display_name`
- `dr_plan_type`

Important enable flags and switches:
- `enable_dr_log_buckets`
- `enable_object_events`
- `enable_bucket_versioning`
- `enable_dr_protection_groups`
- `enable_dr_plan`

Review `terraform.tfvars.example` first, then create a local ignored `terraform.tfvars` for real OCIDs, CIDRs, names, recipients, and enable flags.

## Outputs And Hand-Off

This deployment exports the following outputs from `outputs.tf`:

- `blueprint_name`
- `name_prefix`
- `standby_name_prefix`
- `resource_ids`
- `primary_dr_protection_group_id`
- `standby_dr_protection_group_id`
- `primary_log_bucket_name`
- `standby_log_bucket_name`
- `primary_dr_plan_id`

Use these outputs as the contract for downstream blueprints, runbooks, customer notes, or manual hand-off. If an output name changes, update dependent documentation and consumers in the same change.

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/disaster-recovery/fsdr
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/disaster-recovery/fsdr
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for customer-facing or shared environments.

## Deployment Order

1. Confirm primary and standby regions.
2. Review protected resource IDs and DR group membership.
3. Populate `terraform.tfvars` with region and DR inputs.
4. Run plan and review FSDR objects.
5. Apply infrastructure only; keep failover execution in the runbook flow.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and output contract, operational boundaries, review checklist, and the expected Terraform + Ansible output at the end of the deployment.

## Review Before Apply

- Keep drills and failover execution outside normal Terraform apply until reviewed.
- Confirm primary and standby region providers.
- Validate protected resources and IAM permissions before activation.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
