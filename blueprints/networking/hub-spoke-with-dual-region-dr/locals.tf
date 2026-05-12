# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name             = "networking-hub-spoke-with-dual-region-dr"
  name_prefix                = "${var.org}-${var.environment}-${var.region_key}"
  secondary_name_prefix      = "${var.org}-${var.environment}-${var.secondary_region_key}"
  primary_compartment_ocid   = coalesce(var.compartment_ocid, var.tenancy_ocid)
  secondary_compartment_ocid = coalesce(var.secondary_compartment_ocid, local.primary_compartment_ocid)
}
