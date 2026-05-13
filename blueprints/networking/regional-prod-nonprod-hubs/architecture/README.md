# Regional Prod Nonprod Hubs Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/regional-prod-nonprod-hubs`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates separate prod and nonprod hub-spoke networks in the same region with distinct CIDR spaces and environment tags.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/regional-prod-nonprod-hubs` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates separate prod and nonprod hub-spoke networks in the same region with distinct CIDR spaces and environment tags. |
| Terraform components | `prod_network`, `nonprod_network` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `prod_hub_vcn_id`, `nonprod_hub_vcn_id`, `prod_drg_id`, `nonprod_drg_id` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Regional Prod Nonprod Hubs                                                                        |
|                                                                                                  |
|  Single OCI region                                                                                |
|       |                                                                                          |
|       v                                                                                          |
|  +----------------------------- Production Network ----------------------------+                 |
|  | Environment tag: prod                                                     |                 |
|  | Hub CIDR 10.40.0.0/16                                                     |                 |
|  | Hub subnets: dmz 10.40.0.0/24, firewall 10.40.1.0/24, shared 10.40.2.0/24 |                 |
|  | Spoke prodapp CIDR 10.41.0.0/16 with web/app/db subnets                    |                 |
|  | Dedicated prod DRG and attachments                                         |                 |
|  +----------------------------------------------------------------------------+                 |
|                                                                                                  |
|  +---------------------------- Nonproduction Network -------------------------+                 |
|  | Environment tag: nonprod                                                  |                 |
|  | Hub CIDR 10.50.0.0/16                                                     |                 |
|  | Hub subnets: dmz 10.50.0.0/24, firewall 10.50.1.0/24, shared 10.50.2.0/24 |                 |
|  | Spoke nonprodapp CIDR 10.51.0.0/16 with web/app/db subnets                 |                 |
|  | Dedicated nonprod DRG and attachments                                      |                 |
|  +----------------------------------------------------------------------------+                 |
|                                                                                                  |
|  Traffic: prod and nonprod do not share a DRG in this deployment; each hub controls its own flows. |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `prod_network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `nonprod_network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |

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

- Production and nonproduction networks are separate hub-spoke module instances in the same region.
- Each side has distinct hub CIDRs, spoke CIDRs, subnets, DRGs, and environment tags.
- There is no shared DRG between prod and nonprod in this deployment, so connectivity remains separated unless another layer connects them.
- Review CIDR separation, tags, route tables, and any future peering requirement before adding workloads.

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
|-- prod_hub_vcn_id
|-- nonprod_hub_vcn_id
|-- prod_drg_id
`-- nonprod_drg_id
```


## Review Checklist

- Confirm the diagram matches `main.tf`: `prod_network`, `nonprod_network`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `prod_hub_vcn_id`, `nonprod_hub_vcn_id`, `prod_drg_id`, `nonprod_drg_id`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
