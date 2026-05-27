locals {
  blueprint_name          = "mongodb-api"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })

  database_display_name = coalesce(var.database_display_name, "${local.name_prefix}-adb-mongodb")
  vcn_display_name      = coalesce(var.vcn_display_name, "${local.name_prefix}-vcn-mongodb-api")
  subnet_display_name   = coalesce(var.subnet_display_name, "${local.name_prefix}-sn-mongodb-api")
  nsg_display_name      = coalesce(var.nsg_display_name, "${local.name_prefix}-nsg-mongodb-api")
  effective_subnet_id   = coalesce(var.subnet_id, try(oci_core_subnet.mongodb_api[0].id, null))
  effective_nsg_ids     = length(var.nsg_ids) > 0 ? tolist(var.nsg_ids) : try([oci_core_network_security_group.mongodb_api[0].id], [])
  effective_private_endpoint_label = coalesce(
    var.private_endpoint_label,
    var.create_private_network ? "mongoapi" : null
  )
  public_access_control_enabled = var.enable_public_access_control && length(var.whitelisted_ips) > 0
}
