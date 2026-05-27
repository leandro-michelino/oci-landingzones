resource "oci_core_vcn" "mongodb_api" {
  count = var.create_private_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cidr_block     = var.vcn_cidr_block
  display_name   = local.vcn_display_name
  dns_label      = var.vcn_dns_label
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_subnet" "mongodb_api" {
  count = var.create_private_network ? 1 : 0

  compartment_id             = local.target_compartment_ocid
  vcn_id                     = oci_core_vcn.mongodb_api[0].id
  cidr_block                 = var.subnet_cidr_block
  display_name               = local.subnet_display_name
  dns_label                  = var.subnet_dns_label
  prohibit_public_ip_on_vnic = true
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "oci_core_network_security_group" "mongodb_api" {
  count = var.create_private_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.mongodb_api[0].id
  display_name   = local.nsg_display_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_network_security_group_security_rule" "mongodb_api_ingress" {
  for_each = var.create_private_network ? toset(var.allowed_client_cidrs) : []

  network_security_group_id = oci_core_network_security_group.mongodb_api[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.mongodb_api_port
      max = var.mongodb_api_port
    }
  }
}

resource "oci_database_autonomous_database" "this" {
  count = var.enable_mongodb_api_database ? 1 : 0

  compartment_id                      = local.target_compartment_ocid
  db_name                             = var.db_name
  display_name                        = local.database_display_name
  admin_password                      = var.admin_password
  db_workload                         = var.db_workload
  compute_model                       = var.compute_model
  compute_count                       = var.compute_count
  data_storage_size_in_tbs            = var.data_storage_size_in_tbs
  is_auto_scaling_enabled             = var.is_auto_scaling_enabled
  is_auto_scaling_for_storage_enabled = var.is_auto_scaling_for_storage_enabled
  is_mtls_connection_required         = var.is_mtls_connection_required
  is_free_tier                        = var.is_free_tier
  license_model                       = var.license_model
  subnet_id                           = local.effective_subnet_id
  nsg_ids                             = local.effective_nsg_ids
  private_endpoint_label              = local.effective_private_endpoint_label
  kms_key_id                          = var.kms_key_id
  backup_retention_period_in_days     = var.backup_retention_period_in_days
  whitelisted_ips                     = local.public_access_control_enabled ? var.whitelisted_ips : null
  is_access_control_enabled           = local.public_access_control_enabled ? true : null
  defined_tags                        = var.defined_tags
  freeform_tags                       = local.common_freeform_tags

  db_tools_details {
    name                     = var.mongodb_api_tool_name
    is_enabled               = var.enable_mongodb_api
    compute_count            = var.mongodb_api_compute_count
    max_idle_time_in_minutes = var.mongodb_api_max_idle_time_in_minutes
  }
}

resource "oci_database_autonomous_database_backup" "manual" {
  count = var.enable_mongodb_api_database && var.create_manual_backup ? 1 : 0

  autonomous_database_id   = oci_database_autonomous_database.this[0].id
  display_name             = "${local.database_display_name}-backup"
  is_long_term_backup      = var.manual_backup_is_long_term
  retention_period_in_days = var.manual_backup_retention_period_in_days
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-mongodb-api-access"
  description    = "Autonomous Database MongoDB API access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
