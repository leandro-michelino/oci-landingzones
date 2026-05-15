# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "autonomous-database"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
  database_display_name = coalesce(var.database_display_name, "${local.name_prefix}-adb")
}
