# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "event-driven-platform"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "events"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  stream_pool_name        = coalesce(var.stream_pool_name, "${local.name_prefix}-pool")
  stream_pool_id          = var.create_stream_pool ? try(oci_streaming_stream_pool.this[0].id, null) : var.stream_pool_id
  archive_bucket_name     = coalesce(var.archive_bucket_name, "${local.name_prefix}-archive")
  topic_name              = coalesce(var.topic_name, "${local.name_prefix}-topic")
  topic_id                = var.create_topic ? try(oci_ons_notification_topic.this[0].id, null) : var.topic_id
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
