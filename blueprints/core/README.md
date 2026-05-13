# Core Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This deployment README belongs only to `blueprints/core`. It is the run-facing guide for this blueprint; the detailed ASCII design lives beside it in `architecture/README.md`.

## Deployment Purpose

Builds the shared OCI foundation: compartments, IAM, tagging, logging, Cloud Guard, Vault/KMS, Security Zones, VSS, budgets, events, and monitoring.

## When To Use This Deployment

- You are starting a new landing zone.
- Other blueprints need shared compartments, IAM groups, policies, tags, and security services.
- The customer wants a governed OCI foundation before workload networking.

## What This Deploys

The Terraform in this folder wires the following local components:

- Terraform module `compartments`
- Terraform module `tagging`
- Terraform module `logging`
- Terraform module `cloud_guard`
- Terraform module `vault`
- Terraform module `security_zones`
- Terraform module `vss`
- Terraform module `budgets`
- Terraform module `events`
- Terraform module `monitoring`
- Terraform module `groups`
- Terraform module `dynamic_groups`
- Terraform module `policies`

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/core/
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
- `cis_level`
- `parent_compartment_ocid`
- `tag_default_values`
- `tag_namespace_name`
- `required_tag_defaults`
- `log_groups`
- `service_logs`
- `vcn_flow_logs`
- `logging_saved_searches`
- `audit_retention_period_days`
- `cloud_guard_enabled`
- `cloud_guard_status`
- `cloud_guard_reporting_region`
- `cloud_guard_self_manage_resources`
- `cloud_guard_enable_default_target`
- `cloud_guard_detector_recipe_ids`
- `cloud_guard_responder_recipe_ids`
- `cloud_guard_targets`
- ... plus 39 more deployment-specific inputs in `variables.tf`

Important enable flags and switches:
- `enable_delete`
- `enable_tagging`
- `enable_tag_defaults`
- `enable_logging`
- `enable_audit_retention`
- `cloud_guard_enabled`
- `vault_enabled`
- `enable_default_vault`
- `enable_default_vault_key`
- `security_zones_enabled`
- `enable_default_security_zone`
- `vss_enabled`
- `enable_default_host_scan`
- `enable_budgets`
- `enable_default_budget`
- `enable_events`
- `enable_default_event_topic`
- `enable_default_event_rules`
- ... plus 5 more enable flags in `variables.tf`

Review `terraform.tfvars.example` first, then create a local ignored `terraform.tfvars` for real OCIDs, CIDRs, names, recipients, and enable flags.

## Outputs And Hand-Off

This deployment exports the following outputs from `outputs.tf`:

- `blueprint_name`
- `name_prefix`
- `cis_level`
- `root_compartment_id`
- `compartment_ids`
- `network_compartment_id`
- `security_compartment_id`
- `governance_compartment_id`
- `workloads_compartment_id`
- `compartment_names`
- `tag_namespace_id`
- `tag_namespace_name`
- `tag_definition_ids`
- `log_group_ids`
- `log_group_names`
- `service_log_ids`
- `logging_saved_search_ids`
- `audit_configuration_id`
- `cloud_guard_configuration_id`
- `cloud_guard_target_ids`
- `cloud_guard_target_names`
- `vault_ids`
- `vault_management_endpoints`
- `vault_crypto_endpoints`
- `vault_key_ids`
- `security_zone_ids`
- `security_zone_names`
- `security_zone_target_ids`
- `vss_host_scan_recipe_ids`
- `vss_host_scan_target_ids`
- `vss_container_scan_recipe_ids`
- `vss_container_scan_target_ids`
- `budget_ids`
- `budget_names`
- `budget_alert_rule_ids`
- `event_notification_topic_ids`
- `event_notification_topic_names`
- `event_subscription_ids`
- `event_rule_ids`
- `event_rule_names`
- `monitoring_notification_topic_ids`
- `monitoring_subscription_ids`
- `monitoring_alarm_ids`
- `monitoring_alarm_names`
- `group_ids`
- `group_names`
- `dynamic_group_ids`
- `dynamic_group_names`
- `policy_ids`
- `policy_names`
- `resource_ids`

Use these outputs as the contract for downstream blueprints, runbooks, customer notes, or manual hand-off. If an output name changes, update dependent documentation and consumers in the same change.

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/core
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/core
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for customer-facing or shared environments.

## Deployment Order

1. Bootstrap state and OCI credentials.
2. Populate `terraform.tfvars` from the example.
3. Review governance, IAM, logging, security, and monitoring choices.
4. Run plan, then apply after review.
5. Hand outputs to network, operating-entity, compliance, or extension deployments.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and output contract, operational boundaries, review checklist, and the expected Terraform + Ansible output at the end of the deployment.

## Review Before Apply

- Review tenancy-wide controls before apply.
- Confirm notification topics, budget alerts, and monitoring recipients.
- Keep core outputs stable because downstream blueprints consume them.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
