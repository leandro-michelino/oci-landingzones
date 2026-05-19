# EKS + OKE Active Active

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/extensions/eks-oke-active-active`.
It tells you what the blueprint builds, which inputs deserve a real review, how
to run Terraform or the local Ansible wrappers, and where to find the detailed
Architecture design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/extensions/eks-oke-active-active` |
| Best fit | Active/active EKS + OKE operating model with OCI as primary, partner interconnect, GitOps contract, and weighted traffic steering contract. |
| Terraform shape | `oci_core_vcn.oke`, `oci_core_route_table.oke`, `oci_core_security_list.oke_*`, `oci_core_subnet.oke_*`, `oci_containerengine_cluster.oci_primary`, `oci_containerengine_node_pool.oci_primary`, `terraform_data.interconnect_contract`, `terraform_data.gitops_contract`, `terraform_data.traffic_steering_contract` |
| Inputs to settle first | `compartment_ocid`, `enable_oke_networking`, `oke_vcn_cidr`, `oke_node_subnet_cidrs`, `oke_kubernetes_version`, `fastconnect_virtual_circuit_id`, `direct_connect_connection_id`, `eks_cluster_id`, `app_fqdn`, `oci_primary_endpoint`, `aws_secondary_endpoint` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `primary_cluster`, `secondary_cluster`, `interconnect_contract`, `traffic_steering_contract`, `gitops_contract` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Implements an OCI-primary EKS + OKE active/active Kubernetes pattern that uses
partner Direct Connect + FastConnect interconnect, excludes IPSec backup paths,
and publishes GitOps and traffic-steering contracts for platform operations.

## When To Use This Deployment

- OCI should remain the primary traffic target for Kubernetes workloads.
- EKS is part of the same workload platform and already exists or is managed by another pipeline.
- Cross-cloud connectivity uses Direct Connect + FastConnect partner interconnect.
- You need explicit weighted traffic steering and GitOps hand-off contracts.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the
OCI resource graph and cross-cloud operating contracts, while the local Ansible
files provide the same plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.oke`, `oci_core_route_table.oke`, `oci_core_security_list.oke_*`, `oci_core_subnet.oke_*` | Optional OCI networking stack for deploy-and-use OKE routing and security defaults. |
| Resource | `oci_containerengine_cluster.oci_primary` | Optional OCI primary OKE cluster when `enable_oke_cluster=true`. |
| Resource | `oci_containerengine_node_pool.oci_primary` | Optional OCI primary OKE node pool when `enable_oke_node_pool=true`. |
| Resource | `terraform_data.interconnect_contract` | Interconnect-only contract for FastConnect + Direct Connect and no IPSec backup. |
| Resource | `terraform_data.gitops_contract` | GitOps orchestration metadata for Argo CD or Flux. |
| Resource | `terraform_data.traffic_steering_contract` | Weighted traffic steering metadata with OCI primary weighting. |

The exact OCI behavior is controlled by `variables.tf` and the values supplied
in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/extensions/eks-oke-active-active/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
|-- hello-world/index.html     Sample app page for active/active smoke tests
|-- aws/
|   |-- main.yaml             EKS secondary AWS deployment template
|   |-- parameters.example.json Example AWS deployment parameters
|   `-- README.md              AWS session guide
|-- main.tf                    Terraform modules, resources, and data sources
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    |-- destroy.yml            Guarded destroy
    |-- aws-plan.yml         AWS plan session for EKS secondary
    |-- aws-apply.yml        AWS apply session for EKS secondary
    |-- aws-destroy.yml      AWS destroy session for EKS secondary
    |-- serve-hello-world.yml  Start local hello-world endpoint for demos and checks
    `-- stop-hello-world.yml   Stop local hello-world endpoint
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real IDs, endpoints, names, and enable flags.

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
| `enable_oke_networking` | When true, creates VCN, route table, security lists, and required OKE subnets. |
| `oke_vcn_cidr` | CIDR for OCI VCN created in deploy-and-use mode. |
| `oke_endpoint_subnet_cidr` | CIDR for OKE API endpoint subnet. |
| `oke_node_subnet_cidrs` | CIDR list for OKE worker node subnets. |
| `oke_service_lb_subnet_cidr` | CIDR for OKE load balancer subnet. |
| `oke_api_allowed_cidr` | Allowed source CIDR to reach the OKE API endpoint. |
| `oke_node_ssh_allowed_cidr` | Optional SSH source CIDR for worker node access. |
| `interconnect_mode` | Must remain `direct-connect-fastconnect-partner` for this pattern. |
| `fastconnect_virtual_circuit_id` | OCI FastConnect virtual circuit OCID for the partner interconnect. |
| `direct_connect_connection_id` | AWS Direct Connect connection ID paired to FastConnect through partner exchange. |
| `enable_ipsec_backup` | Must remain `false` in this blueprint variant. |
| `oci_is_primary` | Must remain `true` in this blueprint variant. |
| `enable_oke_cluster` | Create the OCI primary OKE cluster. Disabled by default to avoid cost in smoke tests. |
| `enable_oke_node_pool` | Create the OCI primary OKE node pool. Disabled by default to avoid compute cost. |
| `oke_cluster_id` | Existing OKE cluster OCID used when only creating node pools. |
| `oke_kubernetes_version` | Kubernetes version for OKE resources. |
| `oke_vcn_id` | VCN OCID for OKE cluster networking. |
| `oke_endpoint_subnet_id` | Optional endpoint subnet OCID for OKE API server. |
| `oke_node_subnet_ids` | Node subnet OCIDs for OKE worker nodes. |
| `eks_cluster_id` | Existing EKS cluster resource ID used as secondary target. |
| `eks_cluster_name` | Existing EKS cluster name for hand-off outputs. |
| `eks_stack_name` | Existing EKS stack for hand-off outputs. |
| `gitops_tool` | GitOps controller choice: `argocd` or `flux`. |
| `gitops_repo_url` | GitOps repository URL for multi-cluster rollout. |
| `app_fqdn` | Application FQDN used for traffic steering decisions. |
| `oci_primary_endpoint` | OCI primary ingress endpoint. |
| `aws_secondary_endpoint` | AWS secondary ingress endpoint. |
| `oci_primary_traffic_percent` | Weighted percentage for OCI primary traffic. Remaining weight goes to EKS secondary. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks,
customer notes, or manual hand-off. If an output name changes, update
dependent docs and consumers in the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `primary_cluster` | OCI primary cluster IDs and cloud role metadata. |
| `secondary_cluster` | EKS secondary cluster IDs and cloud role metadata. |
| `interconnect_contract` | Interconnect path contract: Direct Connect + FastConnect and no IPSec backup. |
| `traffic_steering_contract` | Weighted active/active steering contract for OCI primary and EKS secondary endpoints. |
| `gitops_contract` | GitOps metadata contract for rollout tooling and repository wiring. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/extensions/eks-oke-active-active
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across
the repo:

```bash
cd blueprints/extensions/eks-oke-active-active
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

