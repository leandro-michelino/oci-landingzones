# Full Stack Disaster Recovery

Use this page as the operator guide for `blueprints/disaster-recovery/fsdr`. It tells you
what the blueprint builds, which inputs deserve a real review, how to run Terraform or the
local Ansible wrappers, and where to find the detailed Architecture design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/disaster-recovery/fsdr` |
| Best fit | Creates OCI Full Stack Disaster Recovery primary and standby protection groups, log buckets, and DR plan wiring. |
| Terraform shape | `oci_objectstorage_bucket.primary_dr_logs`, `oci_objectstorage_bucket.standby_dr_logs`, `oci_disaster_recovery_dr_protection_group.primary`, `oci_disaster_recovery_dr_protection_group.standby`, `oci_disaster_recovery_dr_plan.primary`, plus 2 more |
| Inputs to settle first | `standby_region`, `standby_region_key`, `compartment_ocid`, `primary_compartment_ocid`, `standby_compartment_ocid`, `primary_log_bucket_name`, `standby_log_bucket_name`, plus 7 more |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `standby_name_prefix`, `resource_ids`, `primary_dr_protection_group_id`, `standby_dr_protection_group_id`, `primary_log_bucket_name`, plus 2 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Creates OCI Full Stack Disaster Recovery primary and standby protection groups, log
buckets, and DR plan wiring.

## When To Use This Deployment

- A workload needs OCI FSDR orchestration.
- Primary and standby regions are already selected.
- Protection groups and plan execution need a documented review path.
- You want a reusable control-plane baseline for repeated FSDR drills without
  recreating application resources each time.

## Use Cases

| Use Case | What This Blueprint Provides | What The Workload Must Provide |
| --- | --- | --- |
| Regional switchover drill | Primary and standby DR protection groups, log buckets, and optional plan wiring. | Replicated compute volumes, destination network mappings, and a reviewed switchover plan created from the current standby DRPG. |
| Movable compute recovery | FSDR control plane and log locations. | Compute instances whose attached boot and block volumes are in replicated volume groups, plus destination subnets and hostname/IP choices. |
| Object Storage recovery | DRPGs and log buckets. | Source and destination buckets with Object Storage replication policy configured before adding the bucket as an FSDR member. |
| Database stack orchestration | FSDR DRPGs and plan hand-off points. | Data Guard, Autonomous Database refreshable clone/cross-region design, or the database-specific DR topology required by the service. |
| Customer demo or lab | A stable DRPG baseline plus the optional lab in `examples/real-dr-lab`. | Disposable workload resources, IAM approval, and cleanup discipline after the drill. |

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_objectstorage_bucket.primary_dr_logs` | Declared directly in `main.tf` |
| Resource | `oci_objectstorage_bucket.standby_dr_logs` | Declared directly in `main.tf` |
| Resource | `oci_disaster_recovery_dr_protection_group.primary` | Declared directly in `main.tf` |
| Resource | `oci_disaster_recovery_dr_protection_group.standby` | Declared directly in `main.tf` |
| Resource | `oci_disaster_recovery_dr_plan.primary` | Declared directly in `main.tf` |
| Data source | `data.oci_objectstorage_namespace.primary` | Read during plan/apply |
| Data source | `data.oci_objectstorage_namespace.standby` | Read during plan/apply |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/disaster-recovery/fsdr/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
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
| `region` | Primary OCI region name. |
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short primary OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `standby_region` | Standby OCI region name. |
| `standby_region_key` | Short standby OCI region key used in resource names. |
| `compartment_ocid` | Default compartment OCID for FSDR resources. Defaults to tenancy_ocid. |
| `primary_compartment_ocid` | Primary-region compartment OCID for FSDR resources. |
| `standby_compartment_ocid` | Standby-region compartment OCID for FSDR resources. |
| `primary_log_bucket_name` | Optional primary-region DR log bucket name. |
| `standby_log_bucket_name` | Optional standby-region DR log bucket name. |
| `log_bucket_storage_tier` | Object Storage tier for DR log buckets. |
| `primary_dr_protection_group_name` | Optional display name for the primary DR protection group. |
| `standby_dr_protection_group_name` | Optional display name for the standby DR protection group. |
| `primary_members` | Primary DR protection group members. |
| `standby_members` | Standby DR protection group members. |
| `dr_plan_display_name` | Optional display name for the primary DR plan. |
| `dr_plan_type` | FSDR plan type, such as SWITCHOVER or FAILOVER. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_dr_log_buckets` | Create Object Storage buckets used by DR protection group logs. |
| `enable_object_events` | Enable Object Storage events on DR log buckets. |
| `enable_bucket_versioning` | Enable versioning on DR log buckets. |
| `enable_dr_protection_groups` | Create primary and standby FSDR protection groups. |
| `enable_dr_plan` | Create a DR plan for the primary protection group. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for primary-region resources. |
| `standby_name_prefix` | Standard OCI naming prefix for standby-region resources. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `primary_dr_protection_group_id` | Primary DR protection group OCID. |
| `standby_dr_protection_group_id` | Standby DR protection group OCID. |
| `primary_log_bucket_name` | Primary DR log bucket name. |
| `standby_log_bucket_name` | Standby DR log bucket name. |
| `primary_dr_plan_id` | Primary DR plan OCID. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/disaster-recovery/fsdr
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/disaster-recovery/fsdr
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Optional Real DR Lab

This blueprint intentionally does not create application resources. To help customers
simulate a real drill, the folder includes an optional lab harness:

```text
examples/real-dr-lab/
```

The lab creates disposable primary/standby VCNs, subnets, Object Storage buckets, a
small primary compute instance, and a replicated boot-volume volume group. It then
outputs the resource IDs and FSDR member hints needed for compute, storage, and
volume-group registration.

Use it when you want to demonstrate the same pattern as a real São Paulo to Vinhedo
test: deploy the FSDR control plane first, deploy the lab workload second, add members
to the current primary DRPG, generate the switchover plan from the current standby DRPG,
run precheck, execute switchover, then switch back.

Keep the lab separate from production state:

```bash
cd blueprints/disaster-recovery/fsdr/examples/real-dr-lab
mkdir -p .work
cp *.tf.example .work/
cp terraform.tfvars.example .work/
for file in .work/*.tf.example; do mv "$file" "${file%.example}"; done
cd .work
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

The lab files are checked in with the `.tf.example` suffix so the repo validator treats
them as a customer simulation harness, not as another managed blueprint entry point.
Keep generated `.tf` files and local Terraform working data in `.work/`.

After the drill, remove FSDR members and plans first, then destroy the lab:

```bash
cd blueprints/disaster-recovery/fsdr/examples/real-dr-lab/.work
terraform destroy
```

The lab is intentionally explicit about cleanup because volume-group and boot-volume
replication can preserve resources after compute termination. If manual cleanup is
needed, disable volume or boot-volume replicas before deleting the preserved volumes.

## Deployment Order

1. Confirm primary and standby regions.
2. Review protected resource IDs and DR group membership.
3. Populate `terraform.tfvars` with region and DR inputs.
4. Run plan and review FSDR objects.
5. Apply infrastructure only; keep failover execution in the runbook flow.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Keep drills and failover execution outside normal Terraform apply until reviewed.
- Confirm primary and standby region providers.
- Validate protected resources and IAM permissions before activation.
- Create and execute switchover or failover plans from the current standby DR protection group.
- For movable compute, confirm every attached boot and block volume is covered by a replicated volume group that is also an FSDR member.
- For Object Storage members, confirm bucket replication is active before plan generation.
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
