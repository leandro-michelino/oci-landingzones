# Azure + OCI Cross-Cloud DR

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for
`blueprints/disaster-recovery/azure-oci-cross-cloud-dr`. It tells you what the
blueprint builds, which inputs deserve a real review, how to run Terraform or
the local Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr` |
| Best fit | Cross-cloud DR contract with OCI primary and Azure standby, DNS failover runbook metadata, and interconnect or no-interconnect connectivity modes. |
| Terraform shape | `oci_objectstorage_bucket.dr_evidence`, `oci_ons_notification_topic.dr_alert`, `terraform_data.connectivity_contract`, `terraform_data.dns_failover_contract`, `terraform_data.runbook_contract` |
| Inputs to settle first | `connectivity_mode`, `fastconnect_virtual_circuit_id`, `expressroute_circuit_id`, `app_fqdn`, `oci_primary_endpoint`, `azure_standby_endpoint`, `target_rto_minutes`, `target_rpo_minutes` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `primary_target`, `standby_target`, `connectivity_contract`, `dns_failover_contract`, `runbook_contract` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Implements a cross-cloud DR pattern where OCI is primary and Azure is standby,
with explicit DNS failover runbook contracts and connectivity operation either
through interconnect or without interconnect.

## When To Use This Deployment

- The primary app target should remain in OCI.
- Azure is the DR standby environment.
- You need explicit failover/failback runbook contracts and DNS cutover metadata.
- Connectivity must support either partner interconnect or an explicit no-interconnect operating mode.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the
OCI resource graph and DR operating contracts, while the local Ansible files
provide the same plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Data source | `data.oci_objectstorage_namespace.this` | Read during plan/apply for evidence bucket namespace. |
| Resource | `oci_objectstorage_bucket.dr_evidence` | Optional DR drill and incident evidence bucket. |
| Resource | `oci_ons_notification_topic.dr_alert` | Optional DR alert topic for runbook notifications. |
| Resource | `terraform_data.connectivity_contract` | Connectivity contract for interconnect or no-interconnect mode. |
| Resource | `terraform_data.dns_failover_contract` | DNS failover contract with primary/standby endpoints and TTL assumptions. |
| Resource | `terraform_data.runbook_contract` | Failover/failback execution contract with RTO/RPO metadata. |

The exact OCI behavior is controlled by `variables.tf` and the values supplied
in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/disaster-recovery/azure-oci-cross-cloud-dr/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed ASCII architecture for this deployment
|-- main.tf                    Terraform modules, resources, and data sources
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
|-- hello-world/index.html     Sample DR status page for runbook demos
|-- azure/
|   |-- main.bicep             Azure standby deployment template
|   |-- parameters.example.json Example Azure deployment parameters
|   `-- README.md              Azure session guide
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    |-- destroy.yml            Guarded destroy
    |-- azure-plan.yml         Azure what-if session for DR standby
    |-- azure-apply.yml        Azure apply session for DR standby
    |-- azure-destroy.yml      Azure destroy session for DR standby
    |-- serve-hello-world.yml  Start local DR hello-world endpoint
    `-- stop-hello-world.yml   Stop local DR hello-world endpoint
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real IDs, endpoints, names, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
| --- | --- |
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region name for primary resources and contracts. |
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
| `oci_is_primary` | Must remain `true` in this blueprint variant. |
| `connectivity_mode` | Select `interconnect` or `without-interconnect`. |
| `fastconnect_virtual_circuit_id` | FastConnect virtual circuit OCID when using interconnect mode. |
| `expressroute_circuit_id` | ExpressRoute circuit ID when using interconnect mode. |
| `enable_dr_evidence_bucket` | Create evidence bucket for DR drill and incident artifacts. |
| `dr_evidence_bucket_name` | Optional custom evidence bucket name. |
| `enable_dr_alert_topic` | Create DR alert topic for notifications. |
| `dr_alert_topic_name` | Optional custom DR alert topic name. |
| `app_fqdn` | Application FQDN used for DNS failover. |
| `oci_primary_endpoint` | OCI primary endpoint for DNS steering. |
| `azure_standby_endpoint` | Azure standby endpoint for DNS steering. |
| `dns_ttl_seconds` | TTL assumption for runbook cutover timing. |
| `dr_drill_frequency` | DR drill cadence expectation. |
| `target_rto_minutes` | Target recovery time objective. |
| `target_rpo_minutes` | Target recovery point objective. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks,
customer notes, or manual hand-off. If an output name changes, update dependent
docs and consumers in the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `primary_target` | OCI primary cloud target metadata. |
| `standby_target` | Azure standby cloud target metadata. |
| `connectivity_contract` | Connectivity operation mode and interconnect identifiers. |
| `dns_failover_contract` | DNS runbook contract for primary/standby cutover. |
| `runbook_contract` | Failover/failback runbook metadata with RTO/RPO targets. |
| `dr_evidence_bucket_name` | Evidence bucket name for drills and incident artifacts. |
| `dr_alert_topic_id` | DR alert topic OCID. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/disaster-recovery/azure-oci-cross-cloud-dr
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across
the repo:

```bash
cd blueprints/disaster-recovery/azure-oci-cross-cloud-dr
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

Azure full deployment session (standby side):

```bash
cd blueprints/disaster-recovery/azure-oci-cross-cloud-dr
ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```

For required Azure variables and parameters, review `azure/README.md`.

## Deployment Order

1. Confirm OCI remains primary and Azure remains standby for this environment.
2. Confirm connectivity mode (`interconnect` or `without-interconnect`) and ownership.
3. Populate `terraform.tfvars` with endpoints, FQDN, and DR objectives.
4. Run plan and review connectivity, DNS failover, and runbook contract outputs.
5. Apply, then execute failover drills using the contract outputs as runbook references.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow,
state and output contract, operational boundaries, review checklist, and the
expected Terraform + Ansible output at the end of the deployment.

## Review Before Apply

- Confirm OCI remains primary for this pattern.
- Confirm connectivity mode choice and interconnect IDs if using interconnect.
- Confirm DNS endpoint targets and TTL assumptions.
- Confirm runbook objectives (RTO/RPO) match business requirements.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Hello World Page

Use the sample page at `hello-world/index.html` as a lightweight status/demo
artifact for DR rehearsals and runbook walkthroughs. It intentionally reflects
this blueprint contract: OCI primary, Azure standby, DNS failover flow, and
connectivity mode choices.

Run it as a real local endpoint:

```bash
cd blueprints/disaster-recovery/azure-oci-cross-cloud-dr
ansible-playbook -i localhost, ansible/serve-hello-world.yml
# open http://127.0.0.1:18081
ansible-playbook -i localhost, ansible/stop-hello-world.yml
```

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files,
required architecture README sections, `terraform init -backend=false`,
`terraform validate`, root Ansible syntax, blueprint-local Ansible syntax,
optional scanners when installed, and cleanup of generated Terraform artifacts.
