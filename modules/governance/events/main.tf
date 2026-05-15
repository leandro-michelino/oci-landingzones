# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_ons_notification_topic" "this" {
  for_each = local.notification_topics

  compartment_id = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  name           = coalesce(each.value.name, "${local.name_prefix}-top-${each.key}")
  description    = coalesce(each.value.description, "Landing zone notification topic ${each.key} managed by Terraform.")
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_ons_subscription" "this" {
  for_each = local.subscriptions

  compartment_id  = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  topic_id        = each.value.topic_id != null ? each.value.topic_id : try(oci_ons_notification_topic.this[each.value.topic_key].id, null)
  protocol        = upper(each.value.protocol)
  endpoint        = each.value.endpoint
  delivery_policy = each.value.delivery_policy
  defined_tags    = var.defined_tags
  freeform_tags   = local.common_freeform_tags
}

resource "oci_events_rule" "this" {
  for_each = local.event_rules

  compartment_id = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-evt-${each.key}")
  description    = coalesce(each.value.description, "Landing zone event rule ${each.key} managed by Terraform.")
  condition      = each.value.condition
  is_enabled     = each.value.is_enabled
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  actions {
    dynamic "actions" {
      for_each = each.value.actions

      content {
        action_type = upper(actions.value.action_type)
        description = actions.value.description
        function_id = actions.value.function_id
        is_enabled  = actions.value.is_enabled
        stream_id   = actions.value.stream_id
        topic_id    = upper(actions.value.action_type) == "ONS" ? (actions.value.topic_id != null ? actions.value.topic_id : try(oci_ons_notification_topic.this[actions.value.topic_key].id, null)) : null
      }
    }
  }
}
