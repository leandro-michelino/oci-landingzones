# Telco Cloud Native Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This deployment README belongs only to `blueprints/industry/telco-cloud-native`. It is the run-facing guide for this blueprint; the detailed ASCII design lives beside it in `architecture/README.md`.

## Deployment Purpose

Composes network, vault, OKE, monitoring, and OS Management foundations for telco-oriented cloud-native workloads.

## When To Use This Deployment

- Telco workloads need a cloud-native landing-zone baseline.
- OKE, network, operations, and security services need one review surface.
- Platform teams need repeatable service enablement.

## What This Deploys

The Terraform in this folder wires the following local components:

- Terraform module `network`
- Terraform module `vault`
- Terraform module `oke`
- Terraform module `monitoring`
- Terraform module `os_management`

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/industry/telco-cloud-native/
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
- `cluster_label`
- `kubernetes_version`
- `oke_endpoint_subnet_key`
- `oke_service_lb_subnet_key`
- `oke_node_subnet_key`
- `node_shape`
- `node_shape_ocpus`
- `node_shape_memory_in_gbs`
- `ssh_public_key`
- `monitoring_notification_topics`
- `monitoring_subscriptions`
- `monitoring_alarms`
- `os_managed_instance_groups`
- `os_scheduled_jobs`

Important enable flags and switches:
- `enable_vault`
- `enable_default_vault`
- `enable_default_key`
- `enable_oke_cluster`
- `enable_oke_node_pool`
- `enable_monitoring`
- `enable_default_monitoring_topic`
- `enable_os_management`

Review `terraform.tfvars.example` first, then create a local ignored `terraform.tfvars` for real OCIDs, CIDRs, names, recipients, and enable flags.

## Outputs And Hand-Off

This deployment exports the following outputs from `outputs.tf`:

- `blueprint_name`
- `name_prefix`
- `resource_ids`
- `hub_vcn_id`
- `drg_id`
- `hub_subnet_ids`
- `oke_cluster_id`
- `oke_node_pool_id`
- `vault_ids`
- `monitoring_alarm_ids`
- `os_management_resource_ids`

Use these outputs as the contract for downstream blueprints, runbooks, customer notes, or manual hand-off. If an output name changes, update dependent documentation and consumers in the same change.

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/industry/telco-cloud-native
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/industry/telco-cloud-native
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for customer-facing or shared environments.

## Deployment Order

1. Review the local README and architecture.
2. Populate `terraform.tfvars`.
3. Run plan.
4. Apply after review.
5. Hand outputs to the next owner.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and output contract, operational boundaries, review checklist, and the expected Terraform + Ansible output at the end of the deployment.

## Review Before Apply

- Confirm telco workload network boundaries.
- Review OKE, OS Management, and monitoring enable flags.
- Check quotas, service limits, and region readiness.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
