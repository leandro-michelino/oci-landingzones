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
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `project_id`, `repository_id`, `build_pipeline_id`, `deploy_pipeline_id`, `notification_topic_id` |

## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| OCI DevOps Pipeline                                                                              |
|                                                                                                  |
|  Developer push
|         |
|         v
|  OCI DevOps repository
|         |
|         v
|  Build pipeline
|         |
|         v
|  Deploy pipeline
|         |
|         v
|  ONS notifications
|                                                                                                  |
|  Control: Terraform creates enabled resources from variables and returns stable hand-off outputs. |
+--------------------------------------------------------------------------------------------------+
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
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `project_id`, `repository_id`, `build_pipeline_id`, `deploy_pipeline_id`, `notification_topic_id`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
