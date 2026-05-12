# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_streaming_stream_pool" "this" {
  count = var.enable_streaming && var.create_stream_pool ? 1 : 0

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

  dynamic "private_endpoint_settings" {
    for_each = var.private_endpoint_subnet_id == null ? [] : [var.private_endpoint_subnet_id]

    content {
      subnet_id = private_endpoint_settings.value
      nsg_ids   = var.private_endpoint_nsg_ids
    }
  }

  dynamic "kafka_settings" {
    for_each = var.kafka_settings == null ? [] : [var.kafka_settings]

    content {
      auto_create_topics_enable = try(kafka_settings.value.auto_create_topics_enable, null)
      log_retention_hours       = try(kafka_settings.value.log_retention_hours, null)
      num_partitions            = try(kafka_settings.value.num_partitions, null)
    }
  }
}

resource "oci_streaming_stream" "this" {
  for_each = var.enable_streaming ? var.streams : {}

  compartment_id     = local.target_compartment_ocid
  name               = "${local.name_prefix}-stream-${each.key}"
  partitions         = each.value.partitions
  retention_in_hours = try(each.value.retention_in_hours, null)
  stream_pool_id     = local.stream_pool_id
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags
}
