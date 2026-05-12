# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "extensions-streaming"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  stream_pool_name        = coalesce(var.stream_pool_name, "${local.name_prefix}-streampool-platform")
  stream_pool_id          = var.stream_pool_id != null ? var.stream_pool_id : try(oci_streaming_stream_pool.this[0].id, null)
  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
    }
  )
}
