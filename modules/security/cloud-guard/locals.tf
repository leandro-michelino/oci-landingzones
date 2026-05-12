# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "security-cloud-guard"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

  default_targets = var.enable_cloud_guard && var.enable_default_target ? {
    landing_zone = {
      display_name         = "${local.name_prefix}-cg-target-landing-zone"
      description          = "Cloud Guard target for the landing zone root scope."
      compartment_ocid     = var.compartment_ocid
      target_resource_id   = coalesce(var.target_resource_ocid, var.compartment_ocid)
      target_resource_type = var.target_resource_type
      detector_recipe_ids  = var.target_detector_recipe_ids
      responder_recipe_ids = var.target_responder_recipe_ids
    }
  } : {}

  targets = var.enable_cloud_guard ? merge(local.default_targets, var.targets) : {}

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Module = local.module_name
    }
  )
}
