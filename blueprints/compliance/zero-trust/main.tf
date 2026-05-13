# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "core" {
  source = "../../../blueprints/core"

  tenancy_ocid       = var.tenancy_ocid
  current_user_ocid  = var.current_user_ocid
  region             = var.region
  home_region        = var.home_region
  oci_config_profile = var.oci_config_profile
  org                = var.org
  environment        = var.environment
  region_key         = var.region_key
  cis_level          = "level2"

  parent_compartment_ocid         = var.parent_compartment_ocid
  enable_delete                   = var.enable_delete
  enable_tagging                  = var.enable_tagging
  enable_tag_defaults             = var.enable_tag_defaults
  enable_audit_retention          = true
  cloud_guard_enabled             = true
  vault_enabled                   = var.vault_enabled
  enable_default_vault_key        = var.enable_default_vault_key
  security_zones_enabled          = var.security_zones_enabled
  default_security_zone_recipe_id = var.default_security_zone_recipe_id
  vss_enabled                     = var.vss_enabled
  enable_default_host_scan        = var.enable_default_host_scan
  enable_events                   = var.enable_events
  monitoring_enabled              = var.monitoring_enabled

  defined_tags = var.defined_tags
  freeform_tags = merge(
    local.common_freeform_tags,
    {
      Compliance = "zero-trust"
    }
  )
}

module "network" {
  source = "../../../blueprints/networking/standalone-three-tier-vcn-zpr"

  tenancy_ocid             = var.tenancy_ocid
  current_user_ocid        = var.current_user_ocid
  region                   = var.region
  home_region              = var.home_region
  oci_config_profile       = var.oci_config_profile
  compartment_ocid         = coalesce(var.network_compartment_ocid, module.core.network_compartment_id)
  org                      = var.org
  environment              = var.environment
  region_key               = var.region_key
  enable_zpr_configuration = var.enable_zpr_configuration
  enable_zpr_policies      = var.enable_zpr_policies
  zpr_policies             = var.zpr_policies
  defined_tags             = var.defined_tags
  freeform_tags            = local.common_freeform_tags
}
