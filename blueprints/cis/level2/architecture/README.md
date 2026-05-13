# CIS Level 2 Landing Zone Blueprint Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This is the design view for `blueprints/cis/level2`. It stays ASCII-first on purpose so you
can review the deployment in GitHub, a terminal, a pull request, or customer notes without a
diagramming tool.

## Deployment Purpose

Builds the stricter CIS-aligned landing-zone baseline for regulated environments where
hardened controls and tighter operational review are expected.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/cis/level2` owns this deployment end to end. |
| Terraform components | `core` |
| Input source | `terraform.tfvars.example` documents the shape; local ignored tfvars provide real values. |
| Output contract | `blueprint_name`, `cis_level`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`, `group_names`, `policy_names`, plus 8 more |
| Runner contract | `ansible/plan.yml`, guarded `ansible/apply.yml`, and guarded `ansible/destroy.yml`. |

## Files In This Deployment

```text
blueprints/cis/level2/
|-- README.md                         Operator guide for this deployment
|-- architecture/README.md            This detailed ASCII architecture
|-- main.tf                           Terraform resource and module wiring
|-- variables.tf                      Input contract and defaults
|-- outputs.tf                        Hand-off values for dependent blueprints
|-- providers.tf                      OCI provider configuration
|-- versions.tf                       Terraform and provider constraints
|-- terraform.tfvars.example          Example local variable shape
`-- ansible/
    |-- plan.yml                      Local guarded plan runner
    |-- apply.yml                     Local guarded apply runner
    `-- destroy.yml                   Local guarded destroy runner
```

## ASCII Architecture

```text
+------------------------------------------------------------------------------------------------------+
| CIS Level 2 Landing Zone                                                                             |
| Folder: blueprints/cis/level2                                                                        |
|                                                                                                      |
| [1] Operator entry                                                                                   |
| Operator, CI job, or local shell reviews README.md and architecture/README.md, copies                |
| terraform.tfvars.example to terraform.tfvars, and chooses either direct Terraform or the local       |
| Ansible wrapper.                                                                                     |
|                                                                                                      |
| [2] Local file contract                                                                              |
| README.md -> run-facing deployment guide.                                                            |
| architecture/README.md -> detailed text architecture and review notes.                               |
| main.tf -> Terraform composition for this deployment.                                                |
| variables.tf -> input contract and defaults.                                                         |
| outputs.tf -> named hand-off values.                                                                 |
| providers.tf + versions.tf -> provider setup and version constraints.                                |
| ansible/plan.yml, apply.yml, destroy.yml -> repeatable local runners with guarded apply and destroy. |
|                                                                                                      |
| [3] Terraform composition from main.tf                                                               |
| 01. module.core -> blueprints/core @ v0.1.0                                                          |
|                                                                                                      |
| [4] OCI/resource planes                                                                              |
| - Control: provider config, tenancy context, naming inputs, and local tfvars.                        |
| - Governance: stricter security, audit, IAM, logging, segmentation, and guardrail posture.           |
| - Consumption: compliance-oriented outputs for evidence, runbooks, and downstream workload teams.    |
| - Operations: Ansible plan/apply/destroy wrappers, validation, and cleanup.                          |
|                                                                                                      |
| [5] Output hand-off                                                                                  |
| - blueprint_name: Blueprint identifier.                                                              |
| - cis_level: Fixed CIS OCI Benchmark profile for this blueprint.                                     |
| - name_prefix: Standard OCI naming prefix for resources created by this blueprint.                   |
| - resource_ids: Map of resource identifiers created by this blueprint.                               |
| - root_compartment_id: OCID of the CIS landing zone root compartment.                                |
| - compartment_ids: Map of CIS landing zone compartment keys to OCIDs.                                |
| - group_names: Map of IAM group keys to names.                                                       |
| - policy_names: Map of IAM policy keys to names.                                                     |
| - vault_ids: Map of vault keys to OCIDs.                                                             |
| - vault_key_ids: Map of KMS key keys to OCIDs.                                                       |
| - security_zone_ids: Map of Security Zone keys to OCIDs.                                             |
| - vss_host_scan_target_ids: Map of VSS host scan target keys to OCIDs.                               |
| - plus 4 more outputs declared in outputs.tf                                                         |
|                                                                                                      |
| [6] Deployment close-out                                                                             |
| terraform output and the Ansible PLAY RECAP are the human and automation hand-off.                   |
| Generated .terraform directories, lock files, plans, state files, and local tfvars stay out of git.  |
+------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `core` | `blueprints/core @ v0.1.0` |

## Request And Deployment Flow

- Operator reviews the local tfvars contract and chooses the plan/apply runner.
- Terraform composes the OCI resources declared in `main.tf`.
- Outputs become the deployment hand-off contract for runbooks and downstream blueprints.
- Validation checks formatting, init, validate, Ansible syntax, documentation coverage, and cleanup.

## State, Inputs, And Outputs

```text
Input sources
|-- terraform.tfvars.example documents expected values
|-- local *.tfvars files provide tenancy, compartment, CIDR, endpoint, and OCID values
|-- environment variables may provide OCI authentication and guarded Ansible confirms
|
Terraform state
|-- backend is disabled for local validation and plan runners by default
|-- production backends should be configured outside this reusable blueprint folder
|-- generated .terraform directories, lock files, plans, and state files are cleaned by validation
|
Output contract
|-- blueprint_name and name_prefix identify the deployment when declared
|-- resource_ids summarizes primary resources when declared
`-- blueprint-specific outputs expose compartment, VCN, subnet, key, policy, service, or DR IDs
```

