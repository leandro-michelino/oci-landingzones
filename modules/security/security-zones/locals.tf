# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "security-security-zones"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

  default_security_zones = var.enable_security_zones && var.enable_default_security_zone && (var.default_security_zone_recipe_id != null || var.default_security_zone_recipe_display_name != null) ? {
    landing_zone = {
      display_name                          = "${local.name_prefix}-sz-landing-zone"
      description                           = "Landing zone Security Zone managed by Terraform."
      compartment_ocid                      = coalesce(var.default_security_zone_target_ocid, var.compartment_ocid)
      security_zone_recipe_id               = var.default_security_zone_recipe_id
      security_zone_recipe_display_name     = var.default_security_zone_recipe_display_name
      security_zone_recipe_compartment_ocid = var.default_security_zone_recipe_compartment_ocid
      is_inheritance_after_delete_enabled   = null
    }
  } : {}

  security_zones = var.enable_security_zones ? merge(local.default_security_zones, var.security_zones) : {}

  recipe_lookups = {
    for key, zone in local.security_zones : key => {
      display_name     = zone.security_zone_recipe_display_name
      compartment_ocid = coalesce(zone.security_zone_recipe_compartment_ocid, var.tenancy_ocid)
    }
    if zone.security_zone_recipe_id == null && zone.security_zone_recipe_display_name != null
  }

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Module = local.module_name
    }
  )
}
