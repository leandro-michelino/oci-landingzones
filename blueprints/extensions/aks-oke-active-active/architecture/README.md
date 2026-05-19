# AKS + OKE Active Active Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for
`blueprints/extensions/aks-oke-active-active`. It is intentionally ASCII-first
so it is easy to review in GitHub, terminals, pull requests, runbooks, and
customer notes without a diagramming tool.

## Deployment Purpose

Implements an OCI-primary AKS + OKE active/active Kubernetes pattern over
partner ExpressRoute + FastConnect interconnect, with GitOps orchestration and
weighted traffic steering contracts, while explicitly excluding IPSec backup.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/extensions/aks-oke-active-active` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | OCI-primary active/active AKS + OKE pattern with interconnect-only connectivity and contract outputs for GitOps and traffic steering. |
| Terraform components | `oci_containerengine_cluster.oci_primary`, `oci_containerengine_node_pool.oci_primary`, `terraform_data.interconnect_contract`, `terraform_data.gitops_contract`, `terraform_data.traffic_steering_contract` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |

## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| AKS + OKE Active Active                                                                                  |
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
| [OKE cluster + node pool] -> [OCI ingress endpoint]                                                      |
|         |                                                                                                |
|         +--> primary traffic target (weighted)                                                           |
|         |                                                                                                |
| [terraform_data contracts]                                                                                |
|    |-- interconnect: ExpressRoute + FastConnect partner path only                                        |
|    |-- gitops: Argo CD or Flux repo/branch orchestration                                                 |
|    `-- traffic steering: FQDN and weighted primary/secondary endpoints                                   |
|                                                                                                          |
| {Azure secondary cloud boundary (external in this variant)}                                              |
|         |                                                                                                |
|         v                                                                                                |
| (AKS cluster, supplied by ID) -> (Azure ingress endpoint)                                                |
|                                                                                                          |
| [Clients] -> [DNS/GTM steering layer] -> OCI endpoint (primary weight)                                   |
|                                     `-> Azure endpoint (secondary weight)                               |
|                                                                                                          |
| Explicit guardrails: OCI primary required, interconnect mode fixed, IPSec backup disabled.              |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_containerengine_cluster.oci_primary` | Optional OCI primary OKE cluster when enabled. |
| Resource | `oci_containerengine_node_pool.oci_primary` | Optional OCI primary OKE node pool when enabled. |
| Resource | `terraform_data.interconnect_contract` | Interconnect-only contract for ExpressRoute + FastConnect and no IPSec fallback. |
| Resource | `terraform_data.gitops_contract` | GitOps operating contract for multi-cluster rollout. |
| Resource | `terraform_data.traffic_steering_contract` | Weighted traffic steering contract for OCI primary and AKS secondary endpoints. |

## Request And Deployment Flow

- Operator supplies existing AKS IDs, interconnect IDs, and endpoint targets in local tfvars.
- Terraform optionally creates OKE primary resources and always publishes interconnect, GitOps, and traffic steering contracts.
- Outputs expose primary/secondary cluster metadata, contract IDs, and steering weights for operations runbooks.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram: client traffic is steered to OCI primary and optionally to Azure secondary based on configured weights.
- Trust boundaries are the OCI tenancy boundary, the Azure boundary represented by externally supplied AKS and endpoint IDs, and the interconnect boundary represented by FastConnect + ExpressRoute partner links.
- Secrets, OCIDs, ExpressRoute IDs, endpoints, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter
at review, plan, and hand-off time.

- The blueprint intentionally models Azure resources as externally managed in this variant, while still publishing a strict active/active operations contract.
- OKE resource creation is optional so customers can run extension-only mode with existing cluster IDs or base-plus-extension mode with new OKE resources.
- `interconnect_mode` and `enable_ipsec_backup` validations keep the deployment constrained to partner interconnect without VPN fallback.
- The traffic steering contract is weighted by `oci_primary_traffic_percent`, with the remaining weight assigned to Azure.
- GitOps contract outputs align deployment orchestration across clusters even when cloud-specific provisioning is split between teams.

## Operational Boundaries

- This extension can run extension-only with supplied brownfield OCI, interconnect, and AKS IDs, or base-plus-extension using outputs from core and networking blueprints.
- Keep customer-specific OCIDs, CIDRs, circuit IDs, endpoint URLs, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so provider files and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check traffic steering weights, GitOps branch controls, and interconnect ownership whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_containerengine_cluster.oci_primary`, `oci_containerengine_node_pool.oci_primary`, `terraform_data.interconnect_contract`, `terraform_data.gitops_contract`, `terraform_data.traffic_steering_contract`.
- Confirm OCI remains primary and IPSec backup remains disabled.
- Confirm interconnect IDs match the intended ExpressRoute + FastConnect partner path.
- Confirm the described traffic path is the path you want before apply.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
