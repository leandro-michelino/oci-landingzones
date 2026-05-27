# Oracle Digital Assistant Architecture

This page is the deployment architecture for
`blueprints/extensions/digital-assistant`. It is intentionally Architecture-first
so it is easy to review in GitHub, terminals, pull requests, runbooks, and
customer notes without a diagramming tool.

## Deployment Purpose

Implements Oracle Digital Assistant with private endpoint-capable networking,
optional endpoint attachment, and clear operational hand-off contracts.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/extensions/digital-assistant` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Deploy ODA instance resources and private endpoint wiring with reusable network/IAM guardrails. |
| Terraform components | `oci_core_vcn.oda`, `oci_core_route_table.oda`, `oci_core_security_list.oda`, `oci_core_subnet.oda`, `oci_core_network_security_group.oda`, `oci_core_network_security_group_security_rule.oda_ingress_https`, `oci_core_network_security_group_security_rule.oda_egress_all`, `oci_oda_oda_instance.this`, `oci_oda_oda_private_endpoint.this`, `oci_oda_oda_private_endpoint_attachment.this`, `oci_ons_notification_topic.alert`, `terraform_data.oda_network_contract`, `terraform_data.oda_contract` |
| Primary architecture view | The Architecture diagram below shows ODA components, endpoint path, and contract outputs for this deployment. |

## Architecture

```text
+----------------------------------------------------------------------------------------------------------------+
| Oracle Digital Assistant Blueprint                                                                             |
+----------------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow                    |
|                                                                                                                |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                                |
|         |                    |                         |                                                       |
|         | validates docs      | init/validate/plan      | OCI API calls                                        |
|         v                    v                         v                                                       |
| {OCI tenancy boundary}                                                                                         |
|   |                                                                                                            |
|   |-- [VCN + route table + security list + subnet + NSG] (optional)                                           |
|   |-- [ODA instance]                                                                                           |
|   |      |-- role-based access                                                                                |
|   |      `-- identity domain integration (optional)                                                           |
|   |-- [ODA private endpoint] (optional)                                                                       |
|   |      `-- subnet + NSG placement                                                                           |
|   |-- [ODA private endpoint attachment] (optional)                                                            |
|   |-- [Notifications topic] (optional)                                                                        |
|   `-- [terraform_data contracts + optional IAM policy]                                                        |
|          |-- network hand-off                                                                                 |
|          `-- instance/endpoint operational contract                                                           |
|                                                                                                                |
| [Integration clients / channels] -> HTTPS -> [ODA private endpoint] -> [ODA instance connectors]             |
+----------------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.oda`, `oci_core_route_table.oda`, `oci_core_security_list.oda`, `oci_core_subnet.oda` | Optional deploy-and-use network foundation for ODA private endpoint placement. |
| Resource | `oci_core_network_security_group.oda` | NSG boundary for ODA private endpoint traffic. |
| Resource | `oci_core_network_security_group_security_rule.oda_ingress_https`, `oci_core_network_security_group_security_rule.oda_egress_all` | Stateless HTTPS ingress and scoped HTTPS egress guardrails. |
| Resource | `oci_oda_oda_instance.this` | ODA instance for conversational platform workloads. |
| Resource | `oci_oda_oda_private_endpoint.this` | ODA private endpoint for controlled channel integration. |
| Resource | `oci_oda_oda_private_endpoint_attachment.this` | Optional attachment between ODA instance and private endpoint. |
| Resource | `oci_ons_notification_topic.alert` | Optional alert topic for operational events and channel notifications. |
| Resource | `oci_identity_policy.access` | Optional policy shell for ODA administrators and integration callers. |
| Resource | `terraform_data.oda_network_contract` | Network output contract for downstream wiring. |
| Resource | `terraform_data.oda_contract` | ODA operational contract for access and endpoint metadata. |

## Request And Deployment Flow

- Operator chooses whether to create ODA instance, private endpoint, and attachment in this run.
- Terraform creates optional network resources and NSG controls.
- Terraform creates ODA instance and optional private endpoint resources.
- Terraform attaches endpoint to instance when requested.
- Outputs publish instance URLs, endpoint IDs, and network contracts for integration teams.

## Traffic And Trust Boundaries

- Control plane traffic is local/CI authentication into OCI provider via Terraform runner.
- Data plane traffic is HTTPS integration traffic from approved CIDRs to ODA private endpoint and ODA connectors.
- Trust boundaries include tenancy compartment ownership, endpoint subnet ownership, and optional policy ownership.
- Secrets and tenancy identifiers remain in ignored local tfvars or approved pipeline secret stores.

## Detailed Architecture Notes

These notes expand the diagram with design details usually needed in reviews.

- ODA instance creation and private endpoint creation are decoupled so teams can stage rollout safely.
- Attachment step is explicit and precondition-guarded to prevent partial misconfiguration.
- Network creation is optional to support extension-only mode in existing customer estates.
- Security rules are intentionally minimal: HTTPS ingress from the allowed CIDR and CIDR-scoped HTTPS egress.
- Optional IAM policies let platform teams codify role boundaries in the same deployment.
- Alert topic creation is optional and intended for runbook and channel-monitoring hooks.

## Operational Boundaries

- Supports extension-only and base-plus-extension operating models.
- Apply and destroy are approval-gated operations through guarded Ansible workflows.
- Keep tenancy-specific IDs, endpoint values, and policy statements in local ignored tfvars.
- Re-run plan when shape, endpoint subnet, NSG list, or attachment mode changes.
- Use outputs as the source of truth for integration onboarding and runbook updates.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_core_vcn.oda`, `oci_core_route_table.oda`, `oci_core_security_list.oda`, `oci_core_subnet.oda`, `oci_core_network_security_group.oda`, `oci_core_network_security_group_security_rule.oda_ingress_https`, `oci_core_network_security_group_security_rule.oda_egress_all`, `oci_oda_oda_instance.this`, `oci_oda_oda_private_endpoint.this`, `oci_oda_oda_private_endpoint_attachment.this`, `oci_ons_notification_topic.alert`, `terraform_data.oda_network_contract`, `terraform_data.oda_contract`.
- Confirm ODA shape/edition and role-based-access choices align with platform policy.
- Confirm private endpoint subnet, NSG IDs, and allowed CIDR values are correct.
- Confirm attachment mode and sequencing are intentional for this environment.
- Confirm policy statements align with intended ODA operator and caller groups.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared runner.
