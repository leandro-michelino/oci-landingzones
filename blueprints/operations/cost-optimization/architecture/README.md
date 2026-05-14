# Cost Optimization Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for
`blueprints/operations/cost-optimization`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer
notes without a diagramming tool.

## Deployment Purpose

Deploys a FinOps control layer with cost-tracking tags, optional tag defaults,
budgets, budget alert rules, notification topics, optional Monitoring alarms,
optional Optimizer profiles, and an optional FinOps access policy.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/operations/cost-optimization` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Turns cost governance into a repeatable blueprint instead of a spreadsheet exercise. |
| Terraform components | `module.tagging`, `module.budgets`, `module.notifications`, `module.monitoring`, `oci_optimizer_enrollment_status.this`, `oci_optimizer_profile.this`, `oci_identity_policy.finops_access` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and signal flow for this exact deployment. |

## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------------+
| Cost Optimization / FinOps Landing-Zone Layer                                                                   |
+----------------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> control/signal flow                       |
|                                                                                                                |
| [Operator / CI]                                                                                                |
|      |                                                                                                         |
|      | terraform plan/apply or guarded Ansible runner                                                          |
|      v                                                                                                         |
| [Terraform OCI provider]                                                                                       |
|      |                                                                                                         |
|      +---------------------------------------------------------------------------------------------------+     |
|      |                                                                                                   |     |
|      v                                                                                                   v     |
| {Home-region Identity / Tagging plane}                                                             {Regional OCI plane} |
|      |                                                                                                   |     |
|      |                                                                                                   |     |
|      +--> [FinOps tag namespace]                                                                         |     |
|      |        |-- CostCenter  (cost tracking enabled)                                                    |     |
|      |        |-- Owner                                                                                  |     |
|      |        |-- Environment                                                                            |     |
|      |        |-- Project                                                                                |     |
|      |        |-- ManagedBy                                                                              |     |
|      |        `-- Blueprint                                                                              |     |
|      |               |                                                                                    |     |
|      |               v                                                                                    |     |
|      |        [Tag defaults on approved compartments]                                                     |     |
|      |               |                                                                                    |     |
|      |               v                                                                                    |     |
|      |        (Workload / governance / shared-service compartments carry owner and cost-center metadata)   |     |
|      |                                                                                                   |     |
|      +--> [FinOps IAM policy]                                                                            |     |
|               |-- optional manage/read access for budgets, usage reports, Optimizer, and notifications    |     |
|               `-- scoped to supplied policy compartment                                                   |     |
|                                                                                                                |
| {Cost governance compartment}                                                                                  |
|      |                                                                                                         |
|      +--> [Budgets]                                                                                            |
|      |        |-- default landing-zone budget                                                               |
|      |        |-- per-compartment or per-tag budgets                                                       |
|      |        `-- budget alert rules                                                                           |
|      |               |                                                                                          |
|      |               v                                                                                          |
|      |        (Email recipients from ignored local tfvars)                                                       |
|      |                                                                                                         |
|      +--> [FinOps ONS topic]                                                                                    |
|      |        |-- EMAIL subscription                                                                         |
|      |        |-- HTTPS webhook subscription                                                                 |
|      |        `-- optional Events rule actions                                                                  |
|      |               |                                                                                          |
|      |               v                                                                                          |
|      |        (Finance, platform, service owner, or incident channel)                                             |
|      |                                                                                                         |
|      +--> [Monitoring alarm, optional]                                                                          |
|      |        |-- customer-supplied MQL query                                                                |
|      |        |-- topic destination from FinOps ONS or supplied topic OCIDs                                  |
|      |        `-- repeat notification window                                                                    |
|      |               |                                                                                          |
|      |               v                                                                                          |
|      |        [FinOps ONS topic] -> (approved email / webhook target)                                             |
|      |                                                                                                         |
|      `--> [OCI Optimizer, optional]                                                                             |
|               |-- enrollment status when explicitly supplied                                                   |
|               |-- Optimizer profiles scoped to compartments                                                   |
|               |-- optional target tag filters                                                                 |
|               `-- optional recommendation-level configuration                                                  |
|                       |                                                                                       |
|                       v                                                                                       |
|               (Rightsizing, idle-resource, and efficiency recommendations for FinOps review)                    |
|                                                                                                                |
| Review focus: tag taxonomy, budget target scope, recipients, webhook ownership, Optimizer scope, and IAM       |
| statements.                                                                                                    |
| Hand-off: tag namespace, budget IDs, alert rules, notification topics, alarm IDs, Optimizer profiles, and      |
| optional access policy ID.                                                                                     |
+----------------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Module | `module.tagging` | Creates the FinOps tag namespace, tag definitions, and optional tag defaults. |
| Module | `module.budgets` | Creates default and custom budgets plus budget alert rules. |
| Module | `module.notifications` | Creates the FinOps ONS topic, subscriptions, and optional Events rules. |
| Module | `module.monitoring` | Creates optional Monitoring alarms that publish to ONS destinations. |
| Resource | `oci_optimizer_enrollment_status.this` | Optionally manages Optimizer enrollment when the customer supplies the identifier. |
| Resource | `oci_optimizer_profile.this` | Creates Optimizer profiles scoped by target compartments or tags. |
| Resource | `oci_identity_policy.finops_access` | Creates an optional IAM policy for FinOps operators. |

