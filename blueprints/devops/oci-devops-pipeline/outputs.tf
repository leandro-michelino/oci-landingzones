# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}
output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this blueprint."
  value       = local.name_prefix
}
output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint."
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
