# Core Landing Zone Blueprint Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This is the design view for `blueprints/core`. It stays ASCII-first on purpose so you can
review the deployment in GitHub, a terminal, a pull request, or customer notes without a
diagramming tool.

## Deployment Purpose

Builds the shared OCI foundation: compartments, IAM, tagging, logging, Cloud Guard,
Vault/KMS, Security Zones, VSS, budgets, events, and monitoring.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/core` owns this deployment end to end. |
| Terraform components | `compartments`, `tagging`, `logging`, `cloud_guard`, `vault`, `security_zones`, `vss`, `budgets`, plus 5 more |
| Input source | `terraform.tfvars.example` documents the shape; local ignored tfvars provide real values. |
| Output contract | `blueprint_name`, `name_prefix`, `cis_level`, `root_compartment_id`, `compartment_ids`, `network_compartment_id`, `security_compartment_id`, `governance_compartment_id`, plus 43 more |
| Runner contract | `ansible/plan.yml`, guarded `ansible/apply.yml`, and guarded `ansible/destroy.yml`. |

## Files In This Deployment

```text
blueprints/core/
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
| Core Landing Zone                                                                                    |
| Folder: blueprints/core                                                                              |
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
| 01. module.compartments -> modules/iam/compartments @ v0.1.0                                         |
| 02. module.tagging -> modules/governance/tagging @ v0.1.0                                            |
| 03. module.logging -> modules/governance/logging @ v0.1.0                                            |
| 04. module.cloud_guard -> modules/security/cloud-guard @ v0.1.0                                      |
| 05. module.vault -> modules/security/vault @ v0.1.0                                                  |
| 06. module.security_zones -> modules/security/security-zones @ v0.1.0                                |
| 07. module.vss -> modules/security/vss @ v0.1.0                                                      |
| 08. module.budgets -> modules/governance/budgets @ v0.1.0                                            |
| 09. module.events -> modules/governance/events @ v0.1.0                                              |
| 10. module.monitoring -> modules/operations/monitoring @ v0.1.0                                      |
| 11. module.groups -> modules/iam/groups @ v0.1.0                                                     |
| 12. module.dynamic_groups -> modules/iam/dynamic-groups @ v0.1.0                                     |
| 13. module.policies -> modules/iam/policies @ v0.1.0                                                 |
|                                                                                                      |
| [4] OCI/resource planes                                                                              |
| - Control: provider config, tenancy context, naming inputs, and local tfvars.                        |
| - Foundation: compartments, IAM, tag namespaces, logging, Cloud Guard, Vault/KMS, Security Zones,    |
| VSS, budgets, events, and monitoring.                                                                |
| - Consumption: stable outputs for networking, operating entity, compliance, and extension            |
| blueprints.                                                                                          |
| - Operations: Ansible plan/apply/destroy wrappers, validation, and cleanup.                          |
|                                                                                                      |
| [5] Output hand-off                                                                                  |
| - blueprint_name: Blueprint identifier.                                                              |
| - name_prefix: Standard OCI naming prefix for resources created by this blueprint.                   |
| - cis_level: Selected CIS OCI Benchmark profile, when this core is wrapped by a CIS blueprint.       |
| - root_compartment_id: OCID of the landing zone root compartment.                                    |
| - compartment_ids: Map of landing zone compartment keys to OCIDs.                                    |
| - network_compartment_id: OCID of the landing zone network compartment.                              |
| - security_compartment_id: OCID of the landing zone security compartment.                            |
| - governance_compartment_id: OCID of the landing zone governance compartment.                        |
| - workloads_compartment_id: OCID of the landing zone workloads compartment.                          |
| - compartment_names: Map of landing zone compartment keys to display names.                          |
| - tag_namespace_id: OCID of the landing zone tag namespace.                                          |
| - tag_namespace_name: Name of the landing zone tag namespace.                                        |
| - plus 39 more outputs declared in outputs.tf                                                        |
|                                                                                                      |
| [6] Deployment close-out                                                                             |
| terraform output and the Ansible PLAY RECAP are the human and automation hand-off.                   |
| Generated .terraform directories, lock files, plans, state files, and local tfvars stay out of git.  |
+------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `compartments` | `modules/iam/compartments @ v0.1.0` |
| Module | `tagging` | `modules/governance/tagging @ v0.1.0` |
| Module | `logging` | `modules/governance/logging @ v0.1.0` |
| Module | `cloud_guard` | `modules/security/cloud-guard @ v0.1.0` |
| Module | `vault` | `modules/security/vault @ v0.1.0` |
| Module | `security_zones` | `modules/security/security-zones @ v0.1.0` |
| Module | `vss` | `modules/security/vss @ v0.1.0` |
| Module | `budgets` | `modules/governance/budgets @ v0.1.0` |
| Module | `events` | `modules/governance/events @ v0.1.0` |
| Module | `monitoring` | `modules/operations/monitoring @ v0.1.0` |
| Module | `groups` | `modules/iam/groups @ v0.1.0` |
| Module | `dynamic_groups` | `modules/iam/dynamic-groups @ v0.1.0` |
| Module | `policies` | `modules/iam/policies @ v0.1.0` |

