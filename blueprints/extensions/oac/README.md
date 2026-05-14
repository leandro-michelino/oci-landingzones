# Oracle Analytics Cloud

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/extensions/oac`. It tells you what the blueprint builds, which inputs deserve a real review, how to run Terraform or the local Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
|---|---|
| Folder | `blueprints/extensions/oac` |
| Best fit | Private analytics tier for ADW, ATP, and enterprise reporting workloads. |
| Terraform shape | `oci_analytics_analytics_instance.this`, `oci_analytics_analytics_instance_private_access_channel.this` |
| Inputs to settle first | Base tenancy values plus the deployment-specific enable flags and service IDs in `variables.tf`. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `analytics_instance_id`, `private_access_channel_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys an Oracle Analytics Cloud instance with optional private access channel.

## When To Use This Deployment

- Private analytics tier for ADW, ATP, and enterprise reporting workloads.
- You need a reusable, reviewable OCI deployment folder with local Terraform and Ansible runners.
- Outputs from this pattern must be handed off to application, platform, or security teams.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_analytics_analytics_instance.this` | Declared directly in `main.tf` |
| Resource | `oci_analytics_analytics_instance_private_access_channel.this` | Declared directly in `main.tf` |

The exact OCI behavior is controlled by `variables.tf` and values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/extensions/oac/
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

| Input | What To Decide |
|---|---|
| `license_type` | Use `LICENSE_INCLUDED` or `BRING_YOUR_OWN_LICENSE` after analytics owner and commercial review. |

### Enable Flags And Switches

All cost-bearing resources are disabled by default where possible. Turn on only the resources approved for the target environment.

## Outputs And Hand-Off

| Output | Hand-Off Meaning |
|---|---|
| `blueprint_name` | Hand-off value for Oracle Analytics Cloud. |
| `name_prefix` | Hand-off value for Oracle Analytics Cloud. |
| `resource_ids` | Hand-off value for Oracle Analytics Cloud. |
| `analytics_instance_id` | Hand-off value for Oracle Analytics Cloud. |
| `private_access_channel_id` | Hand-off value for Oracle Analytics Cloud. |

## Terraform And Ansible Workflow

```bash
cd blueprints/extensions/oac
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

```bash
cd blueprints/extensions/oac
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

## Deployment Order

This extension supports extension-only and base-plus-extension customer paths.
For extension-only use, supply existing compartment, VCN, subnet, NSG, and
private access values in local tfvars and run this folder directly. For
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

- Confirm feature set, `license_type`, and capacity.
- Confirm private access channel subnet, VCN, NSGs, and DNS zones.
- Confirm KMS and identity-domain decisions.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
