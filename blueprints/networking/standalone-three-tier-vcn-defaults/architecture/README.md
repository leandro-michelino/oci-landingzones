# Standalone Three-Tier VCN Defaults Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/standalone-three-tier-vcn-defaults`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates a straightforward standalone three-tier workload VCN using opinionated defaults for web, app, and database tiers.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/standalone-three-tier-vcn-defaults` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates a straightforward standalone three-tier workload VCN using opinionated defaults for web, app, and database tiers. |
| Terraform components | `workload_vcn` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_id`, `subnet_ids`, `route_table_ids`, `gateway_ids` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Standalone Three-Tier VCN Defaults                                                                |
|                                                                                                  |
|  Internet clients                                                                                 |
|       |                                                                                            |
|       v                                                                                            |
|  +----------------------------- Workload VCN -----------------------------+                     |
|  | Default CIDR from var.vcn_cidr_block                                   |                     |
|  | Internet Gateway enabled                                               |                     |
|  | NAT Gateway enabled                                                    |                     |
|  | Service Gateway enabled                                                |                     |
|  |                                                                       |                     |
|  |  Web subnet  <----- public ingress through IGW                          |                     |
|  |      |                                                                |                     |
|  |      v                                                                |                     |
|  |  App subnet  -----> outbound updates through NAT Gateway               |                     |
|  |      |                                                                |                     |
|  |      v                                                                |                     |
|  |  DB subnet   -----> private OCI service access through Service Gateway |                     |
|  +------------------------------+----------------------------------------+                     |
|                                 |                                                               |
|                                 v                                                               |
|        Outputs: vcn_id, subnet_ids, route_table_ids, gateway_ids                                  |
|                                                                                                  |
|  Traffic: web -> app -> db for application tiers; private egress uses NAT/SGW instead of public IPs.|
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `workload_vcn` | `modules/networking/spoke-vcn @ v0.2.0` |

## Request And Deployment Flow

- Operator reviews CIDRs, subnet maps, gateway flags, route targets, and inspection requirements.
- Terraform creates the network foundation first, then dependent attachments or network services declared in main.tf.
- Traffic follows the diagrammed route path, and outputs expose VCN, subnet, DRG, gateway, DNS, inspection, or policy IDs for the next deployment.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- This VCN creates a simple web/app/database tier pattern with Internet Gateway, NAT Gateway, and Service Gateway enabled.
- Public ingress should terminate in the web tier; app and database tiers should remain private unless inputs deliberately change that posture.
- Private outbound internet traffic should use NAT, while OCI service traffic should use the Service Gateway path.
- Review the default CIDRs and route behavior before reusing the pattern in a shared or production environment.

- The output contract at the end of this page is the hand-off surface for downstream blueprints, runbooks, and customer notes.

## State, Inputs, And Outputs

```text
Input sources
|-- terraform.tfvars.example documents expected values for this deployment
|-- local ignored tfvars provide tenancy, compartment, CIDR, endpoint, and service-specific values
|-- environment variables may provide OCI authentication and guarded Ansible confirms
|
Terraform state
|-- backend is disabled for local validation and blueprint-local runners by default
|-- production state backends should be configured outside this reusable blueprint folder
|-- generated .terraform directories, lock files, plans, state files, and local tfvars stay out of git
|
Output contract
|-- blueprint_name
|-- name_prefix
|-- resource_ids
|-- vcn_id
|-- subnet_ids
|-- route_table_ids
`-- gateway_ids
```


## Review Checklist

- Confirm the diagram matches `main.tf`: `workload_vcn`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_id`, `subnet_ids`, `route_table_ids`, `gateway_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