## Operational Boundaries

- Keep apply/destroy behind the guarded Ansible runners or equivalent review gates.
- Use local ignored tfvars for OCIDs, notification endpoints, customer CIDRs, and secrets.
- Run ./scripts/validate-all.sh before commits or hand-off.

## Review Checklist

- Confirm the `README.md` story matches this ASCII architecture.
- Confirm every module/resource listed above is intentional for this deployment.
- Confirm required external IDs are documented before `terraform plan`.
- Confirm enable flags are set deliberately, especially for tenancy-wide, paid, or destructive resources.
- Confirm logging, IAM, security, networking, and operational hand-offs are visible in the diagram.
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

- Terraform modules, resources, data sources, or provider aliases change.
- A subnet, route, trust boundary, region, compartment, or access path changes.
- A new enable flag changes what the deployment can create.
- README usage notes describe behavior that is not represented here.
- A customer review turns an assumption into a reusable pattern.

## Terraform + Ansible Deployment Output

This is the deployment finish line for this blueprint. Terraform owns the OCI resource graph
and named outputs; Ansible gives the local operator a repeatable plan/apply/destroy wrapper
with a clean recap at the end.

```text
$ cd blueprints/cis/level2
$ terraform init
$ terraform validate
$ terraform plan -out=tfplan
$ terraform apply tfplan

Apply complete! Resources: <added> added, <changed> changed, <destroyed> destroyed.

$ terraform output
blueprint_name = "level2"
cis_level = "<cis-level>"
name_prefix = "<org>-<env>-<region_key>"
resource_ids = { ... }
root_compartment_id = "ocid1.<resource>..."
compartment_ids = { ... }
group_names = { ... }
policy_names = { ... }
vault_ids = { ... }
vault_key_ids = { ... }
security_zone_ids = { ... }
vss_host_scan_target_ids = { ... }
budget_ids = { ... }
event_rule_ids = { ... }
event_notification_topic_ids = { ... }
monitoring_alarm_ids = { ... }
```

```text
$ cd blueprints/cis/level2
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

For CIS Level 2 Landing Zone, the important hand-off values are `blueprint_name`,
`cis_level`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`,
`group_names`, `policy_names`, `vault_ids`, `vault_key_ids`, plus 6 more. Keep those names
stable unless a downstream blueprint, runbook, or customer hand-off is updated at the same
time.
