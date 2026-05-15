# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "embedding-pipeline"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  bucket_names = {
    source = coalesce(var.source_bucket_name, "${local.name_prefix}-bkt-source")
    state  = coalesce(var.state_bucket_name, "${local.name_prefix}-bkt-state")
    failed = coalesce(var.failed_bucket_name, "${local.name_prefix}-bkt-failed")
  }
  stream_pool_name = coalesce(var.stream_pool_name, "${local.name_prefix}-pool")
  stream_pool_id   = var.create_stream_pool ? try(oci_streaming_stream_pool.this[0].id, null) : var.stream_pool_id
  event_rule_name  = coalesce(var.event_rule_display_name, "${local.name_prefix}-evt-object")
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
