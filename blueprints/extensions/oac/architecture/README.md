# Oracle Analytics Cloud Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/oac`. It is intentionally ASCII-first so it is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys an Oracle Analytics Cloud instance with optional private access channel.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/extensions/oac` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Deploys an Oracle Analytics Cloud instance with optional private access channel. |
| Terraform components | `oci_analytics_analytics_instance.this`, `oci_analytics_analytics_instance_private_access_channel.this` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic or control flow for this exact deployment. |

## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Oracle Analytics Cloud                                                                                   |
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
| [Oracle Analytics Cloud]                                                                                 |
|         |-- analytics instance with feature set, license type, and capacity                              |
|         |-- private access channel with supplied VCN/subnet/NSGs when enabled                            |
|         |-- DNS and private data source path for databases or application endpoints                      |
|         `-- tags, compartment scope, and optional private access controls                                |
|                  |                                                                                       |
|                  v                                                                                       |
| [analytics users] -> [OAC instance] -> [private access channel] -> [private data sources]                |
|                                                                                                          |
| Review focus: capacity, identity integration, private access channel subnet, DNS zones, NSGs, and        |
| data-source reachability.                                                                                |
| Hand-off: service IDs, endpoint names, private access IDs, and operational references for application    |
| teams.                                                                                                   |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_analytics_analytics_instance.this` | Declared directly in `main.tf` |
| Resource | `oci_analytics_analytics_instance_private_access_channel.this` | Declared directly in `main.tf` |

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

- Confirm feature set, license type, and capacity.
- Confirm private access channel subnet, VCN, NSGs, and DNS zones.
- Confirm KMS and identity-domain decisions.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_analytics_analytics_instance.this`, `oci_analytics_analytics_instance_private_access_channel.this`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
