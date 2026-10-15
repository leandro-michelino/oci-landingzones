# OCI DevOps Pipeline

Start here for `blueprints/devops/oci-devops-pipeline`: what it builds, which inputs deserve a careful look, how to run Terraform or the local Ansible wrappers, and where the detailed architecture notes live.

## At A Glance

| Item | Details |
|---|---|
| Folder | `blueprints/devops/oci-devops-pipeline` |
| Best fit | Native CI/CD bootstrap for OKE, Compute, Functions, or artifact workflows. |
| Terraform shape | `oci_ons_notification_topic.this`, `oci_devops_project.this`, `oci_devops_repository.this`, `oci_devops_build_pipeline.this`, `oci_devops_deploy_pipeline.this` |
| Inputs to settle first | Base tenancy values plus the deployment-specific enable flags and service IDs in `variables.tf`. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `project_id`, `repository_id`, `build_pipeline_id`, `deploy_pipeline_id`, `notification_topic_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Optionally creates an OCI DevOps project, Notifications topic, code repository,
and empty build and deploy pipeline shells.

All creation flags default to `false`. A new project requires either a new
Notifications topic or `notification_topic_id`. Repository and pipeline creation
requires a new project or `existing_project_id`. These relationships are checked
at plan time.

Oracle's [DevOps project guide](https://docs.oracle.com/en-us/iaas/Content/devops/using/create_project.htm)
documents the required notification topic and project logging needed to run
pipelines.

The blueprint does not configure topic subscriptions, project logging, build or
deploy stages, artifacts, triggers, deployment environments, or IAM policies.
It is a control-plane bootstrap, not an executable CI/CD workflow. Review OCI
DevOps, build execution, logging, Notifications, and artifact costs before
activating those services.

## When To Use This Deployment

- Native CI/CD bootstrap for OKE, Compute, Functions, or artifact workflows.
- You need a reusable, reviewable OCI deployment folder with local Terraform and Ansible runners.
- Outputs from this pattern must be handed off to application, platform, or security teams.

## What This Deploys

Everything needed for this deployment starts in this folder: Terraform composes the OCI resource graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_ons_notification_topic.this` | Declared directly in `main.tf` |
| Resource | `oci_devops_project.this` | Declared directly in `main.tf` |
| Resource | `oci_devops_repository.this` | Declared directly in `main.tf` |
| Resource | `oci_devops_build_pipeline.this` | Declared directly in `main.tf` |
| Resource | `oci_devops_deploy_pipeline.this` | Declared directly in `main.tf` |

Use `variables.tf` as the input contract, then keep real OCIDs, CIDRs, names, and enable flags in an ignored local `terraform.tfvars`.

## Folder Contract

```text
blueprints/devops/oci-devops-pipeline/
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

Review the enable flags, the required topic ID for a new project, and the
required existing project ID when creating child resources without a new project.

### Enable Flags And Switches

All cost-bearing resources are disabled by default where possible. Turn on only the resources approved for the target environment.

## Outputs And Hand-Off

| Output | Hand-Off Meaning |
|---|---|
| `blueprint_name` | Hand-off value for OCI DevOps Pipeline. |
| `name_prefix` | Hand-off value for OCI DevOps Pipeline. |
| `resource_ids` | Hand-off value for OCI DevOps Pipeline. |
| `project_id` | Hand-off value for OCI DevOps Pipeline. |
| `repository_id` | Hand-off value for OCI DevOps Pipeline. |
| `build_pipeline_id` | Hand-off value for OCI DevOps Pipeline. |
| `deploy_pipeline_id` | Hand-off value for OCI DevOps Pipeline. |
| `notification_topic_id` | Hand-off value for OCI DevOps Pipeline. |

## Terraform And Ansible Workflow

```bash
cd blueprints/devops/oci-devops-pipeline
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

```bash
cd blueprints/devops/oci-devops-pipeline
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

## Deployment Order

1. Deploy core and the required network foundation first.
2. Confirm service-specific quotas, cost, and dependencies.
3. Populate `terraform.tfvars` with real values from approved sources.
4. Run plan and review optional resource enable flags.
5. Apply only after the platform or service owner approves the output shape.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

## Review Before Apply

- Confirm the project topic exists and arrange subscriptions separately; this blueprint does not create recipients.
- Confirm repository naming and branch strategy.
- Add project logging, stages, triggers, artifacts, and target environments before claiming CI/CD runtime readiness.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.

Last successful validation: 2026-10-15, oracle/oci 9.9.0, Terraform schema and
seven mocked plan cases in `tests/configuration-regressions.tftest.hcl`.
No OCI DevOps resource was provisioned or exercised live.
