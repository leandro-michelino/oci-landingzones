# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  count          = var.create_report_bucket ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "reports" {
  count = var.create_report_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = local.report_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = var.report_bucket_storage_tier
  versioning            = var.report_bucket_versioning
  object_events_enabled = true
  kms_key_id            = var.kms_key_id
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_ons_notification_topic" "this" {
  count = var.create_topic ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = coalesce(var.topic_name, "${local.name_prefix}-topic")
  description    = var.topic_description
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_cloud_guard_target" "this" {
  count = var.create_cloud_guard_target ? 1 : 0

  compartment_id       = local.target_compartment_ocid
  display_name         = coalesce(var.cloud_guard_target_display_name, "${local.name_prefix}-target")
  description          = var.cloud_guard_target_description
  target_resource_id   = coalesce(var.cloud_guard_target_resource_id, local.target_compartment_ocid)
  target_resource_type = var.cloud_guard_target_resource_type
  defined_tags         = var.defined_tags
  freeform_tags        = local.common_freeform_tags

  dynamic "target_detector_recipes" {
    for_each = var.detector_recipe_ids

    content {
      detector_recipe_id = target_detector_recipes.value
    }
  }

  dynamic "target_responder_recipes" {
    for_each = var.responder_recipe_ids

    content {
      responder_recipe_id = target_responder_recipes.value
    }
  }
}

resource "oci_vulnerability_scanning_host_scan_recipe" "this" {
  count = var.create_host_scan_recipe ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = coalesce(var.host_scan_recipe_display_name, "${local.name_prefix}-host-recipe")
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  agent_settings {
    scan_level = var.host_agent_scan_level

    dynamic "agent_configuration" {
      for_each = var.host_agent_vendor == null ? [] : [1]

      content {
        vendor          = var.host_agent_vendor
        vendor_type     = var.host_agent_vendor_type
        vault_secret_id = var.host_agent_vault_secret_id
      }
    }
  }

  port_settings {
    scan_level = var.host_port_scan_level
  }

  schedule {
    type        = var.host_scan_schedule_type
    day_of_week = var.host_scan_day_of_week
  }
}

resource "oci_vulnerability_scanning_host_scan_target" "this" {
  count = var.create_host_scan_target ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  display_name          = coalesce(var.host_scan_target_display_name, "${local.name_prefix}-host-target")
  description           = var.host_scan_target_description
  host_scan_recipe_id   = local.host_scan_recipe_id
  target_compartment_id = coalesce(var.host_scan_target_compartment_id, local.target_compartment_ocid)
  instance_ids          = var.host_scan_instance_ids
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_events_rule" "this" {
  for_each = var.event_rules

  compartment_id = local.target_compartment_ocid
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-${each.key}")
  description    = each.value.description
  condition      = each.value.condition
  is_enabled     = each.value.is_enabled
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  actions {
    dynamic "actions" {
      for_each = each.value.actions

      content {
        action_type = actions.value.action_type
        is_enabled  = actions.value.is_enabled
        description = actions.value.description
        topic_id    = coalesce(actions.value.topic_id, local.topic_id)
        function_id = actions.value.function_id
        stream_id   = actions.value.stream_id
      }
    }
  }
}

resource "oci_monitoring_alarm" "this" {
  for_each = var.alarms

  compartment_id        = local.target_compartment_ocid
  display_name          = coalesce(each.value.display_name, "${local.name_prefix}-${each.key}")
  namespace             = each.value.namespace
  query                 = each.value.query
  severity              = each.value.severity
  destinations          = each.value.destinations
  metric_compartment_id = coalesce(each.value.metric_compartment_id, local.target_compartment_ocid)
  body                  = each.value.body
  is_enabled            = each.value.is_enabled
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-access"
  description    = "Security posture automation access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
