# Telco Cloud Native Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/industry/telco-cloud-native`. It tells
you what the blueprint builds, which inputs deserve a real review, how to run Terraform or
the local Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/industry/telco-cloud-native` |
| Best fit | Composes network, vault, OKE, monitoring, and OS Management foundations for telco-oriented cloud-native workloads. |
| Terraform shape | `network`, `vault`, `oke`, `monitoring`, `os_management` |
| Inputs to settle first | `compartment_ocid`, `cluster_label`, `kubernetes_version`, `oke_endpoint_subnet_key`, `oke_service_lb_subnet_key`, `oke_node_subnet_key`, `node_shape`, plus 8 more |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `hub_subnet_ids`, `oke_cluster_id`, plus 4 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Composes network, vault, OKE, monitoring, and OS Management foundations for telco-oriented
cloud-native workloads.

## When To Use This Deployment

- Telco workloads need a cloud-native landing-zone baseline.
- OKE, network, operations, and security services need one review surface.
- Platform teams need repeatable service enablement.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `../../networking/hub-spoke-with-drg-and-three-tier-vcns` |
| Module | `vault` | `../../../modules/security/vault` |
| Module | `oke` | `../../extensions/oke` |
| Module | `monitoring` | `../../../modules/operations/monitoring` |
| Module | `os_management` | `../../../modules/operations/os-management` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/industry/telco-cloud-native/
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
| `compartment_ocid` | Compartment OCID where telco cloud-native resources are created. Defaults to tenancy_ocid. |
| `cluster_label` | Short OKE cluster label used in names. |
| `kubernetes_version` | Kubernetes version for the OKE cluster and node pool. |
| `oke_endpoint_subnet_key` | Hub subnet key used for the OKE API endpoint. |
| `oke_service_lb_subnet_key` | Hub subnet key used for OKE service load balancers. |
| `oke_node_subnet_key` | Hub subnet key used for OKE worker nodes. |
| `node_shape` | OKE worker node shape. |
| `node_shape_ocpus` | Optional OCPU count for flexible node shapes. |
| `node_shape_memory_in_gbs` | Optional memory in GB for flexible node shapes. |
| `ssh_public_key` | Optional SSH public key for OKE worker nodes. |
| `monitoring_notification_topics` | ONS notification topics keyed by logical name. |
| `monitoring_subscriptions` | ONS subscriptions keyed by logical name. |
| `monitoring_alarms` | Monitoring alarms keyed by logical name. |
| `os_managed_instance_groups` | OS Management Hub managed instance groups keyed by logical name. |
| `os_scheduled_jobs` | OS Management Hub scheduled jobs keyed by logical name. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_vault` | Create Vault resources for telco platform encryption. |
| `enable_default_vault` | Create the default telco platform vault. |
| `enable_default_key` | Create the default telco platform KMS key. |
| `enable_oke_cluster` | Create an OKE cluster for telco cloud-native workloads. |
| `enable_oke_node_pool` | Create an OKE node pool for telco workloads. |
| `enable_monitoring` | Create Monitoring resources for telco workloads. |
| `enable_default_monitoring_topic` | Create the default monitoring notification topic. |
| `enable_os_management` | Create OS Management Hub resources for telco compute fleets. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `hub_vcn_id` | Telco hub VCN OCID. |
| `drg_id` | Telco DRG OCID. |
| `hub_subnet_ids` | Hub subnet OCIDs keyed by role. |
| `oke_cluster_id` | OKE cluster OCID. |
| `oke_node_pool_id` | OKE node pool OCID. |
| `vault_ids` | Vault OCIDs keyed by logical name. |
| `monitoring_alarm_ids` | Monitoring alarm OCIDs keyed by logical name. |
| `os_management_resource_ids` | OS Management Hub resource identifiers. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/industry/telco-cloud-native
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/industry/telco-cloud-native
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Review the local README and architecture.
2. Populate `terraform.tfvars`.
3. Run plan.
4. Apply after review.
5. Hand outputs to the next owner.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Confirm telco workload network boundaries.
- Review OKE, OS Management, and monitoring enable flags.
- Check quotas, service limits, and region readiness.
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
