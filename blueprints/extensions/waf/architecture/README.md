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


## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| WAF Extension                                                                                            |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Existing compartment / VCN / subnet / service boundary as required}                                     |
|         |                                                                                                |
|         v                                                                                                |
| [Web Application Firewall]                                                                               |
|         |-- WAF policy with access, protection, and rule configuration                                   |
|         |-- web app firewall attachment to the supplied load balancer or web application target          |
|         |-- logging/monitoring integration handled by operational layers                                 |
|         `-- tags, compartment scope, and optional private access controls                                |
|                  |                                                                                       |
|                  v                                                                                       |
| [internet clients] -> [WAF policy] -> [web app firewall] -> [load balancer / web application]            |
|                                                                                                          |
| Review focus: policy mode, target ID, rule actions, TLS/header behavior, logging, and false-positive     |
| review path.                                                                                             |
| Hand-off: service IDs, endpoint names, private access IDs, and operational references for application    |
| teams.                                                                                                   |
+----------------------------------------------------------------------------------------------------------+
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

## Operational Boundaries

- This extension can run extension-only with supplied brownfield OCI IDs, or as
  base-plus-extension using outputs from core, networking, ownership, or
  operations blueprints.
- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_waf_web_app_firewall_policy.this`, `oci_waf_web_app_firewall.this`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
