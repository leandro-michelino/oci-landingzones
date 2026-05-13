# Oracle Integration Cloud Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/oic`. It is intentionally ASCII-first so it is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys an Oracle Integration Cloud instance with optional private outbound connection.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/extensions/oic` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Deploys an Oracle Integration Cloud instance with optional private outbound connection. |
| Terraform components | `oci_integration_integration_instance.this`, `oci_integration_private_endpoint_outbound_connection.this` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic or control flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `integration_instance_id`, `outbound_connection_id` |

## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Oracle Integration Cloud                                                                         |
|                                                                                                  |
|  Integration users and adapters
|         |
|         v
|  OIC instance
|         |
|         v
|  private outbound connection
|         |
|         v
|  VCN subnet and NSGs
|         |
|         v
|  SaaS or private application endpoints
|                                                                                                  |
|  Control: Terraform creates enabled resources from variables and returns stable hand-off outputs. |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_integration_integration_instance.this` | Declared directly in `main.tf` |
| Resource | `oci_integration_private_endpoint_outbound_connection.this` | Declared directly in `main.tf` |

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

- Confirm edition, message packs, BYOL, and file server decisions.
- Confirm private outbound subnet and NSGs.
- Confirm IDCS/domain authentication inputs when required by tenancy policy.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_integration_integration_instance.this`, `oci_integration_private_endpoint_outbound_connection.this`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `integration_instance_id`, `outbound_connection_id`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
