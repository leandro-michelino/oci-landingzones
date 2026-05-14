# OKE Extension

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/extensions/oke`. It tells you what the
blueprint builds, which inputs deserve a real review, how to run Terraform or the local
Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/extensions/oke` |
| Best fit | Adds OCI Container Engine for Kubernetes as a platform extension with cluster, node pool, subnet, endpoint, IAM, and logging decisions visible. |
| Terraform shape | `oci_containerengine_cluster.this`, `oci_containerengine_node_pool.this` |
| Inputs to settle first | `compartment_ocid`, `cluster_id`, `cluster_label`, `kubernetes_version`, `vcn_id`, `endpoint_subnet_id`, `endpoint_nsg_ids`, plus 10 more |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `cluster_id`, `node_pool_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Adds OCI Container Engine for Kubernetes as a platform extension with cluster, node pool,
subnet, endpoint, IAM, and logging decisions visible.

## When To Use This Deployment

- Kubernetes is the workload platform.
- Private nodes, endpoint exposure, and ingress need review.
- Platform and application teams need a repeatable OKE baseline.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_containerengine_cluster.this` | Declared directly in `main.tf` |
| Resource | `oci_containerengine_node_pool.this` | Declared directly in `main.tf` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/extensions/oke/
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
| `compartment_ocid` | Compartment OCID where OKE resources are created. Defaults to tenancy_ocid for validation-only tests. |
| `cluster_id` | Existing OKE cluster OCID used when creating only a node pool. |
| `cluster_label` | Short OKE cluster label used in names. |
| `kubernetes_version` | Kubernetes version for the OKE cluster and node pool. |
| `vcn_id` | VCN OCID where the OKE cluster is created. |
| `endpoint_subnet_id` | Optional subnet OCID for the OKE Kubernetes API endpoint. |
| `endpoint_nsg_ids` | Optional NSG OCIDs for the OKE API endpoint. |
| `service_lb_subnet_ids` | Optional subnet OCIDs used by OKE service load balancers. |
| `cni_type` | OKE pod networking CNI type. |
| `node_pool_label` | Short node pool label used in names. |
| `node_shape` | OKE worker node shape. |
| `node_shape_ocpus` | Optional OCPU count for flexible node shapes. |
| `node_shape_memory_in_gbs` | Optional memory in GB for flexible node shapes. |
| `node_subnet_ids` | Subnet OCIDs used by the OKE node pool. |
| `node_quantity_per_subnet` | Number of nodes per node subnet. |
| `node_image_id` | Optional custom worker node image OCID. |
| `ssh_public_key` | Optional SSH public key for worker nodes. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_cluster` | Create the OKE cluster. Disabled by default to avoid cost in smoke tests. |
| `endpoint_public_ip_enabled` | Whether the OKE API endpoint receives a public IP. |
| `enable_node_pool` | Create an OKE node pool. Disabled by default to avoid compute cost. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `cluster_id` | Created or referenced OKE cluster OCID. |
| `node_pool_id` | OKE node pool OCID. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/extensions/oke
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/extensions/oke
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

This extension supports extension-only and base-plus-extension customer paths.
For extension-only use, supply existing compartment, VCN, subnet, NSG, and node
pool values in local tfvars and run this folder directly. For
base-plus-extension use, deploy core and networking first, then pass their
outputs here.

1. Confirm the target compartment, network/service dependencies, and ownership model.
2. Confirm service-specific quotas, cost, and dependencies.
3. Populate `terraform.tfvars` with subnet, compartment, and service values.
4. Run plan and review optional resource enable flags.
5. Apply only after the platform or service owner approves the output shape.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Confirm Kubernetes version and node shape.
- Review private endpoint, API endpoint, and load-balancer subnets.
- Check quotas and cost before enabling cluster and nodes.
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
