# Cost Optimization

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/operations/cost-optimization`.
It explains what the blueprint builds, which FinOps inputs need a real decision,
how to run Terraform or the local Ansible wrappers, and where to review the
detailed ASCII architecture.

## At A Glance

| Item | Details |
|---|---|
| Folder | `blueprints/operations/cost-optimization` |
| Best fit | Cost attribution, budget guardrails, FinOps notifications, optional Optimizer profiles, and finance/platform hand-off. |
| Terraform shape | Governance tagging, budgets, ONS notifications, optional Monitoring alarms, optional Optimizer profile/enrollment, optional IAM policy. |
| Inputs to settle first | Target compartments, cost-center taxonomy, budget amounts, alert recipients, notification channels, Optimizer scope, and FinOps policy statements. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `tag_namespace_id`, `budget_ids`, `budget_alert_rule_ids`, `notification_topic_ids`, `monitoring_alarm_ids`, `optimizer_profile_ids`, `access_policy_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys a FinOps control layer for an OCI landing zone: cost-tracking tags,
optional tag defaults, budgets, budget alert rules, notification topics,
optional Monitoring alarms, optional Optimizer profiles, and an optional access
policy for the finance or platform team.

## When To Use This Deployment

- A landing zone is live and teams need explicit cost-center and owner tags.
- Finance wants per-compartment budget thresholds before workloads scale up.
- Platform teams need a standard notification topic for budget and anomaly
  signals.
- OCI Optimizer recommendations should be scoped to approved compartments or
  tag sets.
- A FinOps group needs review or manage access without becoming tenancy admin.

## What This Deploys

This folder is self-contained at the deployment level. Terraform composes
existing governance modules and a few direct resources, while the local Ansible
files provide the same plan/apply/destroy rhythm used across the repo.

| Kind | Name | Source Or Role |
|---|---|---|
| Module | `tagging` | `modules/governance/tagging` for tag namespace, tag definitions, and tag defaults. |
| Module | `budgets` | `modules/governance/budgets` for budget objects and budget alert rules. |
| Module | `notifications` | `modules/governance/events` used here for ONS topics, subscriptions, and optional cost-governance Events rules. |
| Module | `monitoring` | `modules/operations/monitoring` for optional custom budget or cost alarms. |
| Resource | `oci_optimizer_enrollment_status.this` | Optional Optimizer enrollment management when the tenancy identifier is supplied. |
| Resource | `oci_optimizer_profile.this` | Optional Optimizer profiles scoped by compartment or tags. |
| Resource | `oci_identity_policy.finops_access` | Optional policy for FinOps operators. |

The exact OCI behavior is controlled by `variables.tf` and the values supplied
in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/operations/cost-optimization/
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

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real OCIDs, cost owners, recipients, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
|---|---|
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region name. |
| `home_region` | Home region for Identity and tagging operations. |
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `compartment_ocid` | Compartment OCID where cost-governance resources are created. |
| `defined_tags` | Defined tags applied to created resources. |
| `freeform_tags` | Freeform tags applied to created resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
|---|---|
| `default_cost_center` | Default finance or chargeback value for tag defaults. |
| `default_owner` | Default platform, product, or business owner. |
| `tag_default_compartment_ids` | Compartments where tag defaults should be enforced. |
| `enable_budgets` | Create budget and budget alert resources. |
| `default_budget_amount` | Default budget amount for the selected target compartments. |
| `budgets` | Extra per-compartment or per-tag budgets. |
| `enable_notifications` | Create FinOps ONS topic, subscriptions, and optional Events rules. |
| `notification_subscriptions` | Email, Slack webhook, PagerDuty, or other ONS endpoints. |
| `enable_budget_alarm` | Create an extra Monitoring alarm from a supplied MQL query. |
| `enable_optimizer_profiles` | Create Optimizer profiles scoped by compartments or tags. |
| `finops_policy_statements` | Optional IAM statements for the FinOps operating group. |

### Enable Flags And Switches

All resources that can create noise, cost, or tenant-wide behavior are opt-in.
`enable_tagging` is on by default because tags are the center of this pattern;
budgets, notifications, alarms, Optimizer enrollment, Optimizer profiles, and
IAM policy statements are enabled only when you supply the matching inputs.

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks,
customer notes, or manual hand-off. If an output name changes, update dependent
docs and consumers in the same change.

| Output | Hand-Off Meaning |
|---|---|
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Combined map of resources created by this blueprint. |
| `tag_namespace_id` | FinOps tag namespace OCID. |
| `tag_definition_ids` | Tag definition OCIDs keyed by tag name. |
| `tag_default_ids` | Tag default OCIDs keyed by compartment and tag. |
| `budget_ids` | Budget OCIDs keyed by logical name. |
| `budget_alert_rule_ids` | Budget alert rule OCIDs keyed by logical name. |
| `notification_topic_ids` | ONS topic OCIDs keyed by logical name. |
| `subscription_ids` | ONS subscription OCIDs keyed by logical name. |
| `monitoring_alarm_ids` | Monitoring alarm OCIDs keyed by logical name. |
| `optimizer_profile_ids` | Optimizer profile OCIDs keyed by logical name. |
| `access_policy_id` | Optional FinOps IAM policy OCID. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/operations/cost-optimization
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across
the repo:

```bash
cd blueprints/operations/cost-optimization
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Deploy or identify the core landing-zone compartments first.
2. Confirm the cost-center taxonomy and owner model with finance.
3. Confirm budget amounts, alert thresholds, and recipients.
4. Populate local ignored tfvars with real compartment OCIDs and contact points.
5. Run plan and review every budget, topic, subscription, Optimizer profile, and
   IAM statement.
6. Apply only after finance and platform owners approve the output shape.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow,
signal path, operational boundaries, review checklist, and the expected
Terraform + Ansible output at the end of the deployment.

## Review Before Apply

- Confirm tag names and default values match the finance taxonomy.
- Confirm tag defaults are applied only to the compartments that should enforce
  them.
- Confirm budget targets, thresholds, reset period, and recipients.
- Confirm ONS subscriptions use approved distribution lists or webhook targets.
- Confirm Optimizer scope before enabling tenancy-wide recommendations.
- Confirm FinOps IAM statements grant the minimum useful access.
- Confirm no generated Terraform files, state files, plans, or local tfvars are
  committed.

## Validation

From the repository root:

```bash
./scripts/validate-changed.sh
```

Use `./scripts/validate-all.sh` before release work or broad shared changes.
The validator checks Terraform formatting, required deployment README files,
required architecture README sections, `terraform init -backend=false`,
`terraform validate`, Ansible syntax, optional scanners when installed, and
cleanup of generated Terraform artifacts.
