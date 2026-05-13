# Workload Vending

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/operating-entity/workload-vending`. It
tells you what the blueprint builds, which inputs deserve a real review, how to run
Terraform or the local Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/operating-entity/workload-vending` |
| Best fit | Vends a workload landing area with compartments, groups, and policies for an application or product team. |
| Terraform shape | `compartments`, `groups`, `policies` |
| Inputs to settle first | `parent_compartment_ocid`, `workload_code`, `workload_name`, `root_compartment_name`, `root_compartment_description`, `child_compartments`, `admin_group_name`, plus 3 more |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`, `compartment_names`, `group_ids`, plus 3 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Vends a workload landing area with compartments, groups, and policies for an application or
product team.

## When To Use This Deployment

- Application teams need a repeatable onboarding pattern.
- A workload owner needs delegated admin/operator/auditor access.
- Child compartments should be created consistently.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `compartments` | `modules/iam/compartments @ v0.2.0` |
| Module | `groups` | `modules/iam/groups @ v0.2.0` |
| Module | `policies` | `modules/iam/policies @ v0.2.0` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/operating-entity/workload-vending/
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
| `parent_compartment_ocid` | Parent operating entity or workload compartment OCID. Defaults to tenancy_ocid for simple tests. |
| `workload_code` | Short workload code used in names. |
| `workload_name` | Human-readable workload name. |
| `root_compartment_name` | Optional workload root compartment display name. |
| `root_compartment_description` | Description for the workload root compartment. |
| `child_compartments` | Child compartments created under the workload root. |
| `admin_group_name` | Optional workload admin group name override. |
| `operator_group_name` | Optional workload operator group name override. |
| `auditor_group_name` | Optional workload auditor group name override. |
| `policy_compartment_ocid` | Compartment OCID where workload policies are attached. Defaults to parent_compartment_ocid. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_delete` | Allow Terraform to delete created workload compartments during destroy. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `root_compartment_id` | Workload root compartment OCID. |
| `compartment_ids` | Workload compartment OCIDs keyed by logical name. |
| `compartment_names` | Workload compartment names keyed by logical name. |
| `group_ids` | Workload IAM group OCIDs. |
| `group_names` | Workload IAM group names. |
| `policy_ids` | Workload IAM policy OCIDs. |
| `policy_statements` | Workload IAM policy statements. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/operating-entity/workload-vending
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/operating-entity/workload-vending
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Deploy or identify the parent landing-zone compartment.
2. Review entity or workload naming, child compartments, and delegated groups.
3. Populate `terraform.tfvars` with ownership and policy values.
4. Run plan and review every compartment and policy statement.
5. Apply, then hand outputs to the owning team.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Confirm workload code, name, and child compartments.
- Review admin, operator, and auditor groups.
- Keep workload policy scope tight.
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
