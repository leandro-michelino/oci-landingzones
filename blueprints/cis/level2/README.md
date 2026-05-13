# CIS Level 2 Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This deployment README belongs only to `blueprints/cis/level2`. It is the run-facing guide for this blueprint; the detailed ASCII design lives beside it in `architecture/README.md`.

## Deployment Purpose

Builds the stricter CIS-aligned landing-zone baseline for regulated environments where hardened controls and tighter operational review are expected.

## When To Use This Deployment

- A customer explicitly selects CIS Level 2.
- Security teams require a stronger baseline than Level 1.
- Tenancy-wide logging, monitoring, vault, VSS, and security-zone choices must be reviewed together.

## What This Deploys

The Terraform in this folder wires the following local components:

- Terraform module `core`

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/cis/level2/
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
- `audit_retention_period_days`
- `cloud_guard_enabled`
- `cloud_guard_detector_recipe_ids`
- `cloud_guard_responder_recipe_ids`
- `vault_enabled`
- `vaults`
- `vault_keys`
- `security_zones_enabled`
- `default_security_zone_recipe_id`
- `default_security_zone_recipe_display_name`
- `security_zones`
- `vss_enabled`
- `monitoring_enabled`
- `monitoring_subscriptions`
- `monitoring_alarms`
- `budget_amount`
- `budget_alert_recipients`
- ... plus 3 more deployment-specific inputs in `variables.tf`

Important enable flags and switches:
- `enable_delete`
- `enable_tagging`
- `enable_tag_defaults`
- `enable_audit_retention`
- `cloud_guard_enabled`
- `vault_enabled`
- `enable_default_vault_key`
- `security_zones_enabled`
- `vss_enabled`
- `enable_default_host_scan`
- `monitoring_enabled`
- `enable_events`

Review `terraform.tfvars.example` first, then create a local ignored `terraform.tfvars` for real OCIDs, CIDRs, names, recipients, and enable flags.

## Outputs And Hand-Off

This deployment exports the following outputs from `outputs.tf`:

- `blueprint_name`
- `cis_level`
- `name_prefix`
- `resource_ids`
- `root_compartment_id`
- `compartment_ids`
- `group_names`
- `policy_names`
- `vault_ids`
- `vault_key_ids`
- `security_zone_ids`
- `vss_host_scan_target_ids`
- `budget_ids`
- `event_rule_ids`
- `event_notification_topic_ids`
- `monitoring_alarm_ids`

Use these outputs as the contract for downstream blueprints, runbooks, customer notes, or manual hand-off. If an output name changes, update dependent documentation and consumers in the same change.

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/cis/level2
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/cis/level2
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

- Do not use Level 2 as a casual default.
- Review Security Zone and delete-protection behavior before apply.
- Confirm every exception is documented before rollout.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