AWS full deployment session (EKS secondary):

```bash
cd blueprints/extensions/eks-oke-active-active
ansible-playbook -i localhost, ansible/aws-plan.yml
CONFIRM_AWS_APPLY=true ansible-playbook -i localhost, ansible/aws-apply.yml
CONFIRM_AWS_DESTROY=true ansible-playbook -i localhost, ansible/aws-destroy.yml
```

For required AWS variables and parameters, review `aws/README.md`.
AWS session playbooks use the shared role
`ansible/roles/aws_deployment_runner` for consistent behavior.

To run the real hello-world endpoint for this blueprint:

```bash
cd blueprints/extensions/eks-oke-active-active
ansible-playbook -i localhost, ansible/serve-hello-world.yml
# open http://127.0.0.1:18080
ansible-playbook -i localhost, ansible/stop-hello-world.yml
```

## Deployment Order

This extension supports extension-only and base-plus-extension customer paths.
For extension-only use, supply existing compartment, OKE, interconnect, EKS,
and endpoint values in local tfvars and run this folder directly. For
base-plus-extension use, deploy core and networking first, then pass outputs
here.

1. Confirm compartment scope, OKE ownership, and EKS ownership boundaries.
2. Confirm interconnect ownership and partner circuit lifecycle.
3. Populate `terraform.tfvars` with cluster IDs, interconnect IDs, and endpoint values.
4. Run plan and review OCI-primary weighting and contract outputs.
5. Apply only after platform, network, and operations owners approve the hand-off contract.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow,
state and output contract, operational boundaries, review checklist, and the
expected Terraform + Ansible output at the end of the deployment.

## Review Before Apply

- Confirm OCI remains primary (`oci_is_primary=true`) and IPSec backup is disabled.
- Confirm interconnect IDs map to the intended Direct Connect + FastConnect pair.
- Review OKE endpoint exposure and node subnet reachability.
- Confirm GitOps repository ownership and branch promotion workflow.
- Confirm traffic-steering endpoint names and weights are intentional.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files,
required architecture README sections, `terraform init -backend=false`,
`terraform validate`, root Ansible syntax, blueprint-local Ansible syntax,
optional scanners when installed, and cleanup of generated Terraform artifacts.
