# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  count          = var.create_lakehouse_bucket ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "lakehouse" {
  count = var.create_lakehouse_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = local.lakehouse_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = var.lakehouse_bucket_storage_tier
  versioning            = var.lakehouse_bucket_versioning
  object_events_enabled = true
  kms_key_id            = var.kms_key_id
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_mysql_mysql_db_system" "this" {
  count = var.create_db_system ? 1 : 0

  compartment_id          = local.target_compartment_ocid
  display_name            = local.db_system_display_name
  description             = var.db_system_description
  availability_domain     = var.availability_domain
  fault_domain            = var.fault_domain
  shape_name              = var.db_shape_name
  subnet_id               = var.subnet_id
  nsg_ids                 = var.nsg_ids
  hostname_label          = var.hostname_label
  mysql_version           = var.mysql_version
  admin_username          = var.admin_username
  admin_password          = var.admin_password
  data_storage_size_in_gb = var.data_storage_size_in_gb
  is_highly_available     = var.is_highly_available
  configuration_id        = var.configuration_id
  defined_tags            = var.defined_tags
  freeform_tags           = local.common_freeform_tags

  backup_policy {
    is_enabled        = var.backup_enabled
    retention_in_days = var.backup_retention_in_days
    window_start_time = var.backup_window_start_time
    defined_tags      = var.defined_tags
    freeform_tags     = local.common_freeform_tags
  }

  dynamic "encrypt_data" {
    for_each = var.kms_key_id == null ? [] : [var.kms_key_id]

    content {
      key_generation_type = "CUSTOMER"
      key_id              = encrypt_data.value
    }
  }
}

resource "oci_mysql_heat_wave_cluster" "this" {
  count = var.create_heatwave_cluster ? 1 : 0

  db_system_id         = local.db_system_id
  shape_name           = var.heatwave_shape_name
  cluster_size         = var.heatwave_cluster_size
  is_lakehouse_enabled = var.enable_heatwave_lakehouse
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-access"
  description    = "MySQL HeatWave access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
