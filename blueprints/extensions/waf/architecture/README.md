# WAF Extension Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/waf`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates or attaches an OCI Web Application Firewall policy and binds WAF enforcement to an existing load balancer backend.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/extensions/waf` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates or attaches an OCI Web Application Firewall policy and binds WAF enforcement to an existing load balancer backend. |
| Terraform components | `oci_waf_web_app_firewall_policy.this`, `oci_waf_web_app_firewall.this` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `waf_policy_id`, `web_app_firewall_id` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| WAF Extension                                                                                     |
|                                                                                                  |
|  Internet clients                                                                                 |
|      | HTTPS                                                                                      |
|      v                                                                                           |
|  +------------------------- Existing OCI Load Balancer -------------------------+                 |
|  | load_balancer_id is supplied by the caller                                  |                 |
|  | backend_type controls how WAF attaches                                      |                 |
|  +-------------------------------+---------------------------------------------+                 |
|                                  | WAF association                                               |
|                                  v                                                                  |
|  +-------------------------- OCI Web Application Firewall ---------------------+                 |
|  | WAF Policy                                                                 |                 |
|  | - created here or existing waf_policy_id is used                             |                 |
|  | Web App Firewall                                                           |                 |
|  | - binds the policy to the load balancer                                     |                 |
|  +-------------------------------+---------------------------------------------+                 |
|                                  | allowed traffic after WAF policy evaluation                    |
|                                  v                                                                  |
|                            Application backend sets                                             |
|                                                                                                  |
|  Traffic: client -> load balancer -> WAF policy evaluation -> backend application.                |
|  Control: Terraform creates the policy first, then binds web_app_firewall to the load balancer.    |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_waf_web_app_firewall_policy.this` | `Declared directly in main.tf` |
| Resource | `oci_waf_web_app_firewall.this` | `Declared directly in main.tf` |

## Request And Deployment Flow

- Operator supplies the existing network, compartment, service, or backend IDs required by the extension.
- Terraform creates the optional service resource graph declared in main.tf.
- Outputs expose service IDs, endpoint names, or attachment IDs for applications and runbooks.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- The WAF policy can be created here or an existing waf_policy_id can be supplied.
- The Web App Firewall binds the policy to the supplied load_balancer_id and backend_type.
- Traffic evaluation happens on the load balancer path before requests reach backend sets, so policy readiness should be reviewed before association.
- The policy ID and Web App Firewall ID are the operational hand-offs for security and application teams.

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
|-- waf_policy_id
`-- web_app_firewall_id
```


## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_waf_web_app_firewall_policy.this`, `oci_waf_web_app_firewall.this`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `waf_policy_id`, `web_app_firewall_id`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
