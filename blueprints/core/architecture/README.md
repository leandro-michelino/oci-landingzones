# Core Landing Zone Blueprint Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This architecture page documents the `blueprints/core` deployment. It is intentionally text-first and ASCII-only so it can be reviewed in terminals, pull requests, and customer notes without a diagramming tool.

## Deployment Purpose

This blueprint provides shared landing-zone foundation for compartments, IAM,
governance, logging, security, events, monitoring, and optional guardrail services.

## Files In This Deployment

```text
blueprints/core/
|-- README.md                         Human-friendly deployment notes
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
+--------------------------------------------------------------------------------------------+
| Core Landing Zone Blueprint                                                                |
| blueprints/core                                                                            |
+--------------------------------------------------------------------------------------------+
| Operator / CI / local shell                                                                |
|   |                                                                                        |
|   v                                                                                        |
+--------------------------------------------------------------------------------------------+
| Blueprint folder contract                                                                  |
|   README.md                                                                                |
|   architecture/README.md                                                                   |
|   main.tf + variables.tf + outputs.tf + providers.tf + versions.tf                         |
|   ansible/plan.yml + apply.yml + destroy.yml                                               |
+--------------------------------------------------------------------------------------------+
|   |                                                                                        |
|   v                                                                                        |
+--------------------------------------------------------------------------------------------+
| Terraform composition and OCI resources                                                    |
|  01. module   compartments                                     (main.tf)                   |
|  02. module   tagging                                          (main.tf)                   |
|  03. module   logging                                          (main.tf)                   |
|  04. module   cloud_guard                                      (main.tf)                   |
|  05. module   vault                                            (main.tf)                   |
|  06. module   security_zones                                   (main.tf)                   |
|  07. module   vss                                              (main.tf)                   |
|  08. module   budgets                                          (main.tf)                   |
|  09. module   events                                           (main.tf)                   |
|  10. module   monitoring                                       (main.tf)                   |
|  11. module   groups                                           (main.tf)                   |
|  12. module   dynamic_groups                                   (main.tf)                   |
|  13. module   policies                                         (main.tf)                   |
+--------------------------------------------------------------------------------------------+
|   |                                                                                        |
|   v                                                                                        |
+--------------------------------------------------------------------------------------------+
| Architecture layers                                                                        |
|   - Control plane: Terraform provider and blueprint variables                              |
|   - Foundation plane: compartments, tags, IAM, logging, security, and operations modules   |
|   - Consumption plane: outputs used by networking, operating entity, and extension blueprin|
|   - Operations plane: Ansible runners, validation, and cleanup                             |
+--------------------------------------------------------------------------------------------+
|   |                                                                                        |
|   v                                                                                        |
+--------------------------------------------------------------------------------------------+
| Outputs and hand-off                                                                       |
|   resource_ids plus blueprint-specific IDs                                                 |
|   tfvars reviewed before apply                                                             |
|   generated Terraform artifacts cleaned after validation                                   |
+--------------------------------------------------------------------------------------------+
```

## Terraform Components

- `module compartments` in `main.tf`: composes the reusable compartments module or child blueprint.
- `module tagging` in `main.tf`: composes the reusable tagging module or child blueprint.
- `module logging` in `main.tf`: composes the reusable logging module or child blueprint.
- `module cloud_guard` in `main.tf`: composes the reusable cloud guard module or child blueprint.
- `module vault` in `main.tf`: composes the reusable vault module or child blueprint.
- `module security_zones` in `main.tf`: composes the reusable security zones module or child blueprint.
- `module vss` in `main.tf`: composes the reusable vss module or child blueprint.
- `module budgets` in `main.tf`: composes the reusable budgets module or child blueprint.
- `module events` in `main.tf`: composes the reusable events module or child blueprint.
- `module monitoring` in `main.tf`: composes the reusable monitoring module or child blueprint.
- `module groups` in `main.tf`: composes the reusable groups module or child blueprint.
- `module dynamic_groups` in `main.tf`: composes the reusable dynamic groups module or child blueprint.
- `module policies` in `main.tf`: composes the reusable policies module or child blueprint.

## Request And Deployment Flow

- Operator reviews tfvars and chooses the plan/apply runner.
- Terraform builds the foundation in dependency order.
- Outputs become the hand-off contract for dependent blueprints.
- Validation checks fmt, init, validate, and Ansible syntax.

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
|-- blueprint_name and name_prefix identify the deployment
|-- resource_ids summarizes primary resources in a machine-friendly map
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

The repository validator checks Terraform formatting, initializes and validates every blueprint without a backend, syntax-checks the root Ansible playbooks, syntax-checks every blueprint-local Ansible runner, and removes generated Terraform artifacts afterward.

## When To Update This Architecture

- Terraform modules, resources, data sources, or provider aliases change.
- A subnet, route, trust boundary, region, compartment, or access path changes.
- A new enable flag changes what the deployment can create.
- README usage notes describe behavior that is not represented here.
- A customer review turns an assumption into a reusable pattern.

## Terraform + Ansible Deployment Output

This is the deployment finish line for this blueprint. Terraform owns the OCI resource graph and named outputs; Ansible gives the local operator a repeatable plan/apply/destroy wrapper with a clean recap at the end.

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

For Core, the important hand-off values are `blueprint_name`, `name_prefix`, `cis_level`, `root_compartment_id`, `compartment_ids`, `network_compartment_id`, `security_compartment_id`, `governance_compartment_id`, and the remaining outputs declared in `outputs.tf`. Keep those names stable unless a downstream blueprint, runbook, or customer hand-off is updated at the same time.
