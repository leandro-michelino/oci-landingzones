# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_psql_db_system" "this" {
  count = var.enable_db_system ? 1 : 0

  compartment_id              = local.target_compartment_ocid
  display_name                = local.db_system_display_name
  description                 = var.description
  db_version                  = var.db_version
  shape                       = var.shape
  system_type                 = var.system_type
  config_id                   = var.config_id
  instance_count              = var.instance_count
  instance_ocpu_count         = var.instance_ocpu_count
  instance_memory_size_in_gbs = var.instance_memory_size_in_gbs
  defined_tags                = var.defined_tags
  freeform_tags               = local.common_freeform_tags

  credentials {
    username = var.admin_username

    password_details {
      password       = var.admin_password
      password_type  = var.admin_password_type
      secret_id      = var.admin_password_secret_id
      secret_version = var.admin_password_secret_version
    }
  }

  network_details {
    subnet_id                      = var.subnet_id
    nsg_ids                        = var.nsg_ids
    primary_db_endpoint_private_ip = var.primary_db_endpoint_private_ip
    is_reader_endpoint_enabled     = var.is_reader_endpoint_enabled
  }

  storage_details {
    system_type           = var.storage_system_type
    is_regionally_durable = var.is_regionally_durable
    availability_domain   = var.availability_domain
    iops                  = var.iops
  }

  dynamic "instances_details" {
    for_each = var.instances_details

    content {
      display_name = instances_details.value.display_name
      description  = instances_details.value.description
      private_ip   = instances_details.value.private_ip
    }
  }

  dynamic "management_policy" {
    for_each = var.enable_management_policy ? [1] : []

    content {
      maintenance_window_start = var.maintenance_window_start

      dynamic "backup_policy" {
        for_each = var.backup_policy == null ? [] : [var.backup_policy]

        content {
          backup_start      = backup_policy.value.backup_start
          days_of_the_month = backup_policy.value.days_of_the_month
          days_of_the_week  = backup_policy.value.days_of_the_week
          kind              = backup_policy.value.kind
          retention_days    = backup_policy.value.retention_days

          dynamic "copy_policy" {
            for_each = backup_policy.value.copy_policy == null ? [] : [backup_policy.value.copy_policy]

            content {
              compartment_id   = copy_policy.value.compartment_id
              regions          = copy_policy.value.regions
              retention_period = copy_policy.value.retention_period
            }
          }
        }
      }
    }
  }

  dynamic "source" {
    for_each = var.db_source == null ? [] : [var.db_source]

    content {
      source_type                        = source.value.source_type
      backup_id                          = source.value.backup_id
      is_having_restore_config_overrides = source.value.is_having_restore_config_overrides
    }
  }
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-postgresql-policy"
  description    = "Scoped PostgreSQL access for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
