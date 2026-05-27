locals {
  blueprint_name          = "mysql-heatwave"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  db_system_display_name  = coalesce(var.db_system_display_name, "${local.name_prefix}-db")
  lakehouse_bucket_name   = coalesce(var.lakehouse_bucket_name, "${local.name_prefix}-bkt-lakehouse")
  vcn_display_name        = coalesce(var.vcn_display_name, "${local.name_prefix}-vcn-mysql")
  subnet_display_name     = coalesce(var.subnet_display_name, "${local.name_prefix}-sn-mysql")
  nsg_display_name        = coalesce(var.nsg_display_name, "${local.name_prefix}-nsg-mysql")
  effective_subnet_id     = coalesce(var.subnet_id, try(oci_core_subnet.mysql[0].id, null))
  effective_nsg_ids       = length(var.nsg_ids) > 0 ? var.nsg_ids : (var.create_private_network ? toset([oci_core_network_security_group.mysql[0].id]) : toset([]))
  db_system_id            = var.create_db_system ? try(oci_mysql_mysql_db_system.this[0].id, null) : var.db_system_id
  heatwave_cluster_id     = var.create_heatwave_cluster ? try(oci_mysql_heat_wave_cluster.this[0].id, null) : var.heatwave_cluster_id

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
