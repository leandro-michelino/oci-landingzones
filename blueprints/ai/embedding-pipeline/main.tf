# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  count          = var.create_buckets ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "this" {
  for_each = var.create_buckets ? local.bucket_names : {}

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = each.value
  access_type           = "NoPublicAccess"
  storage_tier          = var.bucket_storage_tier
  versioning            = var.bucket_versioning
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
  name               = "${local.name_prefix}-stream-${each.key}"
  partitions         = each.value.partitions
  retention_in_hours = each.value.retention_in_hours
  stream_pool_id     = local.stream_pool_id
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags
}

resource "oci_events_rule" "source" {
  count = var.create_event_rule ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.event_rule_name
  description    = "Invoke embedding chunking function for new source objects."
  condition      = var.event_rule_condition
  is_enabled     = true
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  actions {
    actions {
      action_type = "FAAS"
      function_id = var.chunking_function_id
      description = "Embedding chunking function."
      is_enabled  = true
    }
  }
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-access"
  description    = "Embedding pipeline access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
