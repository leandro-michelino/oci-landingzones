# EKS + OKE Active Passive Architecture

This page is the deployment architecture for
`blueprints/extensions/eks-oke-active-passive`. It is intentionally Architecture-first
so it is easy to review in GitHub, terminals, pull requests, runbooks, and
customer-safe notes without a diagramming tool.

The default operating mode described here is OCI-primary active/passive.

## Deployment Purpose

Implements an OCI-primary EKS + OKE active/passive Kubernetes pattern over
partner Direct Connect + FastConnect interconnect, with GitOps orchestration and
DNS failover contracts, while explicitly excluding IPSec backup.

## Kubernetes Version Guidance

Keep OKE and EKS on the latest common Kubernetes minor version available in the
selected regions. The desired baseline remains `1.36` where both providers
support it, but region support is authoritative. In the May 26, 2026 E2E test,
EKS in `eu-west-1` required using `1.35`, so OKE was pinned to `v1.35.2` for
minor-version alignment.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/extensions/eks-oke-active-passive` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | OCI-primary active/passive EKS + OKE pattern with interconnect-only connectivity, GitOps contracts, and optional OCI Traffic Management failover. |
| Terraform components | `oci_core_vcn.oke`, `oci_core_route_table.oke`, `oci_core_security_list.oke_*`, `oci_core_subnet.oke_*`, `oci_containerengine_cluster.oci_primary`, `oci_containerengine_node_pool.oci_primary`, optional `oci_health_checks_http_monitor.traffic_failover`, optional `oci_dns_steering_policy.traffic_failover`, optional `oci_dns_steering_policy_attachment.traffic_failover`, `terraform_data.interconnect_contract`, `terraform_data.gitops_contract`, `terraform_data.traffic_steering_contract` |
| Primary architecture view | The Architecture diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |

## Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| EKS + OKE Active Passive                                                                                  |
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
|         +--> primary active traffic target                                                           |
|         |                                                                                                |
| [terraform_data contracts]                                                                                |
|    |-- interconnect: Direct Connect + FastConnect partner path only                                        |
|    |-- gitops: Argo CD or Flux repo/branch orchestration                                                 |
|    `-- OCI Traffic Management: FQDN, health checks, and failover primary/standby endpoints                                   |
|                                                                                                          |
| {AWS secondary cloud boundary}                                                                          |
|         |                                                                                                |
|         v                                                                                                |
| (EKS cluster, supplied by ID) -> (AWS ingress endpoint)                                                |
|                                                                                                          |
| [Clients] -> [OCI Traffic Management failover] -> OCI endpoint (primary active)                          |
|                                              `-> AWS endpoint (standby on failover)                      |
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
| Resource | `terraform_data.traffic_steering_contract` | DNS failover contract for OCI primary and EKS standby endpoints. |
| Optional resource | `oci_health_checks_http_monitor.traffic_failover` | HTTP(S) health monitor used by OCI Traffic Management failover. |
| Optional resource | `oci_dns_steering_policy.traffic_failover` | OCI DNS failover policy with OCI primary and AWS standby answers. |
| Optional resource | `oci_dns_steering_policy_attachment.traffic_failover` | Attachment between the steering policy, DNS zone, and application FQDN. |

## Request And Deployment Flow

- Operator supplies existing EKS IDs, interconnect IDs, and endpoint targets in local tfvars.
- Terraform can create OCI OKE networking (VCN, route table, security lists, subnets) or validate supplied networking IDs.
- Terraform optionally creates OKE primary resources and always publishes interconnect, GitOps, and DNS failover contracts.
- Outputs expose primary/standby cluster metadata, contract IDs, and OCI Traffic Management resource IDs for operations runbooks.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the Architecture diagram: client traffic targets OCI primary and shifts to AWS standby only when failover policy health rules require it.
- Trust boundaries are the OCI tenancy boundary, the AWS boundary represented by externally supplied EKS and endpoint IDs, and the interconnect boundary represented by FastConnect + Direct Connect partner links.
- Secrets, OCIDs, Direct Connect IDs, endpoints, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter
at review, plan, and hand-off time.

- The blueprint creates OCI routing and security primitives for deploy-and-use cluster networking and still allows external OCI network IDs when needed.
- OKE networking includes DNS labels, Internet Gateway routing for public smoke tests, worker-to-endpoint rules on `6443` and `12250`, and HTTP/HTTPS ingress for public service load balancers. For private production nodes, use separate route tables with NAT and Service Gateway patterns.
- AWS-side deployment is provisioned by the same blueprint folder through `aws/main.yaml` and `ansible/aws-*.yml` sessions.
- OKE resource creation is optional so customers can run extension-only mode with existing cluster IDs or base-plus-extension mode with new OKE resources.
- `interconnect_mode` and `enable_ipsec_backup` validations keep the deployment constrained to partner interconnect without VPN fallback.
- The DNS failover contract keeps OCI as the active target by default and uses AWS only as standby; active/active remains possible with an intentional weighted DNS/GSLB design.
- When `enable_oci_traffic_management=true`, the blueprint can create the health monitor, failover steering policy, and policy attachment for a supplied OCI DNS zone and application FQDN.
- OCI Traffic Management steering policies and attachments are created through the tenancy home-region provider alias; set `home_region` before enabling the feature.
- Direct IPs and cloud load balancer hostnames validate the apps, but they do not validate DNS failover. Browser-based Traffic Management tests require a public domain or subdomain delegated to the OCI DNS zone nameservers.
- With the default 30-second TTL, 30-second health check interval, and 10-second health check timeout, use 60 to 120 seconds as the practical target for both OCI-to-AWS failover and AWS-to-OCI failback. Measure from the delegated Traffic Management FQDN, not from direct endpoint IPs.
- The failover priority rule must reference `answer.pool` values (`primary` and `standby`), which matches the OCI Traffic Management FAILOVER template requirements.
- The default active/passive model avoids implying that Kubernetes load balancers perform cross-cloud balancing. Cross-cloud routing lives in OCI Traffic Management or another explicit GSLB layer.
- Kubernetes versions should be advanced to the newest common provider-supported minor version during each deployment review. Use the latest version supported by both OKE and EKS in the selected regions; keep the Terraform and CloudFormation examples at `1.36` where supported, and override only when the target EKS region has not exposed that version yet.
- GitOps contract outputs align deployment orchestration across clusters even when cloud-specific provisioning is split between teams.

## Operational Boundaries

- This extension can run extension-only with supplied brownfield OCI, interconnect, and EKS IDs, or base-plus-extension using outputs from core and networking blueprints.
- Keep customer-specific OCIDs, CIDRs, circuit IDs, endpoint URLs, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so provider files and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check DNS failover targets, health checks, GitOps branch controls, and interconnect ownership whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_core_vcn.oke`, `oci_core_route_table.oke`, `oci_core_security_list.oke_*`, `oci_core_subnet.oke_*`, `oci_containerengine_cluster.oci_primary`, `oci_containerengine_node_pool.oci_primary`, optional OCI Traffic Management resources, `terraform_data.interconnect_contract`, `terraform_data.gitops_contract`, `terraform_data.traffic_steering_contract`.
- Confirm OCI remains primary and IPSec backup remains disabled.
- Confirm interconnect IDs match the intended Direct Connect + FastConnect partner path.
- Confirm the described traffic path is the path you want before apply.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
