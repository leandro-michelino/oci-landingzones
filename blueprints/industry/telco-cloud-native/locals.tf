locals {
  blueprint_name          = "telco-cloud-native"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  defined_tags            = length(var.defined_tags) > 0 ? var.defined_tags : null

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
      Pattern   = "TelcoCloudNative"
    }
  )
}
