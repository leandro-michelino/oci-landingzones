# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_database_autonomous_database" "this" {
  count = var.enable_autonomous_database ? 1 : 0

  compartment_id                  = local.target_compartment_ocid
  db_name                         = var.db_name
  display_name                    = local.database_display_name
  admin_password                  = var.admin_password
  db_workload                     = var.db_workload
  compute_model                   = var.compute_model
  compute_count                   = var.compute_count
  data_storage_size_in_tbs        = var.data_storage_size_in_tbs
  is_auto_scaling_enabled         = var.is_auto_scaling_enabled
  is_mtls_connection_required     = var.is_mtls_connection_required
  is_free_tier                    = var.is_free_tier
  license_model                   = var.license_model
  subnet_id                       = var.subnet_id
  nsg_ids                         = var.nsg_ids
  private_endpoint_label          = var.private_endpoint_label
  kms_key_id                      = var.kms_key_id
  backup_retention_period_in_days = var.backup_retention_period_in_days
  defined_tags                    = var.defined_tags
  freeform_tags                   = local.common_freeform_tags
}

resource "oci_database_autonomous_database_backup" "manual" {
  count = var.enable_autonomous_database && var.create_manual_backup ? 1 : 0

  autonomous_database_id   = oci_database_autonomous_database.this[0].id
  display_name             = "${local.database_display_name}-backup"
  is_long_term_backup      = var.manual_backup_is_long_term
  retention_period_in_days = var.manual_backup_retention_period_in_days
}
