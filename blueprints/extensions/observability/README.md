# Observability Platform

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/extensions/observability`. It tells you what the blueprint builds, which inputs deserve a real review, how to run Terraform or the local Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
|---|---|
| Folder | `blueprints/extensions/observability` |
| Best fit | Shared observability foundation above the core logging and monitoring baseline. |
| Terraform shape | `oci_log_analytics_namespace.this`, `oci_log_analytics_log_analytics_log_group.this`, `oci_apm_apm_domain.this`, `oci_opsi_operations_insights_private_endpoint.this` |
| Inputs to settle first | Base tenancy values plus the deployment-specific enable flags and service IDs in `variables.tf`. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `log_analytics_namespace`, `log_group_id`, `apm_domain_id`, `opsi_private_endpoint_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys an observability layer with optional Log Analytics namespace and group, APM domain, and Operations Insights private endpoint.

## When To Use This Deployment

- Shared observability foundation above the core logging and monitoring baseline.
- You need a reusable, reviewable OCI deployment folder with local Terraform and Ansible runners.
- Outputs from this pattern must be handed off to application, platform, or security teams.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_log_analytics_namespace.this` | Declared directly in `main.tf` |
| Resource | `oci_log_analytics_log_analytics_log_group.this` | Declared directly in `main.tf` |
| Resource | `oci_apm_apm_domain.this` | Declared directly in `main.tf` |
| Resource | `oci_opsi_operations_insights_private_endpoint.this` | Declared directly in `main.tf` |

The exact OCI behavior is controlled by `variables.tf` and values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/extensions/observability/
|-- README.md
|-- architecture/README.md
|-- main.tf
|-- variables.tf
|-- outputs.tf
|-- providers.tf
|-- versions.tf
|-- terraform.tfvars.example
`-- ansible/
    |-- plan.yml
    |-- apply.yml
    `-- destroy.yml
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored `terraform.tfvars` with real OCIDs, names, recipients, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
|---|---|
| `tenancy_ocid` | Required base value for naming, provider configuration, or compartment targeting. |
| `current_user_ocid` | Required base value for naming, provider configuration, or compartment targeting. |
| `region` | Required base value for naming, provider configuration, or compartment targeting. |
| `org` | Required base value for naming, provider configuration, or compartment targeting. |
| `environment` | Required base value for naming, provider configuration, or compartment targeting. |
| `region_key` | Required base value for naming, provider configuration, or compartment targeting. |
| `compartment_ocid` | Required base value for naming, provider configuration, or compartment targeting. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

Review every variable after the base section in `variables.tf`, especially enable flags, private endpoint IDs, policy statements, notification recipients, and service-specific sizing values.

### Enable Flags And Switches

All cost-bearing resources are disabled by default where possible. Turn on only the resources approved for the target environment.

## Outputs And Hand-Off

| Output | Hand-Off Meaning |
|---|---|
| `blueprint_name` | Hand-off value for Observability Platform. |
| `name_prefix` | Hand-off value for Observability Platform. |
| `resource_ids` | Hand-off value for Observability Platform. |
| `log_analytics_namespace` | Hand-off value for Observability Platform. |
| `log_group_id` | Hand-off value for Observability Platform. |
| `apm_domain_id` | Hand-off value for Observability Platform. |
| `opsi_private_endpoint_id` | Hand-off value for Observability Platform. |

## Terraform And Ansible Workflow

```bash
cd blueprints/extensions/observability
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

```bash
cd blueprints/extensions/observability
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

## Deployment Order

This extension supports extension-only and base-plus-extension customer paths.
For extension-only use, supply existing compartment, VCN, subnet, NSG, and
observability service values in local tfvars and run this folder directly. For
base-plus-extension use, deploy core and networking first, then pass their
outputs here.

1. Confirm the target compartment, network/service dependencies, and ownership model.
2. Confirm service-specific quotas, cost, and dependencies.
3. Populate `terraform.tfvars` with real values from approved sources.
4. Run plan and review optional resource enable flags.
5. Apply only after the platform or service owner approves the output shape.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

## Review Before Apply

- Confirm Log Analytics namespace ownership and onboarding.
- Confirm APM free tier versus paid domain.
- Confirm Operations Insights subnet, VCN, and NSGs.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
