# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "operations-monitoring"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

  default_topics = var.enable_monitoring && var.enable_default_topic ? {
    default = {
      name             = "${local.name_prefix}-topic-monitoring"
      description      = "Landing zone monitoring notifications managed by Terraform."
      compartment_ocid = var.compartment_ocid
    }
  } : {}

  notification_topics = var.enable_monitoring ? merge(local.default_topics, var.notification_topics) : {}
  subscriptions       = var.enable_monitoring ? var.subscriptions : {}
  alarms              = var.enable_monitoring ? var.alarms : {}

  alarm_destinations = {
    for key, alarm in local.alarms : key => distinct(concat(
      tolist(alarm.destinations),
      [
        for topic_key in alarm.destination_topic_keys : oci_ons_notification_topic.this[topic_key].id
      ]
    ))
  }

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Module = local.module_name
    }
  )
}
