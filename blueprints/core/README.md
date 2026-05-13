# Core Landing Zone Blueprint

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

The core blueprint is the mandatory baseline for every OCI landing zone deployment. It
creates the shared compartments, tags, and IAM foundation used by the other
blueprints.

## What It Does

Core is the base layer everything else expects. It creates the compartment shape,
baseline tags, governance log groups, IAM groups, dynamic groups, and policies
that networking, security, compliance, operating-entity, and extension
blueprints build on top of.

## Why Use It

Use core when you need the boring-but-critical foundation in place before anyone starts
building fancy stuff. It gives the rest of the repo a stable place to hang compartments,
IAM, tags, and policy outputs.

## When To Use It

- You are starting a new landing zone.
- Other blueprints need shared compartment or IAM outputs.
- You want a repeatable baseline before handing space to app teams.

## Use Cases

- Start a new OCI landing zone from a clean baseline.
- Create the shared compartments and IAM roles before workload onboarding.
- Provide stable outputs for networking, security, governance, and operations.
- Run ephemeral real-deployment tests in a parent compartment.

Architecture notes live in `architecture/README.md`.

## Responsibilities

- Root landing zone compartment.
- Network, security, governance, and workload compartments.
- Landing zone tag namespace, tag definitions, and tag defaults.
- Governance log groups for audit, network, service, and security logs.
- Optional VCN flow logs, OCI service logs, saved searches, and audit retention.
- Optional Cloud Guard configuration and landing zone target.
- Optional Vault/KMS foundation and Security Zones.
- Optional Vulnerability Scanning Service host and container scan recipes and
  targets.
- Optional governance budgets, alert rules, Events rules, notification topics,
  and subscriptions.
- Optional Monitoring alarms, notification topics, and subscriptions.
- Platform IAM groups and least-privilege policies.
- Dynamic groups for platform automation and workload resource principals.

## Module Order

1. `modules/iam/compartments`
2. `modules/governance/tagging`
3. `modules/governance/logging`
4. `modules/security/cloud-guard`
5. `modules/security/vault`
6. `modules/security/security-zones`
7. `modules/security/vss`
8. `modules/governance/budgets`
9. `modules/governance/events`
10. `modules/operations/monitoring`
11. `modules/iam/groups`
12. `modules/iam/dynamic-groups`
13. `modules/iam/policies`

## Expected Outputs

- `root_compartment_id`
- `network_compartment_id`
- `security_compartment_id`
- `governance_compartment_id`
- `workloads_compartment_id`
- `compartment_ids`
- `compartment_names`
- `tag_definition_ids`
- `log_group_ids`
- `service_log_ids`
- `logging_saved_search_ids`
- `audit_configuration_id`
- `cloud_guard_configuration_id`
- `cloud_guard_target_ids`
- `vault_ids`
- `vault_key_ids`
- `security_zone_ids`
- `vss_host_scan_target_ids`
- `vss_container_scan_target_ids`
- `budget_ids`
- `budget_alert_rule_ids`
- `event_notification_topic_ids`
- `event_subscription_ids`
- `event_rule_ids`
- `monitoring_alarm_ids`
- `monitoring_notification_topic_ids`
- `group_ids`
- `group_names`
- `dynamic_group_ids`
- `dynamic_group_names`
- `policy_ids`
- `policy_names`
- `tag_namespace_id`

## Implementation Notes

- Compartments are created before tag defaults because tag defaults attach to
  compartment OCIDs.
- Identity resources are created through the home-region OCI provider alias. Set
  `home_region` when the workload region is not the tenancy home region.
- `parent_compartment_ocid` can be used for ephemeral tests and should be kept in local
  ignored variable files.
- OCI tag definition deletes are slow because OCI Identity retires and deletes them
  asynchronously in the home region. Use `enable_tagging = false` for fast ephemeral
  tests that do not need defined tags.
- Use `enable_tag_defaults = false` when a test needs tag definitions but does not need
  tag defaults on every compartment.
- Core creates governance log groups by default. Service logs and VCN flow logs
  require real source resource OCIDs, so configure `service_logs` and
  `vcn_flow_logs` in local ignored tfvars files.
- Generic core keeps tenancy audit retention disabled by default because it is
  tenancy-wide. CIS Level 1 and Level 2 wrappers enable it by default and expose
  `audit_retention_period_days`.
- Generic core keeps Cloud Guard disabled by default because the service
  configuration is tenancy-wide. CIS Level 1 and Level 2 wrappers enable it by
  default. Add approved detector and responder recipe OCIDs through local
  ignored tfvars when custom target recipes are required.
- Generic core keeps Vault/KMS disabled by default because key ownership,
  protection mode, and rotation windows are environment-specific. Set
  `vault_enabled = true` to create the default vault and key, or use `vaults`
  and `vault_keys` for explicit definitions.
- Generic core keeps Security Zones disabled by default because they enforce
  hard guardrails on the protected compartment tree. Set
  `security_zones_enabled = true` with an approved recipe OCID or display-name
  lookup before creating the default landing zone Security Zone.
- Generic core keeps VSS disabled by default because scan scope should be
  approved per environment. Set `vss_enabled = true` to create the default host
  scan recipe and target for the workloads compartment, or use the host and
  container scan maps for explicit scope.
- Generic core keeps budgets disabled by default because spend thresholds and
  recipients are environment-specific. Set `enable_budgets = true` and
  `default_budget_amount` for the default root-scope budget, or use `budgets`
  for explicit budget definitions.
- Generic core keeps Events disabled by default. CIS Level 1 and Level 2
  wrappers enable the default governance topic and IAM change rules, while
  subscriptions still require explicit local endpoints.
- Generic core keeps Monitoring alarms disabled by default because metric
  queries and notification destinations are environment-specific. Set
  `monitoring_enabled = true`, add subscriptions, and define alarms in local
  ignored tfvars files.
- Use the IAM default toggles only in quota-constrained tests. Normal landing zone
  deployments should leave the IAM foundation enabled.
- IAM policies are attached to the parent compartment and use compartment paths for the
  landing zone root and child compartments.
- IAM policies should avoid granting workload teams permissions outside their operating
  entity compartments.
- Core should expose stable outputs for networking, operating entity, and extension
  blueprints.
