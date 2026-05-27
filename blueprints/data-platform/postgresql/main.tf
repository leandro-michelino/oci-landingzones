resource "oci_core_vcn" "postgresql" {
  count = var.create_private_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cidr_block     = var.vcn_cidr_block
  display_name   = local.vcn_display_name
  dns_label      = var.vcn_dns_label
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_subnet" "postgresql" {
  count = var.create_private_network ? 1 : 0

  compartment_id             = local.target_compartment_ocid
  vcn_id                     = oci_core_vcn.postgresql[0].id
  cidr_block                 = var.subnet_cidr_block
  display_name               = local.subnet_display_name
  dns_label                  = var.subnet_dns_label
  prohibit_public_ip_on_vnic = true
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "oci_core_network_security_group" "postgresql" {
  count = var.create_private_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.postgresql[0].id
  display_name   = local.nsg_display_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_network_security_group_security_rule" "postgresql_ingress" {
  #checkov:skip=CKV_OCI_21:Database ingress is intentionally stateful so return traffic stays tied to approved client CIDRs without broad ephemeral egress.
  for_each = var.create_private_network ? toset(var.allowed_client_cidrs) : []

  network_security_group_id = oci_core_network_security_group.postgresql[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.postgresql_port
      max = var.postgresql_port
    }
  }
}

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
    subnet_id                      = local.effective_subnet_id
    nsg_ids                        = local.effective_nsg_ids
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
          days_of_the_month = length(backup_policy.value.days_of_the_month) > 0 ? backup_policy.value.days_of_the_month : null
          days_of_the_week  = length(backup_policy.value.days_of_the_week) > 0 ? backup_policy.value.days_of_the_week : null
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
  name           = "${local.name_prefix}-pol-postgresql"
  description    = "Scoped PostgreSQL access for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

data "oci_psql_db_system_connection_detail" "this" {
  count = var.enable_db_system ? 1 : 0

  db_system_id = oci_psql_db_system.this[0].id
}
