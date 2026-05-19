# EKS + OKE Active Active Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for
`blueprints/extensions/eks-oke-active-active`. It is intentionally Architecture-first
so it is easy to review in GitHub, terminals, pull requests, runbooks, and
customer notes without a diagramming tool.

## Deployment Purpose

Implements an OCI-primary EKS + OKE active/active Kubernetes pattern over
partner Direct Connect + FastConnect interconnect, with GitOps orchestration and
weighted traffic steering contracts, while explicitly excluding IPSec backup.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/extensions/eks-oke-active-active` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | OCI-primary active/active EKS + OKE pattern with interconnect-only connectivity and contract outputs for GitOps and traffic steering. |
| Terraform components | `oci_core_vcn.oke`, `oci_core_route_table.oke`, `oci_core_security_list.oke_*`, `oci_core_subnet.oke_*`, `oci_containerengine_cluster.oci_primary`, `oci_containerengine_node_pool.oci_primary`, `terraform_data.interconnect_contract`, `terraform_data.gitops_contract`, `terraform_data.traffic_steering_contract` |
| Primary architecture view | The Architecture diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |

## Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| EKS + OKE Active Active                                                                                  |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {OCI primary cloud boundary}                                                                             |
|         |                                                                                                |
|         v                                                                                                |
| [OCI VCN + route table + security lists + OKE subnets] -> [OKE cluster + node pool] -> [OCI ingress endpoint] |
|         |                                                                                                |
|         +--> primary traffic target (weighted)                                                           |
|         |                                                                                                |
| [terraform_data contracts]                                                                                |
|    |-- interconnect: Direct Connect + FastConnect partner path only                                        |
|    |-- gitops: Argo CD or Flux repo/branch orchestration                                                 |
|    `-- traffic steering: FQDN and weighted primary/secondary endpoints                                   |
|                                                                                                          |
| {AWS secondary cloud boundary}                                                                          |
|         |                                                                                                |
|         v                                                                                                |
| (EKS cluster, supplied by ID) -> (AWS ingress endpoint)                                                |
|                                                                                                          |
| [Clients] -> [DNS/GTM steering layer] -> OCI endpoint (primary weight)                                   |
|                                     `-> AWS endpoint (secondary weight)                               |
|                                                                                                          |
| Explicit guardrails: OCI primary required, interconnect mode fixed, IPSec backup disabled.              |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.oke`, `oci_core_route_table.oke`, `oci_core_security_list.oke_*`, `oci_core_subnet.oke_*` | Deploy-and-use OCI networking stack for OKE control plane, nodes, and service load balancers. |
| Resource | `oci_containerengine_cluster.oci_primary` | Optional OCI primary OKE cluster when enabled. |
| Resource | `oci_containerengine_node_pool.oci_primary` | Optional OCI primary OKE node pool when enabled. |
| Resource | `terraform_data.oke_network_contract` | Validation contract for either managed or supplied OKE networking identifiers. |
| Resource | `terraform_data.interconnect_contract` | Interconnect-only contract for Direct Connect + FastConnect and no IPSec fallback. |
| Resource | `terraform_data.gitops_contract` | GitOps operating contract for multi-cluster rollout. |
| Resource | `terraform_data.traffic_steering_contract` | Weighted traffic steering contract for OCI primary and EKS secondary endpoints. |

## Request And Deployment Flow

- Operator supplies existing EKS IDs, interconnect IDs, and endpoint targets in local tfvars.
- Terraform can create OCI OKE networking (VCN, route table, security lists, subnets) or validate supplied networking IDs.
- Terraform optionally creates OKE primary resources and always publishes interconnect, GitOps, and traffic steering contracts.
- Outputs expose primary/secondary cluster metadata, contract IDs, and steering weights for operations runbooks.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the Architecture diagram: client traffic is steered to OCI primary and optionally to AWS secondary based on configured weights.
- Trust boundaries are the OCI tenancy boundary, the AWS boundary represented by externally supplied EKS and endpoint IDs, and the interconnect boundary represented by FastConnect + Direct Connect partner links.
- Secrets, OCIDs, Direct Connect IDs, endpoints, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter
at review, plan, and hand-off time.

- The blueprint creates OCI routing and security primitives for deploy-and-use cluster networking and still allows external OCI network IDs when needed.
- AWS-side deployment is provisioned by the same blueprint folder through `aws/main.yaml` and `ansible/aws-*.yml` sessions.
- OKE resource creation is optional so customers can run extension-only mode with existing cluster IDs or base-plus-extension mode with new OKE resources.
- `interconnect_mode` and `enable_ipsec_backup` validations keep the deployment constrained to partner interconnect without VPN fallback.
- The traffic steering contract is weighted by `oci_primary_traffic_percent`, with the remaining weight assigned to AWS.
- GitOps contract outputs align deployment orchestration across clusters even when cloud-specific provisioning is split between teams.

## Operational Boundaries

- This extension can run extension-only with supplied brownfield OCI, interconnect, and EKS IDs, or base-plus-extension using outputs from core and networking blueprints.
- Keep customer-specific OCIDs, CIDRs, circuit IDs, endpoint URLs, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so provider files and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check traffic steering weights, GitOps branch controls, and interconnect ownership whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_core_vcn.oke`, `oci_core_route_table.oke`, `oci_core_security_list.oke_*`, `oci_core_subnet.oke_*`, `oci_containerengine_cluster.oci_primary`, `oci_containerengine_node_pool.oci_primary`, `terraform_data.interconnect_contract`, `terraform_data.gitops_contract`, `terraform_data.traffic_steering_contract`.
- Confirm OCI remains primary and IPSec backup remains disabled.
- Confirm interconnect IDs match the intended Direct Connect + FastConnect partner path.
- Confirm the described traffic path is the path you want before apply.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
