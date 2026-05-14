# Healthcare PCI Compliance Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/compliance/healthcare-pci`. It is intentionally ASCII-first so it is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys a regulated landing-zone control pack with IAM guardrail policy, budget alerting, and optional Data Safe target registration.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/compliance/healthcare-pci` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Deploys a regulated landing-zone control pack with IAM guardrail policy, budget alerting, and optional Data Safe target registration. |
| Terraform components | `oci_identity_policy.guardrails`, `oci_budget_budget.this`, `oci_budget_alert_rule.this`, `oci_data_safe_target_database.this` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic or control flow for this exact deployment. |

## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Healthcare PCI Compliance                                                                                |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Compliance landing-zone boundary}                                                                       |
|         |                                                                                                |
|         v                                                                                                |
| [Healthcare / PCI guardrail, budget, and Data Safe controls]                                             |
|         |-- identity and compartment guardrails                                                          |
|         |-- logging, monitoring, budget, and evidence paths                                              |
|         |-- private or inspected network path where applicable                                           |
|         `-- workload-specific security service attachments                                               |
|                  |                                                                                       |
|                  v                                                                                       |
| [review evidence lane] findings -> logs -> alarms -> operator action                                     |
|                                                                                                          |
| Control flow: foundation controls first, then network or workload-specific compliance services.          |
| Trust boundary: the compliance scope is explicit; exceptions should be documented before apply.          |
| Hand-off: guardrail policies, budget and alert IDs, network/security IDs, and review evidence locations. |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_identity_policy.guardrails` | Declared directly in `main.tf` |
| Resource | `oci_budget_budget.this` | Declared directly in `main.tf` |
| Resource | `oci_budget_alert_rule.this` | Declared directly in `main.tf` |
| Resource | `oci_data_safe_target_database.this` | Declared directly in `main.tf` |

## Request And Deployment Flow

- Operator supplies the existing network, compartment, service, or backend IDs required by the deployment.
- Terraform creates the optional service resource graph declared in `main.tf`.
- Outputs expose service IDs, endpoint names, or attachment IDs for applications and runbooks.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is permission and signal flow.
- Trust boundaries are the tenancy, compartment, VCN, subnet, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

- Confirm HIPAA and PCI scope before enabling policies.
- Confirm budget recipients and finance owner.
- Confirm Data Safe credentials are supplied securely.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_identity_policy.guardrails`, `oci_budget_budget.this`, `oci_budget_alert_rule.this`, `oci_data_safe_target_database.this`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
