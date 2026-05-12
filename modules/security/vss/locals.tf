# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "security-vss"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

  default_host_scan_recipes = var.enable_vss && var.enable_default_host_scan ? {
    default = {
      display_name         = "${local.name_prefix}-vss-host-recipe"
      compartment_ocid     = var.compartment_ocid
      agent_scan_level     = var.default_host_agent_scan_level
      port_scan_level      = var.default_host_port_scan_level
      schedule_type        = var.default_host_scan_schedule_type
      day_of_week          = var.default_host_scan_day_of_week
      agent_configuration  = null
      application_settings = null
    }
  } : {}

  default_host_scan_targets = var.enable_vss && var.enable_default_host_scan ? {
    default = {
      display_name            = "${local.name_prefix}-vss-host-target"
      description             = "Landing zone host scan target managed by Terraform."
      compartment_ocid        = var.compartment_ocid
      target_compartment_ocid = coalesce(var.default_host_scan_target_compartment_ocid, var.compartment_ocid)
      host_scan_recipe_key    = "default"
      host_scan_recipe_id     = null
      instance_ids            = []
    }
  } : {}

  host_scan_recipes = var.enable_vss ? merge(local.default_host_scan_recipes, var.host_scan_recipes) : {}
  host_scan_targets = var.enable_vss ? merge(local.default_host_scan_targets, var.host_scan_targets) : {}

  container_scan_recipes = var.enable_vss ? var.container_scan_recipes : {}
  container_scan_targets = var.enable_vss ? var.container_scan_targets : {}

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Module = local.module_name
    }
  )
}
