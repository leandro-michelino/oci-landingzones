# AWS + OCI Cross-Cloud DR

Use this page as the operator guide for
`blueprints/disaster-recovery/aws-oci-cross-cloud-dr`. It tells you what the
blueprint builds, which inputs deserve a real review, how to run Terraform or
the local Ansible wrappers, and where to find the detailed Architecture design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/disaster-recovery/aws-oci-cross-cloud-dr` |
| Best fit | Cross-cloud DR contract with OCI primary and AWS standby, DNS failover runbook metadata, and interconnect or no-interconnect connectivity modes. |
| Terraform shape | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_app`, `oci_core_subnet.primary_app`, `oci_objectstorage_bucket.dr_evidence`, `oci_ons_notification_topic.dr_alert`, `terraform_data.connectivity_contract`, `terraform_data.dns_failover_contract`, `terraform_data.runbook_contract` |
| Inputs to settle first | `connectivity_mode`, `fastconnect_virtual_circuit_id`, `direct_connect_connection_id`, `app_fqdn`, `oci_primary_endpoint`, `aws_standby_endpoint`, `target_rto_minutes`, `target_rpo_minutes` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `primary_target`, `standby_target`, `connectivity_contract`, `dns_failover_contract`, `runbook_contract` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Implements a cross-cloud DR pattern where OCI is primary and AWS is standby,
with explicit DNS failover runbook contracts and connectivity operation either
through interconnect or without interconnect.

## When To Use This Deployment

- The primary app target should remain in OCI.
- AWS is the DR standby environment.
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
| Resource | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_app`, `oci_core_subnet.primary_app` | Optional OCI primary networking stack with wired routes and security controls. |
| Resource | `terraform_data.connectivity_contract` | Connectivity contract for interconnect or no-interconnect mode. |
| Resource | `terraform_data.dns_failover_contract` | DNS failover contract with primary/standby endpoints and TTL assumptions. |
| Resource | `terraform_data.runbook_contract` | Failover/failback execution contract with RTO/RPO metadata. |

The exact OCI behavior is controlled by `variables.tf` and the values supplied
in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/disaster-recovery/aws-oci-cross-cloud-dr/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
|-- main.tf                    Terraform modules, resources, and data sources
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
|-- hello-world/index.html     Sample DR status page for runbook demos
|-- aws/
|   |-- main.yaml             AWS standby deployment template
|   |-- parameters.example.json Example AWS deployment parameters
|   `-- README.md              AWS session guide
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    |-- destroy.yml            Guarded destroy
    |-- aws-plan.yml         AWS plan session for DR standby
    |-- aws-apply.yml        AWS apply session for DR standby
    |-- aws-destroy.yml      AWS destroy session for DR standby
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
| `enable_oci_primary_network` | When true, creates OCI primary VCN, route table, security list, and app subnet. |
| `oci_primary_vcn_cidr` | CIDR for OCI primary VCN. |
| `oci_primary_app_subnet_cidr` | CIDR for OCI primary application subnet. |
| `oci_primary_ingress_allowed_cidr` | Allowed source CIDR for OCI primary application ingress. |
| `connectivity_mode` | Select `interconnect` or `without-interconnect`. |
| `fastconnect_virtual_circuit_id` | FastConnect virtual circuit OCID when using interconnect mode. |
| `direct_connect_connection_id` | Direct Connect connection ID when using interconnect mode. |
| `enable_dr_evidence_bucket` | Create evidence bucket for DR drill and incident artifacts. |
| `dr_evidence_bucket_name` | Optional custom evidence bucket name. |
| `enable_dr_alert_topic` | Create DR alert topic for notifications. |
| `dr_alert_topic_name` | Optional custom DR alert topic name. |
| `app_fqdn` | Application FQDN used for DNS failover. |
| `oci_primary_endpoint` | OCI primary endpoint for DNS steering. |
| `aws_standby_endpoint` | AWS standby endpoint for DNS steering. |
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
| `standby_target` | AWS standby cloud target metadata. |
| `connectivity_contract` | Connectivity operation mode and interconnect identifiers. |
| `dns_failover_contract` | DNS runbook contract for primary/standby cutover. |
| `runbook_contract` | Failover/failback runbook metadata with RTO/RPO targets. |
| `dr_evidence_bucket_name` | Evidence bucket name for drills and incident artifacts. |
| `dr_alert_topic_id` | DR alert topic OCID. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/disaster-recovery/aws-oci-cross-cloud-dr
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across
the repo:

```bash
cd blueprints/disaster-recovery/aws-oci-cross-cloud-dr
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

AWS full deployment session (standby side):

```bash
cd blueprints/disaster-recovery/aws-oci-cross-cloud-dr
ansible-playbook -i localhost, ansible/aws-plan.yml
CONFIRM_AWS_APPLY=true ansible-playbook -i localhost, ansible/aws-apply.yml
CONFIRM_AWS_DESTROY=true ansible-playbook -i localhost, ansible/aws-destroy.yml
```

For required AWS variables and parameters, review `aws/README.md`.
AWS session playbooks use the shared role
`ansible/roles/aws_deployment_runner` for consistent behavior.

E2E note: the AWS standby EC2 instance needs outbound HTTPS during first boot
for package repositories, SSM, and managed service endpoints. The template also
associates a public IP before the EIP attachment settles so the hello-world
bootstrap can complete reliably in ephemeral public-subnet tests. Scope inbound
HTTP/HTTPS with `AllowedIngressCidr`; use a narrow operator CIDR for E2E.

## Deployment Order

1. Confirm OCI remains primary and AWS remains standby for this environment.
2. Confirm connectivity mode (`interconnect` or `without-interconnect`) and ownership.
3. Populate `terraform.tfvars` with endpoints, FQDN, and DR objectives.
4. Run plan and review connectivity, DNS failover, and runbook contract outputs.
5. Apply, then execute failover drills using the contract outputs as runbook references.

## Architecture

The full detailed Architecture is local to this deployment:

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
- Confirm AWS standby hello-world returns HTTP `200` before using the endpoint
  in OCI DNS/runbook contracts.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Hello World Page

Use the sample page at `hello-world/index.html` as a lightweight status/demo
artifact for DR rehearsals and runbook walkthroughs. It intentionally reflects
this blueprint contract: OCI primary, AWS standby, DNS failover flow, and
connectivity mode choices.

Run it as a real local endpoint:

```bash
cd blueprints/disaster-recovery/aws-oci-cross-cloud-dr
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
