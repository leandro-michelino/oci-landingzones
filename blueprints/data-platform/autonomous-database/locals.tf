locals {
  blueprint_name          = "autonomous-database"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
  database_display_name = coalesce(var.database_display_name, "${local.name_prefix}-adb")
  vcn_display_name      = coalesce(var.vcn_display_name, "${local.name_prefix}-vcn-adb")
  subnet_display_name   = coalesce(var.subnet_display_name, "${local.name_prefix}-sn-adb")
  nsg_display_name      = coalesce(var.nsg_display_name, "${local.name_prefix}-nsg-adb")
  effective_subnet_id   = coalesce(var.subnet_id, try(oci_core_subnet.adb[0].id, null))
  effective_nsg_ids     = length(var.nsg_ids) > 0 ? var.nsg_ids : (var.create_private_network ? toset([oci_core_network_security_group.adb[0].id]) : toset([]))
  effective_private_endpoint_label = coalesce(
    var.private_endpoint_label,
    var.create_private_network ? "adb" : null
  )
}
