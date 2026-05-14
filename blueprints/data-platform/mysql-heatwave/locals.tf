# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "mysql-heatwave"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "mysql-hw"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  db_system_display_name  = coalesce(var.db_system_display_name, "${local.name_prefix}-db")
  lakehouse_bucket_name   = coalesce(var.lakehouse_bucket_name, "${local.name_prefix}-lakehouse")
  db_system_id            = var.create_db_system ? try(oci_mysql_mysql_db_system.this[0].id, null) : var.db_system_id
  heatwave_cluster_id     = var.create_heatwave_cluster ? try(oci_mysql_heat_wave_cluster.this[0].id, null) : var.heatwave_cluster_id

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
