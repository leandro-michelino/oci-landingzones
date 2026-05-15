# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "security-vault"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

  default_vaults = var.enable_vault && var.enable_default_vault ? {
    default = {
      display_name     = "${local.name_prefix}-vlt"
      compartment_ocid = var.compartment_ocid
      vault_type       = var.default_vault_type
    }
  } : {}

  vaults = var.enable_vault ? merge(local.default_vaults, var.vaults) : {}

  default_keys = var.enable_vault && var.enable_default_vault && var.enable_default_key ? {
    default = {
      display_name              = "${local.name_prefix}-key-default"
      compartment_ocid          = var.compartment_ocid
      vault_key                 = "default"
      vault_management_endpoint = null
      algorithm                 = var.default_key_algorithm
      length                    = var.default_key_length
      curve_id                  = null
      protection_mode           = var.default_key_protection_mode
      desired_state             = null
      is_auto_rotation_enabled  = null
      rotation_interval_in_days = null
      time_of_schedule_start    = null
    }
  } : {}

  keys = var.enable_vault ? merge(local.default_keys, var.keys) : {}

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Module = local.module_name
    }
  )
}