## Request And Deployment Flow

- Operator reviews tenancy, governance, IAM, logging, security, and monitoring inputs.
- Terraform builds the shared foundation in dependency order.
- Outputs become the hand-off contract for networking, operating entity, compliance, and extension blueprints.
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
$ cd blueprints/core
$ terraform init
$ terraform validate
$ terraform plan -out=tfplan
$ terraform apply tfplan

Apply complete! Resources: <added> added, <changed> changed, <destroyed> destroyed.

$ terraform output
blueprint_name = "core"
name_prefix = "<org>-<env>-<region_key>"
cis_level = "<cis-level>"
root_compartment_id = "ocid1.<resource>..."
compartment_ids = { ... }
network_compartment_id = "ocid1.<resource>..."
security_compartment_id = "ocid1.<resource>..."
governance_compartment_id = "ocid1.<resource>..."
workloads_compartment_id = "ocid1.<resource>..."
compartment_names = { ... }
tag_namespace_id = "ocid1.<resource>..."
tag_namespace_name = "<name>"
tag_definition_ids = { ... }
log_group_ids = { ... }
log_group_names = { ... }
service_log_ids = { ... }
logging_saved_search_ids = { ... }
audit_configuration_id = "ocid1.<resource>..."
cloud_guard_configuration_id = "ocid1.<resource>..."
cloud_guard_target_ids = { ... }
cloud_guard_target_names = { ... }
vault_ids = { ... }
vault_management_endpoints = { ... }
vault_crypto_endpoints = { ... }
vault_key_ids = { ... }
security_zone_ids = { ... }
security_zone_names = { ... }
security_zone_target_ids = { ... }
vss_host_scan_recipe_ids = { ... }
vss_host_scan_target_ids = { ... }
vss_container_scan_recipe_ids = { ... }
vss_container_scan_target_ids = { ... }
budget_ids = { ... }
budget_names = { ... }
budget_alert_rule_ids = { ... }
event_notification_topic_ids = { ... }
event_notification_topic_names = { ... }
event_subscription_ids = { ... }
event_rule_ids = { ... }
event_rule_names = { ... }
monitoring_notification_topic_ids = { ... }
monitoring_subscription_ids = { ... }
monitoring_alarm_ids = { ... }
monitoring_alarm_names = { ... }
group_ids = { ... }
group_names = { ... }
dynamic_group_ids = { ... }
dynamic_group_names = { ... }
policy_ids = { ... }
policy_names = { ... }
resource_ids = { ... }
```

```text
$ cd blueprints/core
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

For Core Landing Zone, the important hand-off values are `blueprint_name`, `name_prefix`,
`cis_level`, `root_compartment_id`, `compartment_ids`, `network_compartment_id`,
`security_compartment_id`, `governance_compartment_id`, `workloads_compartment_id`,
`compartment_names`, plus 41 more. Keep those names stable unless a downstream blueprint,
runbook, or customer hand-off is updated at the same time.
