# CIS Basic Identity Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/identity/cis-basic`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates baseline IAM groups, dynamic groups, and policies suitable for CIS-aligned landing-zone administration.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/identity/cis-basic` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates baseline IAM groups, dynamic groups, and policies suitable for CIS-aligned landing-zone administration. |
| Terraform components | `groups`, `dynamic_groups`, `policies` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `cis_level`, `resource_ids`, `group_ids`, `group_names`, `dynamic_group_ids`, `policy_ids` |
| Runner contract | `ansible/plan.yml`, guarded `ansible/apply.yml`, and guarded `ansible/destroy.yml`. |

## Files In This Deployment

```text
blueprints/identity/cis-basic/
|-- README.md                         Operator guide for this deployment
|-- architecture/README.md            This deployment-specific ASCII architecture
|-- main.tf                           Terraform module and resource graph
|-- variables.tf                      Input contract and defaults
|-- outputs.tf                        Hand-off values for downstream deployments
|-- providers.tf                      OCI provider configuration
|-- versions.tf                       Terraform and provider constraints
|-- terraform.tfvars.example          Example tfvars shape for this deployment
`-- ansible/
    |-- plan.yml                      Local plan runner
    |-- apply.yml                     Guarded apply runner
    `-- destroy.yml                   Guarded destroy runner
```

## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| CIS Basic Identity                                                                                |
|                                                                                                  |
|  Human administrators, break-glass users, automation principals                                    |
|                 |                                                                                |
|                 v                                                                                |
|  +---------------------------- OCI IAM Home Region ----------------------------+                  |
|  | Groups                                                                     |                  |
|  | - default CIS-aligned admin, security, network, app, auditor groups         |                  |
|  |                                                                            |                  |
|  | Dynamic Groups                                                              |                  |
|  | - workload/resource principal matching rules                                |                  |
|  |                                                                            |                  |
|  | Policies                                                                    |                  |
|  | - group_names + dynamic_group_names -> tenancy/compartment permissions      |                  |
|  +-------------------------------+--------------------------------------------+                  |
|                                  | permissions gate all resource plane actions                    |
|                                  v                                                                  |
|                         Landing-zone compartments and OCI services                                |
|                                                                                                  |
|  Flow: create groups and dynamic groups first, then policies referencing those names.              |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `groups` | `../../../modules/iam/groups` |
| Module | `dynamic_groups` | `../../../modules/iam/dynamic-groups` |
| Module | `policies` | `../../../modules/iam/policies` |

## Request And Deployment Flow

- Provider authentication uses the home-region IAM plane.
- Terraform creates domains, groups, dynamic groups, or policies in dependency order.
- Outputs expose identity IDs, names, URLs, and policy IDs for operators and downstream blueprints.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## State, Inputs, And Outputs

```text
Input sources
|-- terraform.tfvars.example documents expected values for this deployment
|-- local ignored tfvars provide tenancy, compartment, CIDR, endpoint, and service-specific values
|-- environment variables may provide OCI authentication and guarded Ansible confirms
|
Terraform state
|-- backend is disabled for local validation and blueprint-local runners by default
|-- production state backends should be configured outside this reusable blueprint folder
|-- generated .terraform directories, lock files, plans, state files, and local tfvars stay out of git
|
Output contract
|-- blueprint_name
|-- name_prefix
|-- cis_level
|-- resource_ids
|-- group_ids
|-- group_names
|-- dynamic_group_ids
`-- policy_ids
```

## Operational Boundaries

- Review enable flags before apply, especially for paid, tenancy-wide, identity, network edge, database, or destructive resources.
- Confirm required external IDs are real and in the intended region and compartment before running `terraform plan`.
- Keep apply and destroy behind the guarded Ansible runners or an equivalent approval gate.
- Treat route tables, firewall policies, ZPR policies, identity policies, and domain replication as change-controlled surfaces.
- Run repository validation before commit or hand-off.

## Review Checklist

- Confirm the diagram matches `main.tf`: `groups`, `dynamic_groups`, `policies`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `cis_level`, `resource_ids`, `group_ids`, `group_names`, `dynamic_group_ids`, `policy_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.

## Validation

```bash
./scripts/validate-all.sh
```

The repository validator checks Terraform formatting, initializes and validates every
blueprint without a backend, syntax-checks the root Ansible playbooks, syntax-checks every
blueprint-local Ansible runner, verifies README coverage, and removes generated Terraform
artifacts afterward.

## When To Update This Architecture

- Terraform modules, resources, data sources, provider aliases, or enable flags change.
- A subnet, route, trust boundary, identity scope, region, compartment, private endpoint, or access path changes.
- A new output becomes part of the contract for downstream deployments or operators.
- README usage notes describe behavior that is not represented in the diagram.

## Terraform + Ansible Deployment Output

This is the expected close-out shape for `blueprints/identity/cis-basic`. Terraform owns the OCI resource graph and
named outputs; Ansible gives the operator a repeatable plan/apply/destroy wrapper with a
clear recap.

```text
$ cd blueprints/identity/cis-basic
$ terraform init
$ terraform validate
$ terraform plan -out=tfplan
$ terraform apply tfplan

Apply complete! Resources: <added> added, <changed> changed, <destroyed> destroyed.

$ terraform output
blueprint_name = "<value>"
name_prefix = "<value>"
cis_level = "<value>"
resource_ids = { ... }
group_ids = { ... }
group_names = { ... }
dynamic_group_ids = { ... }
policy_ids = { ... }
```

```text
$ cd blueprints/identity/cis-basic
$ ansible-playbook -i localhost, ansible/plan.yml

TASK [terraform_runner : Terraform init]      ok
TASK [terraform_runner : Terraform validate]  ok
TASK [terraform_runner : Terraform plan]      ok

PLAY RECAP *********************************************************************
localhost                  : ok=<n> changed=0 unreachable=0 failed=0 skipped=<n> rescued=0 ignored=0

$ CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml

TASK [terraform_runner : Terraform init]      ok
TASK [terraform_runner : Terraform validate]  ok
TASK [terraform_runner : Terraform plan]      ok
TASK [terraform_runner : Terraform apply]     changed

PLAY RECAP *********************************************************************
localhost                  : ok=<n> changed=<n> unreachable=0 failed=0 skipped=<n> rescued=0 ignored=0
```

For this deployment, keep the output names stable unless the downstream deployment, runbook,
or customer hand-off is updated in the same change.
