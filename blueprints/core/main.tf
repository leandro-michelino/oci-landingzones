# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "compartments" {
  source = "../../modules/iam/compartments"

  providers = {
    oci = oci.home
  }

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = local.parent_compartment_ocid
  region           = var.region
  org              = var.org
  environment      = var.environment
  region_key       = var.region_key
  cis_level        = var.cis_level
  enable_delete    = var.enable_delete
  defined_tags     = var.defined_tags
  freeform_tags    = var.freeform_tags
}

module "tagging" {
  source = "../../modules/governance/tagging"

  providers = {
    oci = oci.home
  }

  tenancy_ocid                = var.tenancy_ocid
  compartment_ocid            = module.compartments.compartment_ids["governance"]
  region                      = var.region
  org                         = var.org
  environment                 = var.environment
  region_key                  = var.region_key
  cis_level                   = var.cis_level
  enable_tagging              = var.enable_tagging
  enable_tag_defaults         = var.enable_tag_defaults
  tag_namespace_name          = var.tag_namespace_name
  tag_default_compartment_ids = module.compartments.compartment_ids
  tag_default_values          = local.core_tag_default_values
  required_tag_defaults       = var.required_tag_defaults
  defined_tags                = var.defined_tags
  freeform_tags               = var.freeform_tags
}

module "logging" {
  source = "../../modules/governance/logging"

  tenancy_ocid                = var.tenancy_ocid
  compartment_ocid            = module.compartments.compartment_ids["governance"]
  region                      = var.region
  org                         = var.org
  environment                 = var.environment
  region_key                  = var.region_key
  cis_level                   = var.cis_level
  enable_logging              = var.enable_logging
  log_groups                  = var.log_groups
  service_logs                = var.service_logs
  vcn_flow_logs               = var.vcn_flow_logs
  saved_searches              = var.logging_saved_searches
  enable_audit_retention      = var.enable_audit_retention
  audit_retention_period_days = var.audit_retention_period_days
  defined_tags                = var.defined_tags
  freeform_tags               = var.freeform_tags
}

module "cloud_guard" {
  source = "../../modules/security/cloud-guard"

  tenancy_ocid                = var.tenancy_ocid
  compartment_ocid            = module.compartments.compartment_ids["security"]
  region                      = var.region
  org                         = var.org
  environment                 = var.environment
  region_key                  = var.region_key
  cis_level                   = var.cis_level
  enable_cloud_guard          = var.cloud_guard_enabled
  cloud_guard_status          = var.cloud_guard_status
  reporting_region            = var.cloud_guard_reporting_region
  self_manage_resources       = var.cloud_guard_self_manage_resources
  enable_default_target       = var.cloud_guard_enable_default_target
  target_resource_ocid        = module.compartments.root_compartment_id
  target_resource_type        = "COMPARTMENT"
  target_detector_recipe_ids  = var.cloud_guard_detector_recipe_ids
  target_responder_recipe_ids = var.cloud_guard_responder_recipe_ids
  targets                     = var.cloud_guard_targets
  defined_tags                = var.defined_tags
  freeform_tags               = var.freeform_tags
}

module "vault" {
  source = "../../modules/security/vault"

  tenancy_ocid                = var.tenancy_ocid
  compartment_ocid            = module.compartments.compartment_ids["security"]
  region                      = var.region
  org                         = var.org
  environment                 = var.environment
  region_key                  = var.region_key
  cis_level                   = var.cis_level
  enable_vault                = var.vault_enabled
  enable_default_vault        = var.enable_default_vault
  default_vault_type          = var.default_vault_type
  enable_default_key          = var.enable_default_vault_key
  default_key_algorithm       = var.default_vault_key_algorithm
  default_key_length          = var.default_vault_key_length
  default_key_protection_mode = var.default_vault_key_protection_mode
  vaults                      = var.vaults
  keys                        = var.vault_keys
  defined_tags                = var.defined_tags
  freeform_tags               = var.freeform_tags
}

module "security_zones" {
  source = "../../modules/security/security-zones"

