# OCI Container Instances

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/extensions/container-instances`. It tells you what the blueprint builds, which inputs deserve a real review, how to run Terraform or the local Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
|---|---|
| Folder | `blueprints/extensions/container-instances` |
| Best fit | Serverless container runtime for private app workers, APIs, and small services that do not need OKE. |
| Terraform shape | `oci_container_instances_container_instance.this`, `oci_identity_policy.access` |
| Inputs to settle first | Base tenancy values, availability domain, private subnet, image URL, NSGs, shape, and optional image pull secret. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `container_instance_id`, `vnic_ids`, `container_ids`, `access_policy_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys an OCI Container Instance with private VNIC attachment, one or more containers, optional pull secrets, optional volumes, and optional IAM policy statements.

## When To Use This Deployment

- You need a small containerized workload without an OKE cluster.
- You want private subnet attachment and NSG control for a container runtime.
- You need a repeatable OCI deployment folder with local Terraform and Ansible runners.
- App or platform teams need stable outputs for VNICs, container IDs, and IAM policy hand-off.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_container_instances_container_instance.this` | Declared directly in `main.tf` |
| Resource | `oci_identity_policy.access` | Optional scoped IAM policy declared directly in `main.tf` |

The exact OCI behavior is controlled by `variables.tf` and values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/extensions/container-instances/
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

Start with `terraform.tfvars.example`, then create a local ignored `terraform.tfvars` with real OCIDs, image URLs, sizing values, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
|---|---|
| `tenancy_ocid` | Required base value for provider configuration and policy scope. |
| `current_user_ocid` | Required base value for local execution or bootstrap workflows. |
| `region` | OCI region where the Container Instance is created. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in names. |
| `compartment_ocid` | Compartment OCID where the Container Instance is created. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
|---|---|
| `enable_container_instance` | Keep `false` for validation-only runs; set `true` only for an approved deployment. |
| `availability_domain` | Availability domain for the runtime. |
| `subnet_id` | Private subnet for the VNIC. |
| `nsg_ids` | NSGs that allow only approved ingress and egress. |
| `shape`, `ocpus`, `memory_in_gbs` | Runtime size. |
| `containers` | Image URL, command, args, env vars, health checks, and volume mounts. |
| `image_pull_secrets` | Registry pull secret configuration; prefer Vault secret IDs over inline passwords. |
| `volumes` | Optional config or empty volumes mounted into containers. |
| `policy_statements` | Optional IAM statements for operators or service principals. |

### Enable Flags And Switches

All cost-bearing resources are disabled by default where possible. Turn on only the resources approved for the target environment.

## Outputs And Hand-Off

| Output | Hand-Off Meaning |
|---|---|
| `blueprint_name` | Blueprint identifier for automation. |
| `name_prefix` | Standard OCI naming prefix. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `container_instance_id` | Container Instance OCID. |
| `container_instance_state` | Runtime lifecycle state. |
| `vnic_ids` | VNIC OCIDs attached to the Container Instance. |
| `container_ids` | Container IDs inside the runtime. |
| `access_policy_id` | Optional IAM policy OCID. |

## Terraform And Ansible Workflow

```bash
cd blueprints/extensions/container-instances
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

```bash
cd blueprints/extensions/container-instances
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

## Deployment Order

This extension supports extension-only and base-plus-extension customer paths.
For extension-only use, supply existing compartment, subnet, NSG, image, and
registry values in local tfvars and run this folder directly. For
base-plus-extension use, deploy core and networking first, then pass their
outputs here.

1. Confirm the target compartment, network/service dependencies, and ownership model.
2. Confirm the target subnet, NSGs, image registry, and image pull secret approach.
3. Populate `terraform.tfvars` with real values from approved sources.
4. Run plan and review container image, VNIC, NSGs, public IP setting, and IAM policy statements.
5. Apply only after the platform or app owner approves the output shape.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

## Review Before Apply

- Confirm the container image URL and registry pull secret model.
- Confirm the VNIC is in the expected private subnet and public IP assignment is intentional.
- Confirm NSGs allow only approved app, admin, and service paths.
- Confirm health checks, volumes, environment variables, and resource limits match the workload.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
