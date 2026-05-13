# Externally Managed VCNs Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/externally-managed-vcns`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Documents and exports existing VCN, subnet, DRG, and route target OCIDs so brownfield networks can participate in the landing-zone output contract.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/externally-managed-vcns` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Documents and exports existing VCN, subnet, DRG, and route target OCIDs so brownfield networks can participate in the landing-zone output contract. |
| Terraform components | `locals.external_resource_ids` only |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_ids`, `subnet_ids`, `drg_id`, `route_target_ids` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Externally Managed VCNs                                                                           |
|                                                                                                  |
|  Existing OCI network estate                                                                      |
|       |                                                                                          |
|       | supplied as variables                                                                     |
|       v                                                                                          |
|  +----------------------------- Brownfield Inputs -----------------------------+                 |
|  | vcn_ids: logical name -> existing VCN OCID                                  |                 |
|  | subnet_ids: logical name -> existing subnet OCID                            |                 |
|  | drg_id: existing DRG OCID when present                                      |                 |
|  | route_target_ids: firewall, NVA, DRG, or private IP route target OCIDs       |                 |
|  +-------------------------------+---------------------------------------------+                 |
|                                  | normalize into local.external_resource_ids                    |
|                                  v                                                                  |
|  +----------------------------- Output Contract ------------------------------+                 |
|  | resource_ids, vcn_ids, subnet_ids, drg_id, route_target_ids                  |                 |
|  | lets other blueprints consume brownfield resources without creating them      |                 |
|  +----------------------------------------------------------------------------+                 |
|                                                                                                  |
|  Traffic: no packet path is created here; this folder documents and exports already-built paths.   |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Local output contract | `locals.external_resource_ids` | References existing brownfield resources supplied as variables |

## Request And Deployment Flow

- No OCI network resource is created by this folder.
- Existing VCN, subnet, DRG, and route target OCIDs are normalized into resource_ids.
- Downstream deployments can consume the brownfield output contract without knowing whether the resources were created here.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- This deployment intentionally creates no OCI network resources; it normalizes existing OCIDs into the standard output contract.
- vcn_ids, subnet_ids, drg_id, and route_target_ids should be verified against the intended region and compartment before use.
- Packet paths already exist outside this folder, so the architecture review should confirm the brownfield routes and security controls separately.
- Downstream deployments can use the exported maps the same way they use outputs from resource-creating network blueprints.

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
|-- vcn_ids
|-- subnet_ids
|-- drg_id
`-- route_target_ids
```


## Review Checklist

- Confirm the diagram matches `main.tf`: `locals.external_resource_ids`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_ids`, `subnet_ids`, `drg_id`, `route_target_ids`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
