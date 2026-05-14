# OCI DevOps Pipeline Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/devops/oci-devops-pipeline`. It is intentionally ASCII-first so it is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys an OCI DevOps project with notification topic, code repository, build pipeline, and deploy pipeline.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/devops/oci-devops-pipeline` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Deploys an OCI DevOps project with notification topic, code repository, build pipeline, and deploy pipeline. |
| Terraform components | `oci_ons_notification_topic.this`, `oci_devops_project.this`, `oci_devops_repository.this`, `oci_devops_build_pipeline.this`, `oci_devops_deploy_pipeline.this` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic or control flow for this exact deployment. |

## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| OCI DevOps Pipeline                                                                                      |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {OCI DevOps compartment / selected region}                                                               |
|         |                                                                                                |
|         +--> [notification topic] -> build/deploy event subscribers                                      |
|         |                                                                                                |
|         +--> [DevOps project]                                                                            |
|         |      |-- [code repository]                                                                     |
|         |      |-- [build pipeline]  source -> stages -> artifacts                                       |
|         |      `-- [deploy pipeline] environment -> stages -> approval/release path                      |
|         |                                                                                                |
|         `--> [IAM policies outside this folder] must permit project, build, deploy, and artifact actions |
|                                                                                                          |
| Control flow: topic first, project second, repository/pipelines after the project ID exists.             |
| Delivery flow: commit or manual trigger -> build pipeline -> deploy pipeline -> notification topic.      |
| Hand-off: project, repository, build pipeline, deploy pipeline, and notification topic IDs.              |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_ons_notification_topic.this` | Declared directly in `main.tf` |
| Resource | `oci_devops_project.this` | Declared directly in `main.tf` |
| Resource | `oci_devops_repository.this` | Declared directly in `main.tf` |
| Resource | `oci_devops_build_pipeline.this` | Declared directly in `main.tf` |
| Resource | `oci_devops_deploy_pipeline.this` | Declared directly in `main.tf` |

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

- Confirm notification recipients and topic ownership.
- Confirm repository naming and branch strategy.
- Add stages after project, repository, and pipeline IDs are approved.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_ons_notification_topic.this`, `oci_devops_project.this`, `oci_devops_repository.this`, `oci_devops_build_pipeline.this`, `oci_devops_deploy_pipeline.this`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
