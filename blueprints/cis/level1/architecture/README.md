# CIS Level 1 Landing Zone Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/cis/level1`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Builds the core landing-zone foundation with CIS Level 1-oriented governance, security, logging, IAM, and operations controls.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/cis/level1` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Builds the core landing-zone foundation with CIS Level 1-oriented governance, security, logging, IAM, and operations controls. |
| Terraform components | `core` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `cis_level`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`, `group_names`, `policy_names`, ... |
| Runner contract | `ansible/plan.yml`, guarded `ansible/apply.yml`, and guarded `ansible/destroy.yml`. |

## Files In This Deployment

```text
blueprints/cis/level1/
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
| CIS Level 1 Landing Zone                                                                                |
|                                                                                                  |
|  Operator / CI / Ansible                                                                         |
|          | terraform plan/apply                                                                  |
|          v                                                                                       |
|  +-------------------------- OCI Tenancy / Home Region IAM ---------------------------+          |
|  | Compartments                                                                       |          |
|  |   root/parent -> governance, security, network, workloads                          |          |
|  | IAM                                                                                |          |
|  |   admin groups + dynamic groups -> policies scoped to compartments                 |          |
|  | Tagging                                                                            |          |
|  |   namespace, tag definitions, tag defaults applied to landing-zone compartments     |          |
|  +-------------------------------+----------------------------------------------------+          |
|                                  |                                                               |
|                                  v                                                               |
|  +---------------------- Governance Compartment ----------------------+                           |
|  | Logging: log groups, service logs, VCN flow-log targets, saved searches            |           |
|  | Audit retention: tenancy audit configuration                                       |           |
|  | Budgets: cost targets and alert rules                                              |           |
|  | Events + Notifications: event rules -> ONS topics/subscriptions                    |           |
|  | Monitoring: alarms -> notification topics/subscriptions                            |           |
|  +-------------------------------+----------------------------------------------------+          |
|                                  | signals, alarms, events                                      |
|                                  v                                                               |
|  +----------------------- Security Compartment -----------------------+                           |
|  | Cloud Guard configuration and targets watch the root/landing-zone compartments      |           |
|  | Vault/KMS creates vaults and master encryption keys for downstream resources        |           |
|  | Security zones remain optional; Level 1 emphasizes baseline monitoring, audit, IAM, and encryption                |           |
|  | Vulnerability Scanning Service creates host/container scan recipes and targets      |           |
|  +-------------------------------+----------------------------------------------------+          |
|                                  | outputs consumed by network, app, data, compliance blueprints |
|                                  v                                                               |
|  resource_ids, compartment_ids, policy_ids, vault_key_ids, log_group_ids, alarm_ids               |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `core` | `blueprints/core @ v0.2.0` |

## Request And Deployment Flow

- The wrapper passes cis_level = level1 into the core blueprint.
- Core creates the baseline compartment, IAM, logging, Cloud Guard, Vault, scanning, budgets, events, and monitoring controls.
- Outputs are the same core hand-off contract so Level 1 can feed later network and workload deployments.

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
|-- cis_level
|-- name_prefix
|-- resource_ids
|-- root_compartment_id
|-- compartment_ids
|-- group_names
|-- policy_names
|-- vault_ids
|-- vault_key_ids
|-- security_zone_ids
|-- vss_host_scan_target_ids
|-- budget_ids
|-- event_rule_ids
|-- event_notification_topic_ids
`-- monitoring_alarm_ids
```

## Operational Boundaries

- Review enable flags before apply, especially for paid, tenancy-wide, identity, network edge, database, or destructive resources.
- Confirm required external IDs are real and in the intended region and compartment before running `terraform plan`.
- Keep apply and destroy behind the guarded Ansible runners or an equivalent approval gate.
- Treat route tables, firewall policies, ZPR policies, identity policies, and domain replication as change-controlled surfaces.
- Run repository validation before commit or hand-off.

## Review Checklist

- Confirm the diagram matches `main.tf`: `core`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `cis_level`, `name_prefix`, `resource_ids`, `root_compartment_id`, `compartment_ids`, `group_names`, `policy_names`, `vault_ids`, `vault_key_ids`, `security_zone_ids`, `vss_host_scan_target_ids`, ....
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

This is the expected close-out shape for `blueprints/cis/level1`. Terraform owns the OCI resource graph and
named outputs; Ansible gives the operator a repeatable plan/apply/destroy wrapper with a
clear recap.

```text
$ cd blueprints/cis/level1
$ terraform init
$ terraform validate
$ terraform plan -out=tfplan
$ terraform apply tfplan

Apply complete! Resources: <added> added, <changed> changed, <destroyed> destroyed.

$ terraform output
blueprint_name = "<value>"
cis_level = "<value>"
name_prefix = "<value>"
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
$ cd blueprints/cis/level1
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
