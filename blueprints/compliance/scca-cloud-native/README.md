# SCCA Cloud Native Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This deployment README belongs only to `blueprints/compliance/scca-cloud-native`. It is the run-facing guide for this blueprint; the detailed ASCII design lives beside it in `architecture/README.md`.

## Deployment Purpose

Combines core governance, controlled networking, and operations hooks for a SCCA-style cloud-native landing-zone pattern.

## When To Use This Deployment

- A regulated workload needs a SCCA-style control boundary.
- Security, network, and platform teams need one reviewable composition.
- OS Management, network inspection, and baseline controls are part of the landing-zone conversation.

## What This Deploys

The Terraform in this folder wires the following local components:

- Terraform module `core`
- Terraform module `network`
- Terraform module `os_management`

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/compliance/scca-cloud-native/
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
- `parent_compartment_ocid`
- `network_compartment_ocid`
- `vault_enabled`
- `security_zones_enabled`
- `default_security_zone_recipe_id`
- `vss_enabled`
- `monitoring_enabled`
- `os_managed_instance_groups`
- `os_scheduled_jobs`

Important enable flags and switches:
- `enable_delete`
- `enable_tagging`
- `enable_tag_defaults`
- `vault_enabled`
- `enable_default_vault_key`
- `security_zones_enabled`
- `vss_enabled`
- `enable_default_host_scan`
- `enable_events`
- `monitoring_enabled`
- `enable_network_firewall`
- `enable_os_management`

Review `terraform.tfvars.example` first, then create a local ignored `terraform.tfvars` for real OCIDs, CIDRs, names, recipients, and enable flags.

## Outputs And Hand-Off

This deployment exports the following outputs from `outputs.tf`:

- `blueprint_name`
- `name_prefix`
- `resource_ids`
- `root_compartment_id`
- `compartment_ids`
- `network_resource_ids`
- `os_management_resource_ids`

Use these outputs as the contract for downstream blueprints, runbooks, customer notes, or manual hand-off. If an output name changes, update dependent documentation and consumers in the same change.

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/compliance/scca-cloud-native
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/compliance/scca-cloud-native
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for customer-facing or shared environments.

## Deployment Order

1. Confirm the selected compliance profile.
2. Review tenancy-wide controls, monitoring, vault, VSS, and event settings.
3. Populate `terraform.tfvars` with security and notification inputs.
4. Run plan and review control impact.
5. Apply only after the security owner accepts the profile.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and output contract, operational boundaries, review checklist, and the expected Terraform + Ansible output at the end of the deployment.

## Review Before Apply

- Confirm the selected inspection model and OS Management scope.
- Review optional paid services and quotas before enabling them.
- Treat the architecture page as the customer review artifact.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
