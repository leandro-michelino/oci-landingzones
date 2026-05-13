module "core" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/core?ref=v0.2.0"

  tenancy_ocid       = var.tenancy_ocid
  current_user_ocid  = var.current_user_ocid
  region             = var.region
  home_region        = var.home_region
  oci_config_profile = var.oci_config_profile
  org                = var.org
  environment        = var.environment
  region_key         = var.region_key
  cis_level          = local.cis_level

  parent_compartment_ocid                   = var.parent_compartment_ocid
  enable_delete                             = var.enable_delete
  enable_tagging                            = var.enable_tagging
  enable_tag_defaults                       = var.enable_tag_defaults
  enable_audit_retention                    = var.enable_audit_retention
  audit_retention_period_days               = var.audit_retention_period_days
  cloud_guard_enabled                       = var.cloud_guard_enabled
  cloud_guard_detector_recipe_ids           = var.cloud_guard_detector_recipe_ids
  cloud_guard_responder_recipe_ids          = var.cloud_guard_responder_recipe_ids
  vault_enabled                             = var.vault_enabled
  enable_default_vault_key                  = var.enable_default_vault_key
  vaults                                    = var.vaults
  vault_keys                                = var.vault_keys
  security_zones_enabled                    = var.security_zones_enabled
  default_security_zone_recipe_id           = var.default_security_zone_recipe_id
  default_security_zone_recipe_display_name = var.default_security_zone_recipe_display_name
  security_zones                            = var.security_zones
  vss_enabled                               = var.vss_enabled
  enable_default_host_scan                  = var.enable_default_host_scan
  enable_budgets                            = var.budget_amount != null || length(var.budgets) > 0
  default_budget_amount                     = var.budget_amount
  default_budget_alert_recipients           = var.budget_alert_recipients
  budgets                                   = var.budgets
  enable_events                             = var.enable_events
  event_subscriptions                       = var.event_subscriptions
  event_rules                               = var.event_rules
  monitoring_enabled                        = var.monitoring_enabled
  monitoring_subscriptions                  = var.monitoring_subscriptions
  monitoring_alarms                         = var.monitoring_alarms

  defined_tags = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Compliance = "cis-level2"
    }
  )
}
