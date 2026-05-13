# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_ons_notification_topic" "this" {
  count = var.create_notification_topic ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.topic_name
  description    = "OCI DevOps notifications for ${local.name_prefix}."
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_devops_project" "this" {
  count = var.enable_devops_project ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.project_name
  description    = var.project_description
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  notification_config {
    topic_id = local.notification_topic_id
  }
}

resource "oci_devops_repository" "this" {
  count = var.enable_repository ? 1 : 0

  project_id      = local.project_id
  name            = local.repository_name
  repository_type = var.repository_type
  default_branch  = var.default_branch
  description     = var.repository_description
  defined_tags    = var.defined_tags
  freeform_tags   = local.common_freeform_tags
}

resource "oci_devops_build_pipeline" "this" {
  count = var.enable_build_pipeline ? 1 : 0

  project_id    = local.project_id
  display_name  = local.build_pipeline_name
  description   = var.build_pipeline_description
  defined_tags  = var.defined_tags
  freeform_tags = local.common_freeform_tags
}

resource "oci_devops_deploy_pipeline" "this" {
  count = var.enable_deploy_pipeline ? 1 : 0

  project_id    = local.project_id
  display_name  = local.deploy_pipeline_name
  description   = var.deploy_pipeline_description
  defined_tags  = var.defined_tags
  freeform_tags = local.common_freeform_tags
}
