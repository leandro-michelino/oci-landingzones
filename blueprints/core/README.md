# Core Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/core`. It tells you what the blueprint
builds, which inputs deserve a real review, how to run Terraform or the local Ansible
wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/core` |
| Best fit | Builds the shared OCI foundation: compartments, IAM, tagging, logging, Cloud Guard, Vault/KMS, Security Zones, VSS, budgets, events, and monitoring. |
| Terraform shape | `compartments`, `tagging`, `logging`, `cloud_guard`, `vault`, plus 8 more |
| Inputs to settle first | `cis_level`, `parent_compartment_ocid`, `tag_default_values`, `tag_namespace_name`, `required_tag_defaults`, `log_groups`, `service_logs`, plus 43 more |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `cis_level`, `root_compartment_id`, `compartment_ids`, `network_compartment_id`, `security_compartment_id`, plus 44 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Builds the shared OCI foundation: compartments, IAM, tagging, logging, Cloud Guard,
Vault/KMS, Security Zones, VSS, budgets, events, and monitoring.

## When To Use This Deployment

- You are starting a new landing zone.
- Other blueprints need shared compartments, IAM groups, policies, tags, and security services.
- The customer wants a governed OCI foundation before workload networking.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `compartments` | `modules/iam/compartments @ v0.2.0` |
| Module | `tagging` | `modules/governance/tagging @ v0.2.0` |
| Module | `logging` | `modules/governance/logging @ v0.2.0` |
| Module | `cloud_guard` | `modules/security/cloud-guard @ v0.2.0` |
| Module | `vault` | `modules/security/vault @ v0.2.0` |
| Module | `security_zones` | `modules/security/security-zones @ v0.2.0` |
| Module | `vss` | `modules/security/vss @ v0.2.0` |
| Module | `budgets` | `modules/governance/budgets @ v0.2.0` |
| Module | `events` | `modules/governance/events @ v0.2.0` |
| Module | `monitoring` | `modules/operations/monitoring @ v0.2.0` |
| Module | `groups` | `modules/iam/groups @ v0.2.0` |
| Module | `dynamic_groups` | `modules/iam/dynamic-groups @ v0.2.0` |
| Module | `policies` | `modules/iam/policies @ v0.2.0` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/core/
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
| `oci_config_profile` | Optional OCI CLI config profile for local execution. Leave null to use the provider default profile. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `cis_level` | Optional CIS OCI Benchmark profile selected by dedicated CIS wrapper blueprints. |
| `parent_compartment_ocid` | Parent compartment OCID for the landing zone root compartment. Defaults to tenancy_ocid when omitted. |
| `tag_default_values` | Optional overrides for default values in the landing zone tag namespace. |
| `tag_namespace_name` | Optional tag namespace name override. Useful for ephemeral tests where tag namespace names must stay unique. |
| `required_tag_defaults` | Tag names whose tag defaults should be marked required. |
| `log_groups` | Additional or overriding governance log groups keyed by logical name. |
| `service_logs` | OCI service logs keyed by logical name. |
| `vcn_flow_logs` | Convenience VCN flow log definitions keyed by logical name. |
| `logging_saved_searches` | Logging saved searches keyed by logical name. |
| `audit_retention_period_days` | Tenancy audit retention in days when enable_audit_retention is true. |
| `cloud_guard_reporting_region` | Cloud Guard reporting region. Defaults to region when omitted. |
| `cloud_guard_self_manage_resources` | Let Cloud Guard manage required service resources. |
| `cloud_guard_enable_default_target` | Create a default Cloud Guard target for the landing zone root compartment. |
| `cloud_guard_detector_recipe_ids` | Detector recipe OCIDs attached to the default Cloud Guard target. |
| `cloud_guard_responder_recipe_ids` | Responder recipe OCIDs attached to the default Cloud Guard target. |
| `cloud_guard_targets` | Additional Cloud Guard targets keyed by logical name. |
| `default_vault_type` | Vault type for the default landing zone vault. |
| `default_vault_key_algorithm` | Key shape algorithm for the default landing zone key. |
| `default_vault_key_length` | Key shape length for the default landing zone key. |
| `vaults` | Additional OCI Vaults keyed by logical name. |
| `vault_keys` | KMS keys keyed by logical name. Use vault_key for module-created vaults or vault_management_endpoint for existing vaults. |
| `default_security_zone_recipe_id` | Security recipe OCID used by the default landing zone Security Zone. |
| `default_security_zone_recipe_display_name` | Optional security recipe display name to look up for the default landing zone Security Zone when recipe OCID is not supplied. |
| `default_security_zone_recipe_compartment_ocid` | Compartment OCID used when looking up default_security_zone_recipe_display_name. Defaults to tenancy_ocid. |
| `security_zones` | Additional Security Zones keyed by logical name. |
| `default_host_scan_schedule_type` | Schedule type for the default host scan recipe. |
| `default_host_scan_day_of_week` | Day of week for the default weekly host scan schedule. |
| `default_host_agent_scan_level` | Agent scan level for the default host scan recipe. |
| `default_host_port_scan_level` | Port scan level for the default host scan recipe. |
| `host_scan_recipes` | Host scan recipes keyed by logical name. |
| `host_scan_targets` | Host scan targets keyed by logical name. |
| `container_scan_recipes` | Container image scan recipes keyed by logical name. |
| `container_scan_targets` | Container image scan targets keyed by logical name. |
| `default_budget_amount` | Amount for the default landing zone budget. Leave null to skip the default budget. |
| `default_budget_target_ocids` | Optional set of compartment OCIDs tracked by the default landing zone budget. Defaults to the landing zone root compartment. |
| `default_budget_reset_period` | Reset period for the default landing zone budget. |
| `default_budget_alert_recipients` | Email recipients for the default budget alert rule. Leave empty to create no default alert rule. |
| `default_budget_alert_threshold` | Threshold for the default budget alert rule. |
| `default_budget_alert_threshold_type` | Threshold type for the default budget alert rule. |
| `default_budget_alert_type` | Spend type for the default budget alert rule. |
| `budgets` | Additional OCI Budgets keyed by logical name. |
| `event_notification_topics` | ONS notification topics keyed by logical name. |
| `event_subscriptions` | ONS subscriptions keyed by logical name. Endpoints should be supplied from local ignored tfvars. |
| `event_rules` | Additional or overriding OCI Events rules keyed by logical name. |
| `monitoring_notification_topics` | ONS notification topics for monitoring keyed by logical name. |
| `monitoring_subscriptions` | ONS subscriptions for monitoring keyed by logical name. Endpoints should be supplied from local ignored tfvars. |
| `monitoring_alarms` | OCI Monitoring alarms keyed by logical name. |
| `iam_groups` | Additional or overriding IAM groups keyed by logical role. |
| `iam_dynamic_groups` | Additional or overriding dynamic groups keyed by logical role. |
| `iam_policies` | Additional or overriding IAM policies keyed by logical role. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_delete` | Allow Terraform to delete compartments during destroy. Keep true for ephemeral tests; review carefully for production. |
| `enable_tagging` | Create the landing zone tag namespace, tag definitions, and tag defaults. Disable for fast ephemeral tests. |
| `enable_tag_defaults` | Create tag defaults for the landing zone compartments. Disable for faster tests while keeping tag definitions. |
| `enable_logging` | Create core governance log groups and optional service logs. |
| `enable_audit_retention` | Configure tenancy audit retention. This is tenancy-wide and should be enabled deliberately. |
| `cloud_guard_enabled` | Enable Cloud Guard configuration and a default landing zone target. |
| `cloud_guard_status` | Cloud Guard tenancy status when managed by the core blueprint. |
| `vault_enabled` | Create OCI Vault and KMS keys for the landing zone. |
| `enable_default_vault` | Create the default landing zone vault when vault_enabled is true. |
| `enable_default_vault_key` | Create the default landing zone master encryption key when the default vault is created. |
| `default_vault_key_protection_mode` | Protection mode for the default landing zone key. |
| `security_zones_enabled` | Create OCI Security Zones for protected landing zone compartments. |
| `enable_default_security_zone` | Create the default landing zone Security Zone when a default recipe is provided. |
| `vss_enabled` | Create OCI Vulnerability Scanning Service resources for the landing zone. |
| `enable_default_host_scan` | Create the default host scan recipe and target when VSS is enabled. |
| `enable_budgets` | Create OCI Budgets resources for the landing zone. |
| `enable_default_budget` | Create the default landing zone budget when default_budget_amount is set. |
| `enable_events` | Create OCI Events and Notifications resources for governance notifications. |
| `enable_default_event_topic` | Create the default governance notification topic. |
| `enable_default_event_rules` | Create default IAM governance event rules that publish to the default topic. |
| `monitoring_enabled` | Create OCI Monitoring alarms and optional notification resources. |
| `enable_default_monitoring_topic` | Create the default monitoring notification topic when monitoring is enabled. |
| `enable_default_iam_groups` | Create default landing zone IAM groups. |
| `enable_default_dynamic_groups` | Create default dynamic groups for platform automation and workload instances. |
| `enable_default_iam_policies` | Create default least-privilege IAM policies for the core landing zone. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `cis_level` | Selected CIS OCI Benchmark profile, when this core is wrapped by a CIS blueprint. |
| `root_compartment_id` | OCID of the landing zone root compartment. |
| `compartment_ids` | Map of landing zone compartment keys to OCIDs. |
| `network_compartment_id` | OCID of the landing zone network compartment. |
| `security_compartment_id` | OCID of the landing zone security compartment. |
| `governance_compartment_id` | OCID of the landing zone governance compartment. |
| `workloads_compartment_id` | OCID of the landing zone workloads compartment. |
| `compartment_names` | Map of landing zone compartment keys to display names. |
| `tag_namespace_id` | OCID of the landing zone tag namespace. |
| `tag_namespace_name` | Name of the landing zone tag namespace. |
| `tag_definition_ids` | Map of landing zone tag names to tag definition OCIDs. |
| `log_group_ids` | Map of governance log group keys to OCIDs. |
| `log_group_names` | Map of governance log group keys to display names. |
| `service_log_ids` | Map of governance service log keys to OCIDs. |
| `logging_saved_search_ids` | Map of logging saved search keys to OCIDs. |
| `audit_configuration_id` | OCID of the tenancy audit configuration when managed by the core blueprint. |
| `cloud_guard_configuration_id` | OCID of the Cloud Guard configuration when managed by the core blueprint. |
| `cloud_guard_target_ids` | Map of Cloud Guard target keys to OCIDs. |
| `cloud_guard_target_names` | Map of Cloud Guard target keys to display names. |
| `vault_ids` | Map of vault keys to OCIDs. |
| `vault_management_endpoints` | Map of vault keys to management endpoints. |
| `vault_crypto_endpoints` | Map of vault keys to crypto endpoints. |
| `vault_key_ids` | Map of KMS key keys to OCIDs. |
| `security_zone_ids` | Map of Security Zone keys to OCIDs. |
| `security_zone_names` | Map of Security Zone keys to display names. |
| `security_zone_target_ids` | Map of Security Zone keys to target OCIDs. |
| `vss_host_scan_recipe_ids` | Map of VSS host scan recipe keys to OCIDs. |
| `vss_host_scan_target_ids` | Map of VSS host scan target keys to OCIDs. |
| `vss_container_scan_recipe_ids` | Map of VSS container scan recipe keys to OCIDs. |
| `vss_container_scan_target_ids` | Map of VSS container scan target keys to OCIDs. |
| `budget_ids` | Map of budget keys to OCIDs. |
| `budget_names` | Map of budget keys to display names. |
| `budget_alert_rule_ids` | Map of budget alert rule keys to OCIDs. |
| `event_notification_topic_ids` | Map of event notification topic keys to OCIDs. |
| `event_notification_topic_names` | Map of event notification topic keys to names. |
| `event_subscription_ids` | Map of event subscription keys to OCIDs. |
| `event_rule_ids` | Map of event rule keys to OCIDs. |
| `event_rule_names` | Map of event rule keys to display names. |
| `monitoring_notification_topic_ids` | Map of monitoring notification topic keys to OCIDs. |
| `monitoring_subscription_ids` | Map of monitoring subscription keys to OCIDs. |
| `monitoring_alarm_ids` | Map of monitoring alarm keys to OCIDs. |
| `monitoring_alarm_names` | Map of monitoring alarm keys to display names. |
| `group_ids` | Map of IAM group keys to OCIDs. |
| `group_names` | Map of IAM group keys to names. |
| `dynamic_group_ids` | Map of dynamic group keys to OCIDs. |
| `dynamic_group_names` | Map of dynamic group keys to names. |
| `policy_ids` | Map of IAM policy keys to OCIDs. |
| `policy_names` | Map of IAM policy keys to names. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |

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

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

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

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

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

The validator checks Terraform formatting, required deployment README files, required
architecture README sections, `terraform init -backend=false`, `terraform validate`, root
Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and
cleanup of generated Terraform artifacts.
