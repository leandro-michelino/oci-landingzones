# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "private-data-platform"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  data_bucket_name        = coalesce(var.data_bucket_name, "${local.name_prefix}-bkt-data-platform")
  private_endpoint_name   = coalesce(var.private_endpoint_name, "${local.name_prefix}-pe-os")

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
      Pattern   = "PrivateDataPlatform"
    }
  )
}
