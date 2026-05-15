# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "tagging" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/governance/tagging?ref=v0.2.0"

  providers = {
    oci = oci.home
  }

  tenancy_ocid                = var.tenancy_ocid
  compartment_ocid            = local.target_compartment_ocid
  region                      = var.region
  org                         = var.org
  environment                 = var.environment
  region_key                  = var.region_key
  enable_tagging              = var.enable_tagging
  enable_tag_defaults         = var.enable_tag_defaults
  tag_namespace_name          = var.tag_namespace_name
  tag_namespace_description   = var.tag_namespace_description
  tag_definitions             = var.tag_definitions
  tag_default_compartment_ids = var.tag_default_compartment_ids
  tag_default_values          = local.tag_default_values
  required_tag_defaults       = var.required_tag_defaults
  defined_tags                = var.defined_tags
  freeform_tags               = local.common_freeform_tags
}

module "budgets" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/governance/budgets?ref=v0.2.0"

  tenancy_ocid                        = var.tenancy_ocid
  compartment_ocid                    = local.target_compartment_ocid
  region                              = var.region
  org                                 = var.org
  environment                         = var.environment
  region_key                          = var.region_key
  enable_budgets                      = var.enable_budgets
  enable_default_budget               = var.enable_default_budget
  default_budget_amount               = var.default_budget_amount
  default_budget_target_ocid          = var.default_budget_target_ocid
  default_budget_target_ocids         = var.default_budget_target_ocids
  default_budget_reset_period         = var.default_budget_reset_period
  default_budget_alert_recipients     = var.default_budget_alert_recipients
  default_budget_alert_threshold      = var.default_budget_alert_threshold
  default_budget_alert_threshold_type = var.default_budget_alert_threshold_type
  default_budget_alert_type           = var.default_budget_alert_type
  budgets                             = var.budgets
  defined_tags                        = var.defined_tags
  freeform_tags                       = local.common_freeform_tags
}

module "notifications" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/governance/events?ref=v0.2.0"

  tenancy_ocid               = var.tenancy_ocid
  compartment_ocid           = local.notification_compartment_ocid
  region                     = var.region
  org                        = var.org
  environment                = var.environment
  region_key                 = var.region_key
  enable_events              = var.enable_notifications
  enable_default_topic       = false
  enable_default_event_rules = false
  notification_topics        = local.notification_topics
  subscriptions              = var.notification_subscriptions
  event_rules                = var.notification_event_rules
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

module "monitoring" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/operations/monitoring?ref=v0.2.0"

  tenancy_ocid         = var.tenancy_ocid
  compartment_ocid     = local.target_compartment_ocid
  region               = var.region
  org                  = var.org
  environment          = var.environment
  region_key           = var.region_key
  enable_monitoring    = length(local.monitoring_alarms) > 0
  enable_default_topic = false
  notification_topics  = {}
  subscriptions        = {}
  alarms               = local.monitoring_alarms
  defined_tags         = var.defined_tags
  freeform_tags        = local.common_freeform_tags
}

resource "oci_optimizer_enrollment_status" "this" {
  count = var.enable_optimizer_enrollment && var.optimizer_enrollment_status_id != null ? 1 : 0

  enrollment_status_id = var.optimizer_enrollment_status_id
  status               = upper(var.optimizer_enrollment_status)
}

resource "oci_optimizer_profile" "this" {
  for_each = local.optimizer_profiles

  compartment_id               = coalesce(each.value.compartment_ocid, local.target_compartment_ocid)
  name                         = coalesce(each.value.name, "${local.name_prefix}-opt-${each.key}")
  description                  = coalesce(each.value.description, "Optimizer profile ${each.key} managed by Terraform.")
  aggregation_interval_in_days = each.value.aggregation_interval_in_days
  defined_tags                 = var.defined_tags
  freeform_tags                = local.common_freeform_tags

  dynamic "target_compartments" {
    for_each = length(each.value.target_compartment_ids) > 0 ? [each.value.target_compartment_ids] : []

    content {
      items = tolist(target_compartments.value)
    }
  }

  dynamic "target_tags" {
    for_each = length(each.value.target_tags) > 0 ? [each.value.target_tags] : []

    content {
      dynamic "items" {
        for_each = target_tags.value

        content {
          tag_namespace_name  = items.value.tag_namespace_name
          tag_definition_name = items.value.tag_definition_name
          tag_value_type      = upper(items.value.tag_value_type)
          tag_values          = items.value.tag_values
        }
      }
    }
  }

  dynamic "levels_configuration" {
    for_each = length(each.value.levels_configuration) > 0 ? [each.value.levels_configuration] : []

    content {
      dynamic "items" {
        for_each = levels_configuration.value

        content {
          recommendation_id = items.value.recommendation_id
          level             = items.value.level
        }
      }
    }
  }
}

resource "oci_identity_policy" "finops_access" {
  count = length(var.finops_policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-finops"
  description    = "FinOps access policy for cost optimization operations."
  statements     = var.finops_policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
