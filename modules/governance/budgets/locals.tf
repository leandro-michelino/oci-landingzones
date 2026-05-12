# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "governance-budgets"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

  default_budget_targets = length(var.default_budget_target_ocids) > 0 ? tolist(var.default_budget_target_ocids) : [
    coalesce(var.default_budget_target_ocid, var.compartment_ocid)
  ]

  default_budgets = var.enable_budgets && var.enable_default_budget && var.default_budget_amount != null ? {
    landing_zone = {
      display_name                          = "${local.name_prefix}-budget-landing-zone"
      description                           = "Landing zone budget managed by Terraform."
      compartment_ocid                      = var.compartment_ocid
      amount                                = var.default_budget_amount
      reset_period                          = var.default_budget_reset_period
      target_type                           = "COMPARTMENT"
      targets                               = local.default_budget_targets
      processing_period_type                = null
      start_date                            = null
      end_date                              = null
      budget_processing_period_start_offset = null
      alert_rules                           = {}
    }
  } : {}

  budgets = var.enable_budgets ? merge(local.default_budgets, var.budgets) : {}

  default_alert_rules = var.enable_budgets && contains(keys(local.default_budgets), "landing_zone") && length(var.default_budget_alert_recipients) > 0 ? {
    "landing_zone.default" = {
      budget_key     = "landing_zone"
      rule_key       = "default"
      display_name   = "${local.name_prefix}-budget-alert-landing-zone"
      description    = "Default alert for the landing zone budget."
      message        = "Landing zone budget threshold exceeded."
      recipients     = join(",", sort(tolist(var.default_budget_alert_recipients)))
      threshold      = var.default_budget_alert_threshold
      threshold_type = var.default_budget_alert_threshold_type
      type           = var.default_budget_alert_type
    }
  } : {}

  custom_alert_rules = merge(
    {},
    [
      for budget_key, budget in local.budgets : {
        for rule_key, rule in budget.alert_rules : "${budget_key}.${rule_key}" => {
          budget_key     = budget_key
          rule_key       = rule_key
          display_name   = rule.display_name
          description    = rule.description
          message        = rule.message
          recipients     = rule.recipients
          threshold      = rule.threshold
          threshold_type = rule.threshold_type
          type           = rule.type
        }
      }
    ]...
  )

  alert_rules = merge(local.default_alert_rules, local.custom_alert_rules)

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Module = local.module_name
    }
  )
}
