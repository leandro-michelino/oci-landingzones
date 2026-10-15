# Last successful validation: 2026-10-15 | Terraform init/validate and 5 mocked plans | oracle/oci 9.9.0.
# Scope: local schema and plan assertions; live test covered only private OCI networking, not MySQL, HeatWave, or backups.
# Evidence: blueprints/data-platform/mysql-heatwave/tests/configuration-regressions.tftest.hcl.
# Last successful reduced lifecycle: 2026-10-15 | DEFAULT, sa-saopaulo-1 | OCI network-only apply, no-drift plan, destroy, API/state cleanup | oracle/oci 9.9.0.
# Live evidence: docs/DATA-DEVOPS-DR-REVIEW-20261015.md; private logs in .leo-local/data-devops-dr-20261015/.
data "oci_objectstorage_namespace" "this" {
  count          = var.create_lakehouse_bucket ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_core_vcn" "mysql" {
  count = var.create_private_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cidr_block     = var.vcn_cidr_block
  display_name   = local.vcn_display_name
  dns_label      = var.vcn_dns_label
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_subnet" "mysql" {
  count = var.create_private_network ? 1 : 0

  compartment_id             = local.target_compartment_ocid
  vcn_id                     = oci_core_vcn.mysql[0].id
  cidr_block                 = var.subnet_cidr_block
  display_name               = local.subnet_display_name
  dns_label                  = var.subnet_dns_label
  security_list_ids          = [oci_core_security_list.mysql[0].id]
  prohibit_public_ip_on_vnic = true
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "oci_core_security_list" "mysql" {
  #checkov:skip=CKV_OCI_16:An explicitly empty list removes the VCN default SSH/ICMP rules; the DB endpoint uses CIDR-scoped NSG ingress instead.
  count = var.create_private_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.mysql[0].id
  display_name   = "${local.name_prefix}-sl-mysql-empty"
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_network_security_group" "mysql" {
  count = var.create_private_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.mysql[0].id
  display_name   = local.nsg_display_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_network_security_group_security_rule" "mysql_ingress" {
  #checkov:skip=CKV_OCI_21:Database ingress is intentionally stateful so return traffic stays tied to approved client CIDRs without broad ephemeral egress.
  for_each = var.create_private_network ? toset(var.allowed_client_cidrs) : []

  network_security_group_id = oci_core_network_security_group.mysql[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 3306
      max = 3306
    }
  }
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
  subnet_id               = local.effective_subnet_id
  nsg_ids                 = local.effective_nsg_ids
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

  lifecycle {
    precondition {
      condition     = local.effective_subnet_id != null
      error_message = "When create_db_system=true, set subnet_id or enable create_private_network."
    }
    precondition {
      condition     = var.admin_username != null && var.admin_password != null
      error_message = "When create_db_system=true, set admin_username and admin_password securely."
    }
  }
}

resource "oci_mysql_heat_wave_cluster" "this" {
  count = var.create_heatwave_cluster ? 1 : 0

  db_system_id         = local.db_system_id
  shape_name           = var.heatwave_shape_name
  cluster_size         = var.heatwave_cluster_size
  is_lakehouse_enabled = var.enable_heatwave_lakehouse

  lifecycle {
    precondition {
      condition     = local.db_system_id != null
      error_message = "When create_heatwave_cluster=true, create a DB System or set db_system_id."
    }
  }
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-access"
  description    = "MySQL HeatWave access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
