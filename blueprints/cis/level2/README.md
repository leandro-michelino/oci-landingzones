# CIS Level 2 Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/cis/level2`. It tells you what the
blueprint builds, which inputs deserve a real review, how to run Terraform or the local
Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/cis/level2` |
| Best fit | Builds the stricter CIS-aligned landing-zone baseline for regulated environments where hardened controls and tighter operational review are expected. |
| Terraform shape | `core` |
| Inputs to settle first | `parent_compartment_ocid`, `audit_retention_period_days`, `cloud_guard_detector_recipe_ids`, `cloud_guard_responder_recipe_ids`, `vaults`, `vault_keys`, `default_security_zone_recipe_id`, plus 9 more |
| Outputs to hand off | `blueprint_name`, `cis_level`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`, `group_names`, plus 9 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Builds the stricter CIS-aligned landing-zone baseline for regulated environments where
hardened controls and tighter operational review are expected.

## When To Use This Deployment

- A customer explicitly selects CIS Level 2.
- Security teams require a stronger baseline than Level 1.
- Tenancy-wide logging, monitoring, vault, VSS, and security-zone choices must be reviewed together.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `core` | `blueprints/core @ v0.2.0` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/cis/level2/
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
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `parent_compartment_ocid` | Parent compartment OCID for the CIS landing zone root compartment. Defaults to tenancy_ocid when omitted. |
| `audit_retention_period_days` | Tenancy audit retention in days. |
| `cloud_guard_detector_recipe_ids` | Detector recipe OCIDs attached to the default Cloud Guard target. |
| `cloud_guard_responder_recipe_ids` | Responder recipe OCIDs attached to the default Cloud Guard target. |
| `vaults` | Additional OCI Vaults keyed by logical name. |
| `vault_keys` | KMS keys keyed by logical name. Use vault_key for module-created vaults or vault_management_endpoint for existing vaults. |
| `default_security_zone_recipe_id` | Security recipe OCID used by the default CIS landing zone Security Zone. |
| `default_security_zone_recipe_display_name` | Optional security recipe display name to look up for the default CIS landing zone Security Zone when recipe OCID is not supplied. |
| `security_zones` | Additional Security Zones keyed by logical name. |
| `monitoring_subscriptions` | ONS subscriptions for monitoring keyed by logical name. Endpoints should be supplied from local ignored tfvars. |
| `monitoring_alarms` | OCI Monitoring alarms keyed by logical name. |
| `budget_amount` | Optional amount for the default CIS landing zone budget. Leave null to skip budget creation. |
| `budget_alert_recipients` | Email recipients for the default CIS budget alert rule. |
| `budgets` | Additional OCI Budgets keyed by logical name. |
| `event_subscriptions` | ONS subscriptions keyed by logical name. Endpoints should be supplied from local ignored tfvars. |
| `event_rules` | Additional or overriding OCI Events rules keyed by logical name. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_delete` | Allow Terraform to delete CIS landing zone compartments during destroy. Review carefully for production. |
| `enable_tagging` | Create the CIS landing zone tag namespace, tag definitions, and tag defaults. |
| `enable_tag_defaults` | Create tag defaults for CIS landing zone compartments. |
| `enable_audit_retention` | Configure tenancy audit retention for the CIS landing zone. |
| `cloud_guard_enabled` | Enable Cloud Guard configuration and a default CIS landing zone target. |
| `vault_enabled` | Create OCI Vault and KMS keys for the CIS landing zone. |
| `enable_default_vault_key` | Create the default landing zone master encryption key when the default vault is created. |
| `security_zones_enabled` | Create OCI Security Zones for protected CIS landing zone compartments. |
| `vss_enabled` | Create OCI Vulnerability Scanning Service resources for the CIS landing zone. |
| `enable_default_host_scan` | Create the default VSS host scan recipe and target when VSS is enabled. |
| `monitoring_enabled` | Create OCI Monitoring alarms and optional notification resources for the CIS landing zone. |
| `enable_events` | Create OCI Events and Notifications resources for CIS governance notifications. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `cis_level` | Fixed CIS OCI Benchmark profile for this blueprint. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `root_compartment_id` | OCID of the CIS landing zone root compartment. |
| `compartment_ids` | Map of CIS landing zone compartment keys to OCIDs. |
| `group_names` | Map of IAM group keys to names. |
| `policy_names` | Map of IAM policy keys to names. |
| `vault_ids` | Map of vault keys to OCIDs. |
| `vault_key_ids` | Map of KMS key keys to OCIDs. |
| `security_zone_ids` | Map of Security Zone keys to OCIDs. |
| `vss_host_scan_target_ids` | Map of VSS host scan target keys to OCIDs. |
| `budget_ids` | Map of budget keys to OCIDs. |
| `event_rule_ids` | Map of event rule keys to OCIDs. |
| `event_notification_topic_ids` | Map of event notification topic keys to OCIDs. |
| `monitoring_alarm_ids` | Map of monitoring alarm keys to OCIDs. |

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

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

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

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

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

The validator checks Terraform formatting, required deployment README files, required
architecture README sections, `terraform init -backend=false`, `terraform validate`, root
Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and
cleanup of generated Terraform artifacts.
