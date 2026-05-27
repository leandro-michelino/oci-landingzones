locals {
  blueprint_name          = "hub-spoke-with-multicloud-interconnect"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
}
