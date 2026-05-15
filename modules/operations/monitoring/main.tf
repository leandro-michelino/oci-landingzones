# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_ons_notification_topic" "this" {
  for_each = local.notification_topics

  compartment_id = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  name           = coalesce(each.value.name, "${local.name_prefix}-top-monitoring-${each.key}")
  description    = coalesce(each.value.description, "Landing zone monitoring topic ${each.key} managed by Terraform.")
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_ons_subscription" "this" {
  for_each = local.subscriptions

  compartment_id  = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  topic_id        = each.value.topic_id != null ? each.value.topic_id : oci_ons_notification_topic.this[each.value.topic_key].id
  protocol        = upper(each.value.protocol)
  endpoint        = each.value.endpoint
  delivery_policy = each.value.delivery_policy
  defined_tags    = var.defined_tags
  freeform_tags   = local.common_freeform_tags
}

resource "oci_monitoring_alarm" "this" {
  for_each = local.alarms

  compartment_id                                = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  metric_compartment_id                         = coalesce(each.value.metric_compartment_ocid, var.compartment_ocid)
  metric_compartment_id_in_subtree              = each.value.metric_compartment_id_in_subtree
  display_name                                  = coalesce(each.value.display_name, "${local.name_prefix}-alm-${each.key}")
  body                                          = coalesce(each.value.body, "Landing zone monitoring alarm ${each.key}.")
  destinations                                  = local.alarm_destinations[each.key]
  namespace                                     = each.value.namespace
  query                                         = each.value.query
  severity                                      = upper(each.value.severity)
  is_enabled                                    = each.value.is_enabled
  pending_duration                              = each.value.pending_duration
  resolution                                    = each.value.resolution
  resource_group                                = each.value.resource_group
  message_format                                = each.value.message_format
  repeat_notification_duration                  = each.value.repeat_notification_duration
  evaluation_slack_duration                     = each.value.evaluation_slack_duration
  is_notifications_per_metric_dimension_enabled = each.value.is_notifications_per_metric_dimension_enabled
  notification_title                            = each.value.notification_title
  defined_tags                                  = var.defined_tags
  freeform_tags                                 = local.common_freeform_tags
}
