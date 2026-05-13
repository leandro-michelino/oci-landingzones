# Full Stack Disaster Recovery Blueprint Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This architecture page documents the `blueprints/disaster-recovery/fsdr` deployment. It is intentionally text-first and ASCII-only so it can be reviewed in terminals, pull requests, and customer notes without a diagramming tool.

## Deployment Purpose

This blueprint provides Full Stack Disaster Recovery foundation with primary and standby
log buckets, DR protection groups, and optional DR plan.

## Files In This Deployment

```text
blueprints/disaster-recovery/fsdr/
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
+------------------------------------------------------------------------------------+
| Full Stack Disaster Recovery Blueprint                                             |
| blueprints/disaster-recovery/fsdr                                                  |
+------------------------------------------------------------------------------------+
| Operator / CI / local shell                                                        |
|   |                                                                                |
|   v                                                                                |
+------------------------------------------------------------------------------------+
| Blueprint folder contract                                                          |
|   README.md                                                                        |
|   architecture/README.md                                                           |
|   main.tf + variables.tf + outputs.tf + providers.tf + versions.tf                 |
|   ansible/plan.yml + apply.yml + destroy.yml                                       |
+------------------------------------------------------------------------------------+
|   |                                                                                |
|   v                                                                                |
+------------------------------------------------------------------------------------+
| Terraform composition and OCI resources                                            |
|  01. data     oci_objectstorage_namespace.primary              (main.tf)           |
|  02. data     oci_objectstorage_namespace.standby              (main.tf)           |
|  03. resource oci_objectstorage_bucket.primary_dr_logs         (main.tf)           |
|  04. resource oci_objectstorage_bucket.standby_dr_logs         (main.tf)           |
|  05. resource oci_disaster_recovery_dr_protection_group.primary (main.tf)          |
|  06. resource oci_disaster_recovery_dr_protection_group.standby (main.tf)          |
|  07. resource oci_disaster_recovery_dr_plan.primary            (main.tf)           |
+------------------------------------------------------------------------------------+
|   |                                                                                |
|   v                                                                                |
+------------------------------------------------------------------------------------+
| Architecture layers                                                                |
|   - Control plane: primary and standby OCI providers                               |
|   - Data plane: Object Storage log buckets and namespace lookups                   |
|   - Recovery plane: DR protection groups, members, and optional plans              |
|   - Operations plane: validation, runbook approval, and failover/switchover executi|
+------------------------------------------------------------------------------------+
|   |                                                                                |
|   v                                                                                |
+------------------------------------------------------------------------------------+
| Outputs and hand-off                                                               |
|   resource_ids plus blueprint-specific IDs                                         |
|   tfvars reviewed before apply                                                     |
|   generated Terraform artifacts cleaned after validation                           |
+------------------------------------------------------------------------------------+
```

## Terraform Components

- `data oci_objectstorage_namespace.primary` in `main.tf`: reads the Object Storage namespace needed by buckets and endpoints.
- `data oci_objectstorage_namespace.standby` in `main.tf`: reads the Object Storage namespace needed by buckets and endpoints.
- `resource oci_objectstorage_bucket.primary_dr_logs` in `main.tf`: creates a private Object Storage bucket for data or DR logs.
- `resource oci_objectstorage_bucket.standby_dr_logs` in `main.tf`: creates a private Object Storage bucket for data or DR logs.
- `resource oci_disaster_recovery_dr_protection_group.primary` in `main.tf`: creates a Full Stack Disaster Recovery protection group.
- `resource oci_disaster_recovery_dr_protection_group.standby` in `main.tf`: creates a Full Stack Disaster Recovery protection group.
- `resource oci_disaster_recovery_dr_plan.primary` in `main.tf`: creates a DR plan for controlled failover or switchover operations.

## Request And Deployment Flow

- Operator selects primary and standby regions.
- Terraform creates/readies log buckets and namespaces.
- Primary and standby DR protection groups are built with approved members.
- Optional DR plan is created only when enable_dr_plan is true.
- Outputs feed runbooks for drill, switchover, or failover review.

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
- Confirm DR members, runbook ownership, and region pairing before any DR plan execution.
- Treat failover and switchover plans as operational change events.

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
$ cd blueprints/disaster-recovery/fsdr
$ terraform init
$ terraform validate
$ terraform plan -out=tfplan
$ terraform apply tfplan

Apply complete! Resources: <added> added, <changed> changed, <destroyed> destroyed.

$ terraform output
blueprint_name = "fsdr"
name_prefix = "<org>-<env>-<region_key>"
standby_name_prefix = "<org>-<env>-<standby_region_key>"
resource_ids = { ... }
primary_dr_protection_group_id = "ocid1.<resource>..."
standby_dr_protection_group_id = "ocid1.<resource>..."
primary_log_bucket_name = "<name>"
standby_log_bucket_name = "<name>"
primary_dr_plan_id = "ocid1.<resource>..."
```

```text
$ cd blueprints/disaster-recovery/fsdr
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

For FSDR, the important hand-off values are `blueprint_name`, `name_prefix`, `standby_name_prefix`, `resource_ids`, `primary_dr_protection_group_id`, `standby_dr_protection_group_id`, `primary_log_bucket_name`, `standby_log_bucket_name`, and the remaining outputs declared in `outputs.tf`. Keep those names stable unless a downstream blueprint, runbook, or customer hand-off is updated at the same time.
