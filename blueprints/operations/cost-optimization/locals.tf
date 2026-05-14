# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name                = "operations-cost-optimization"
  name_prefix                   = lower(join("-", compact([var.org, var.environment, var.region_key, "costopt"])))
  target_compartment_ocid       = coalesce(var.compartment_ocid, var.tenancy_ocid)
  notification_compartment_ocid = coalesce(var.notification_compartment_ocid, local.target_compartment_ocid)
  policy_compartment_ocid       = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)

  tag_default_values = merge(
    {
      Environment = var.environment
      CostCenter  = var.default_cost_center
      Owner       = var.default_owner
      ManagedBy   = "terraform"
      Blueprint   = local.blueprint_name
    },
    var.tag_default_values
  )

  default_notification_topics = var.enable_notifications ? {
    finops = {
      name             = "${local.name_prefix}-topic-finops"
      description      = "FinOps notifications for budget, anomaly, and cost-governance events."
      compartment_ocid = local.notification_compartment_ocid
    }
  } : {}

  notification_topics = merge(local.default_notification_topics, var.notification_topics)

  optimizer_target_compartment_ids = length(var.optimizer_target_compartment_ids) > 0 ? var.optimizer_target_compartment_ids : toset([local.target_compartment_ocid])

  default_optimizer_profiles = var.enable_default_optimizer_profile ? {
    finops = {
      name                         = "${local.name_prefix}-optimizer-finops"
      description                  = "FinOps optimizer profile scoped to approved landing-zone compartments."
      compartment_ocid             = local.target_compartment_ocid
      aggregation_interval_in_days = var.optimizer_aggregation_interval_in_days
      target_compartment_ids       = local.optimizer_target_compartment_ids
      target_tags                  = []
      levels_configuration         = []
    }
  } : {}

  optimizer_profiles = var.enable_optimizer_profiles ? merge(local.default_optimizer_profiles, var.optimizer_profiles) : {}

  finops_topic_id = try(module.notifications.notification_topic_ids["finops"], null)

  budget_alarm_destinations = toset(compact(concat(
    tolist(var.budget_alarm_destination_ids),
    var.enable_notifications && local.finops_topic_id != null ? [local.finops_topic_id] : []
  )))

  default_budget_alarm = var.enable_budget_alarm && var.budget_alarm_query != null && length(local.budget_alarm_destinations) > 0 ? {
    budget_spend = {
      display_name                                  = "${local.name_prefix}-alarm-budget-spend"
      body                                          = "Budget or cost threshold breached for ${local.name_prefix}."
      compartment_ocid                              = local.target_compartment_ocid
      metric_compartment_ocid                       = coalesce(var.budget_alarm_metric_compartment_ocid, local.target_compartment_ocid)
      metric_compartment_id_in_subtree              = var.budget_alarm_metric_compartment_id_in_subtree
      namespace                                     = var.budget_alarm_namespace
      query                                         = var.budget_alarm_query
      severity                                      = var.budget_alarm_severity
      is_enabled                                    = true
      destinations                                  = local.budget_alarm_destinations
      destination_topic_keys                        = []
      pending_duration                              = var.budget_alarm_pending_duration
      resolution                                    = null
      resource_group                                = null
      message_format                                = null
      repeat_notification_duration                  = var.budget_alarm_repeat_notification_duration
      evaluation_slack_duration                     = null
      is_notifications_per_metric_dimension_enabled = null
      notification_title                            = "FinOps budget threshold"
    }
  } : {}

  monitoring_alarms = merge(local.default_budget_alarm, var.monitoring_alarms)

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      ManagedBy  = "Terraform"
      Blueprint  = local.blueprint_name
      CostOwner  = var.default_owner
      CostCenter = var.default_cost_center
    }
  )
}
