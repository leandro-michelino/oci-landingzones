# CIS Basic Identity Baseline

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/identity/cis-basic`. It tells you what
the blueprint builds, which inputs deserve a real review, how to run Terraform or the local
Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/identity/cis-basic` |
| Best fit | Creates CIS-oriented IAM groups, dynamic groups, and policies without deploying the full core landing-zone stack. |
| Terraform shape | `groups`, `dynamic_groups`, `policies` |
| Inputs to settle first | `compartment_ocid`, `groups`, `dynamic_groups`, `policies` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `cis_level`, `resource_ids`, `group_ids`, `group_names`, `dynamic_group_ids`, plus 1 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Creates CIS-oriented IAM groups, dynamic groups, and policies without deploying the full
core landing-zone stack.

## When To Use This Deployment

- Identity baseline is needed as a standalone task.
- Groups, dynamic groups, and policies need repeatable naming.
- A team wants CIS-aligned identity scope before broader resources.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `groups` | `../../../modules/iam/groups` |
| Module | `dynamic_groups` | `../../../modules/iam/dynamic-groups` |
| Module | `policies` | `../../../modules/iam/policies` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/identity/cis-basic/
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
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `compartment_ocid` | Compartment OCID where identity policies are created. Defaults to tenancy_ocid. |
| `groups` | Additional or overriding IAM groups keyed by logical role. |
| `dynamic_groups` | Dynamic groups keyed by logical role. |
| `policies` | Additional IAM policies keyed by logical role. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_default_groups` | Create the default CIS landing zone IAM groups. |
| `enable_default_policies` | Create baseline CIS IAM policies. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `cis_level` | CIS baseline level implemented by this identity blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `group_ids` | IAM group OCIDs keyed by logical role. |
| `group_names` | IAM group names keyed by logical role. |
| `dynamic_group_ids` | Dynamic group OCIDs keyed by logical role. |
| `policy_ids` | IAM policy OCIDs keyed by logical role. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/identity/cis-basic
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/identity/cis-basic
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Confirm the target tenancy and identity-domain strategy.
2. Review group, dynamic-group, domain, replica, and policy inputs.
3. Populate `terraform.tfvars` with identity naming and scope values.
4. Run plan and inspect IAM or domain impact.
5. Apply, then hand group, domain, and policy outputs to administrators.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Review policy statements carefully.
- Confirm target compartment and tenancy scope.
- Do not duplicate groups already managed elsewhere.
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
