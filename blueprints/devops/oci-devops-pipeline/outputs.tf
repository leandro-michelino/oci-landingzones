# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}
output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}
output "resource_ids" {
  description = "Consolidated map of resource and contract identifiers produced by this blueprint; use it as the primary machine-readable hand-off for integration and runbook steps."
  value = {
    notification_topic = try(oci_ons_notification_topic.this[0].id, null)
    project            = try(oci_devops_project.this[0].id, null)
    repository         = try(oci_devops_repository.this[0].id, null)
    build_pipeline     = try(oci_devops_build_pipeline.this[0].id, null)
    deploy_pipeline    = try(oci_devops_deploy_pipeline.this[0].id, null)
  }
}
output "project_id" {
  description = "OCI DevOps project OCID."
  value       = local.project_id
}
output "repository_id" {
  description = "OCI DevOps repository OCID."
  value       = try(oci_devops_repository.this[0].id, null)
}
output "build_pipeline_id" {
  description = "OCI DevOps build pipeline OCID."
  value       = try(oci_devops_build_pipeline.this[0].id, null)
}
output "deploy_pipeline_id" {
  description = "OCI DevOps deployment pipeline OCID."
  value       = try(oci_devops_deploy_pipeline.this[0].id, null)
}
output "notification_topic_id" {
  description = "ONS topic OCID used by the DevOps project."
  value       = local.notification_topic_id
}
