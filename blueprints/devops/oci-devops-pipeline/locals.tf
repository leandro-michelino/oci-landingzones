# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "oci-devops-pipeline"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
  topic_name            = coalesce(var.topic_name, "${local.name_prefix}-top-devops")
  notification_topic_id = var.create_notification_topic ? oci_ons_notification_topic.this[0].id : var.notification_topic_id
  project_name          = coalesce(var.project_name, "${local.name_prefix}-proj-devops")
  project_id            = var.enable_devops_project ? oci_devops_project.this[0].id : var.existing_project_id
  repository_name       = coalesce(var.repository_name, "${local.name_prefix}-repo")
  build_pipeline_name   = coalesce(var.build_pipeline_name, "${local.name_prefix}-build")
  deploy_pipeline_name  = coalesce(var.deploy_pipeline_name, "${local.name_prefix}-deploy")
}
