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

> [DIAGRAM REQUIRED] `architecture/core.excalidraw`
>
> Status: TODO - create this diagram before using the blueprint for a production
> customer review.

## Responsibilities

- Root landing zone compartment.
- Network, security, governance, and workload compartments.
- Landing zone tag namespace, tag definitions, and tag defaults.
- Governance log groups for audit, network, service, and security logs.
- Optional VCN flow logs, OCI service logs, saved searches, and audit retention.
- Platform IAM groups and least-privilege policies.
- Dynamic groups for platform automation and workload resource principals.
- Planned later: Cloud Guard, Security Zones, Vault, events, budgets, and
  monitoring alarms.

## Module Order

1. `modules/iam/compartments`
2. `modules/governance/tagging`
3. `modules/governance/logging`
4. `modules/iam/groups`
5. `modules/iam/dynamic-groups`
6. `modules/iam/policies`

Planned later:

1. `modules/security/vault`
2. `modules/security/cloud-guard`
3. `modules/security/security-zones`
4. `modules/governance/events`
5. `modules/governance/budgets`
6. `modules/operations/monitoring`

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
- `group_ids`
- `group_names`
- `dynamic_group_ids`
- `dynamic_group_names`
- `policy_ids`
- `policy_names`
- `tag_namespace_id`

Planned outputs for later core phases include Vault, Cloud Guard, Security
Zones, events, budgets, and monitoring identifiers.

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
- Use the IAM default toggles only in quota-constrained tests. Normal landing zone
  deployments should leave the IAM foundation enabled.
- IAM policies are attached to the parent compartment and use compartment paths for the
  landing zone root and child compartments.
- IAM policies should avoid granting workload teams permissions outside their operating
  entity compartments.
- Core should expose stable outputs for networking, operating entity, and extension
  blueprints.
