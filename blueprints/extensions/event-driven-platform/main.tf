# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  count          = var.create_archive_bucket ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "archive" {
  count = var.create_archive_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = local.archive_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = "Standard"
  versioning            = var.archive_bucket_versioning
  object_events_enabled = true
  kms_key_id            = var.kms_key_id
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_streaming_stream_pool" "this" {
  count = var.create_stream_pool ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.stream_pool_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  dynamic "custom_encryption_key" {
    for_each = var.kms_key_id == null ? [] : [var.kms_key_id]

    content {
      kms_key_id = custom_encryption_key.value
    }
  }
}

resource "oci_streaming_stream" "this" {
  for_each = var.create_streams ? var.streams : {}

  compartment_id     = local.target_compartment_ocid
  name               = "${local.name_prefix}-${each.key}"
  partitions         = each.value.partitions
  retention_in_hours = each.value.retention_in_hours
  stream_pool_id     = local.stream_pool_id
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags
}

resource "oci_ons_notification_topic" "this" {
  count = var.create_topic ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.topic_name
  description    = var.topic_description
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_events_rule" "this" {
  for_each = var.create_event_rules ? var.event_rules : {}

  compartment_id = local.target_compartment_ocid
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-${each.key}")
  description    = coalesce(each.value.description, "Event-driven platform rule ${each.key}.")
  condition      = each.value.condition
  is_enabled     = coalesce(each.value.is_enabled, true)
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  actions {
    dynamic "actions" {
      for_each = each.value.actions

      content {
        action_type = actions.value.action_type
        function_id = actions.value.function_id
        stream_id   = coalesce(actions.value.stream_id, try(oci_streaming_stream.this[actions.value.stream_key].id, null))
        topic_id    = coalesce(actions.value.topic_id, local.topic_id)
        description = actions.value.description
        is_enabled  = coalesce(actions.value.is_enabled, true)
      }
    }
  }
}

resource "oci_sch_service_connector" "this" {
  count = var.create_service_connector ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = coalesce(var.connector_display_name, "${local.name_prefix}-connector")
  description    = "Event-driven platform connector for ${local.name_prefix}."
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  source {
    kind      = "streaming"
    stream_id = coalesce(var.connector_source_stream_id, try(oci_streaming_stream.this[var.connector_source_stream_key].id, null))
  }

  target {
    kind               = var.connector_target_kind
    namespace          = coalesce(var.connector_target_namespace, try(data.oci_objectstorage_namespace.this[0].namespace, null))
    bucket             = coalesce(var.connector_target_bucket, local.archive_bucket_name)
    object_name_prefix = var.connector_object_prefix
    function_id        = var.connector_target_function_id
    stream_id          = var.connector_target_stream_id
    topic_id           = coalesce(var.connector_target_topic_id, local.topic_id)
  }
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-access"
  description    = "Event-driven platform access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
