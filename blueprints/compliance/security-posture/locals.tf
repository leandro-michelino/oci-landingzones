# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "security-posture"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  report_bucket_name      = coalesce(var.report_bucket_name, "${local.name_prefix}-bkt-reports")
  topic_id                = var.create_topic ? try(oci_ons_notification_topic.this[0].id, null) : var.topic_id
  host_scan_recipe_id     = var.create_host_scan_recipe ? try(oci_vulnerability_scanning_host_scan_recipe.this[0].id, null) : var.host_scan_recipe_id
  cloud_guard_target_id   = var.create_cloud_guard_target ? try(oci_cloud_guard_target.this[0].id, null) : var.cloud_guard_target_id

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
