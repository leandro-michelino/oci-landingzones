locals {
  blueprint_name          = "postgresql"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  db_system_display_name  = coalesce(var.db_system_display_name, "${local.name_prefix}-db")
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  vcn_display_name        = coalesce(var.vcn_display_name, "${local.name_prefix}-vcn-postgresql")
  subnet_display_name     = coalesce(var.subnet_display_name, "${local.name_prefix}-sn-postgresql")
  nsg_display_name        = coalesce(var.nsg_display_name, "${local.name_prefix}-nsg-postgresql")
  effective_subnet_id     = coalesce(var.subnet_id, try(oci_core_subnet.postgresql[0].id, null))
  effective_nsg_ids = length(var.nsg_ids) > 0 ? var.nsg_ids : (
    var.create_private_network ? toset([oci_core_network_security_group.postgresql[0].id]) : toset([])
  )
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
