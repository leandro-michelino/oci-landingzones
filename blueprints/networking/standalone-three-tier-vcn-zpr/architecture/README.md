# Standalone Three-Tier VCN ZPR Architecture

This is the deployment architecture for `blueprints/networking/standalone-three-tier-vcn-zpr`. It keeps the design reviewable in GitHub, terminals, pull requests, runbooks, and customer-safe notes without a diagramming tool.

## Deployment Purpose

Creates a standalone three-tier VCN with optional, separately authorized tenancy-root ZPR administration.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/standalone-three-tier-vcn-zpr` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates a standalone three-tier VCN with optional, separately authorized tenancy-root ZPR administration. |
| Terraform components | `workload_vcn`, `zpr` |
| Primary architecture view | The Architecture diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Standalone Three-Tier VCN ZPR                                                                            |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Workload compartment / selected region}                                                                 |
|         |                                                                                                |
|         v                                                                                                |
| [Workload VCN]                                                                                           |
|         |-- [public web subnet]  -> route table -> Internet Gateway when enabled                         |
|         |-- [private app subnet] -> route table -> NAT Gateway / Service Gateway                         |
|         `-- [private db subnet]  -> route table -> NAT Gateway / Service Gateway                                |
|              |                                                                                           |
|              +--> [security lists] gate traffic; (workload NSGs supplied separately)                                      |
|              +--> [gateway set] IGW / NAT / SGW according to blueprint variables                         |
|                                                                                                          |
| Optional ZPR: tenancy-root policies; (security attributes assigned separately to workload resources).  |
| North-south: client -> web tier -> app tier -> database tier.                                            |
| Service path: private subnets -> service gateway for OCI services; outbound updates use NAT when         |
| enabled.                                                                                                 |
| Hand-off: VCN, subnet, route table, security, and gateway IDs for workloads or later extensions.         |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `workload_vcn` | `modules/networking/spoke-vcn @ v0.2.0` |
| Module | `zpr` | `modules/networking/zpr @ v0.2.0` |

## Request And Deployment Flow

- Operator reviews CIDRs, subnet maps, gateway flags, route targets, and inspection requirements.
- Terraform creates the network foundation first, then dependent attachments or network services declared in main.tf.
- Traffic follows the diagrammed route path, and outputs expose VCN, subnet, DRG, gateway, DNS, inspection, or policy IDs for the next deployment.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the Architecture diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- The default deployment creates the VCN only; ZPR configuration and policies require explicit enable flags and tenancy-root administrative authorization.
- The network still provides the web/app/db packet path through normal VCN routing and gateways.
- ZPR policies add packet authorization for specific resources, subjects, compartments, and services.
- Review policy blast radius and expected web-to-app/app-to-db flows before applying to production workloads.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `workload_vcn`, `zpr`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.

## October 2026 Review Boundaries

Provider configuration ignores only OCI-managed `Oracle-Tags.CreatedBy` and `Oracle-Tags.CreatedOn`; customer-defined tags remain managed. Live validation covers network provisioning and cleanup, without workload packet-flow tests.

ZPR is disabled by default. Onboarding and ZPR policies are tenancy-root administrative resources, outside a compartment-only test. Onboarding requires the tenancy home region. This blueprint does not assign security attributes to workload resources, so provisioning policies alone does not prove enforcement. The corrected local ZPR module requires publication and a refreshed module pin before remote consumers receive its root-scope fix. Public HTTP/HTTPS ingress belongs only to the web subnet; app and database use an ingress-empty baseline.