## Request And Deployment Flow

- Operator identifies the landing-zone compartments that need cost ownership,
  tag defaults, and budget tracking.
- Finance or platform owners approve cost-center values, budget thresholds, and
  alert recipients before local tfvars are created.
- Terraform creates tag definitions first, then budget and notification
  resources, then optional alarms, Optimizer resources, and IAM policy.
- Budget alert rules send direct recipient email through OCI Budgets.
- Optional Monitoring alarms publish to the FinOps ONS topic or supplied topic
  OCIDs.
- Outputs expose the IDs needed by finance reports, runbooks, and downstream
  automation.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI
  provider and the Ansible Terraform runner.
- Tagging and IAM policy operations use the home-region provider because those
  APIs are tenancy and identity-plane sensitive.
- Budgets, notifications, monitoring alarms, and Optimizer profiles are scoped
  to the supplied compartment IDs and region.
- ONS subscriptions may point to email or webhook endpoints outside OCI; treat
  those endpoints as external trust boundaries.
- Recipients, webhook URLs, OCIDs, and policy statements belong in ignored local
  tfvars or secure pipeline variables, not committed examples.

## Detailed Architecture Notes

- Tag defaults are intentionally separate from tag definitions. Create tag
  definitions broadly, then enforce defaults only where the operating model is
  ready.
- Budget alert rules are native OCI Budgets alerts and use recipient email
  strings. They do not require ONS.
- The FinOps ONS topic is still useful for Monitoring alarms, Events rules, and
  webhook-style integrations.
- The default Monitoring alarm is query-driven. The blueprint requires the MQL
  query to come from local inputs because cost metric naming can differ by
  tenancy, service, and reporting model.
- Optimizer enrollment is optional because some tenancies already manage it
  centrally. The profile resource is safer to use for scoped recommendations.
- The IAM policy is empty by default so teams can review exact group names,
  verbs, and compartments before granting access.

## Operational Boundaries

- Keep customer-specific OCIDs, recipients, webhook URLs, and IAM group names in
  ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so pinned Git module sources, provider
  files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible
  playbooks or a reviewed Terraform workflow.
- Re-check tag defaults, budget targets, alert thresholds, notification
  destinations, Optimizer scope, and IAM statements whenever finance ownership
  changes.
- Use `scripts/validate-changed.sh` for normal edits to this blueprint and
  `scripts/validate-all.sh` before release-wide changes.

## Review Checklist

- Confirm the diagram matches `main.tf`: `module.tagging`, `module.budgets`,
  `module.notifications`, `module.monitoring`,
  `oci_optimizer_enrollment_status.this`, `oci_optimizer_profile.this`, and
  `oci_identity_policy.finops_access`.
- Confirm cost-center and owner tag names match the customer reporting model.
- Confirm tag defaults target only approved compartments.
- Confirm budget targets, thresholds, reset periods, recipients, and custom
  budget maps.
- Confirm ONS topics and subscriptions point to approved notification owners.
- Confirm Monitoring alarm queries are tested in the target tenancy before
  apply.
- Confirm Optimizer profiles do not accidentally cover compartments outside
  the intended FinOps scope.
- Confirm IAM policy statements are least-privilege and reference existing
  groups.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml`
  still point at the shared Terraform runner.