  tenancy_ocid                                  = var.tenancy_ocid
  compartment_ocid                              = module.compartments.compartment_ids["security"]
  region                                        = var.region
  org                                           = var.org
  environment                                   = var.environment
  region_key                                    = var.region_key
  cis_level                                     = var.cis_level
  enable_security_zones                         = var.security_zones_enabled
  enable_default_security_zone                  = var.enable_default_security_zone
  default_security_zone_target_ocid             = module.compartments.root_compartment_id
  default_security_zone_recipe_id               = var.default_security_zone_recipe_id
  default_security_zone_recipe_display_name     = var.default_security_zone_recipe_display_name
  default_security_zone_recipe_compartment_ocid = var.default_security_zone_recipe_compartment_ocid
  security_zones                                = var.security_zones
  defined_tags                                  = var.defined_tags
  freeform_tags                                 = var.freeform_tags

  depends_on = [
    module.cloud_guard
  ]
}

module "budgets" {
  source = "../../modules/governance/budgets"

  tenancy_ocid                        = var.tenancy_ocid
  compartment_ocid                    = module.compartments.compartment_ids["governance"]
  region                              = var.region
  org                                 = var.org
  environment                         = var.environment
  region_key                          = var.region_key
  cis_level                           = var.cis_level
  enable_budgets                      = var.enable_budgets
  enable_default_budget               = var.enable_default_budget
  default_budget_amount               = var.default_budget_amount
  default_budget_target_ocid          = module.compartments.root_compartment_id
  default_budget_target_ocids         = var.default_budget_target_ocids
  default_budget_reset_period         = var.default_budget_reset_period
  default_budget_alert_recipients     = var.default_budget_alert_recipients
  default_budget_alert_threshold      = var.default_budget_alert_threshold
  default_budget_alert_threshold_type = var.default_budget_alert_threshold_type
  default_budget_alert_type           = var.default_budget_alert_type
  budgets                             = var.budgets
  defined_tags                        = var.defined_tags
  freeform_tags                       = var.freeform_tags
}

module "events" {
  source = "../../modules/governance/events"

  tenancy_ocid               = var.tenancy_ocid
  compartment_ocid           = module.compartments.compartment_ids["governance"]
  region                     = var.region
  org                        = var.org
  environment                = var.environment
  region_key                 = var.region_key
  cis_level                  = var.cis_level
  enable_events              = var.enable_events
  enable_default_topic       = var.enable_default_event_topic
  enable_default_event_rules = var.enable_default_event_rules
  notification_topics        = var.event_notification_topics
  subscriptions              = var.event_subscriptions
  event_rules                = var.event_rules
  defined_tags               = var.defined_tags
  freeform_tags              = var.freeform_tags
}

module "groups" {
  source = "../../modules/iam/groups"

  providers = {
    oci = oci.home
  }

  tenancy_ocid          = var.tenancy_ocid
  compartment_ocid      = var.tenancy_ocid
  region                = var.region
  org                   = var.org
  environment           = var.environment
  region_key            = var.region_key
  cis_level             = var.cis_level
  enable_default_groups = var.enable_default_iam_groups
  groups                = var.iam_groups
  defined_tags          = var.defined_tags
  freeform_tags         = var.freeform_tags
}

module "dynamic_groups" {
  source = "../../modules/iam/dynamic-groups"

  providers = {
    oci = oci.home
  }

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.tenancy_ocid
  region           = var.region
  org              = var.org
  environment      = var.environment
  region_key       = var.region_key
  cis_level        = var.cis_level
  dynamic_groups   = local.core_dynamic_groups
  defined_tags     = var.defined_tags
  freeform_tags    = var.freeform_tags
}

module "policies" {
  source = "../../modules/iam/policies"

  providers = {
    oci = oci.home
  }

  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = local.parent_compartment_ocid
  region                  = var.region
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  cis_level               = var.cis_level
  enable_default_policies = var.enable_default_iam_policies
  group_names             = module.groups.group_names
  dynamic_group_names     = module.dynamic_groups.dynamic_group_names
  compartment_names       = module.compartments.compartment_names
  policies                = var.iam_policies
  defined_tags            = var.defined_tags
  freeform_tags           = var.freeform_tags
}
