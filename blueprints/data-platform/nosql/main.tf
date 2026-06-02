resource "oci_core_vcn" "app" {
  count = var.enable_app_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cidr_block     = var.app_vcn_cidr
  display_name   = local.app_vcn_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_internet_gateway" "app" {
  count = var.enable_app_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.app[0].id
  display_name   = local.app_igw_name
  enabled        = true
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_route_table" "app" {
  count = var.enable_app_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.app[0].id
  display_name   = local.app_rt_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.app[0].id
  }
}

resource "oci_core_security_list" "app" {
  count = var.enable_app_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.app[0].id
  display_name   = local.app_sl_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  ingress_security_rules {
    protocol = "6"
    source   = var.app_ingress_allowed_cidr
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "app" {
  count = var.enable_app_network ? 1 : 0

  compartment_id             = local.target_compartment_ocid
  vcn_id                     = oci_core_vcn.app[0].id
  cidr_block                 = var.app_subnet_cidr
  display_name               = local.app_subnet_name
  route_table_id             = oci_core_route_table.app[0].id
  security_list_ids          = [oci_core_security_list.app[0].id]
  prohibit_public_ip_on_vnic = false
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "terraform_data" "app_network_contract" {
  input = {
    enabled          = var.enable_app_network
    vcn_id           = try(oci_core_vcn.app[0].id, null)
    subnet_id        = try(oci_core_subnet.app[0].id, null)
    route_table_id   = try(oci_core_route_table.app[0].id, null)
    security_list_id = try(oci_core_security_list.app[0].id, null)
  }
}

resource "oci_nosql_table" "this" {
  compartment_id = local.target_compartment_ocid
  name           = local.nosql_table_name
  ddl_statement  = local.nosql_table_ddl
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  table_limits {
    max_read_units     = var.table_max_read_units
    max_write_units    = var.table_max_write_units
    max_storage_in_gbs = var.table_max_storage_in_gbs
    capacity_mode      = var.table_capacity_mode
  }
}

resource "oci_nosql_index" "secondary" {
  count = var.create_secondary_index ? 1 : 0

  name             = local.nosql_index_name
  table_name_or_id = oci_nosql_table.this.id

  dynamic "keys" {
    for_each = var.secondary_index_columns

    content {
      column_name = keys.value.column_name
    }
  }

  lifecycle {
    precondition {
      condition     = length(var.secondary_index_columns) > 0
      error_message = "secondary_index_columns must include at least one column when create_secondary_index=true."
    }
  }
}

resource "oci_nosql_table_replica" "this" {
  count = var.enable_table_replica ? 1 : 0

  table_name_or_id = oci_nosql_table.this.id
  region           = var.replica_region
  max_read_units   = var.replica_max_read_units
  max_write_units  = var.replica_max_write_units

  lifecycle {
    precondition {
      condition     = var.replica_region != null
      error_message = "replica_region is required when enable_table_replica=true."
    }
  }
}

resource "oci_ons_notification_topic" "alert" {
  count = var.create_alert_topic ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.alert_topic_name
  description    = "NoSQL table alerts and operations topic for ${local.name_prefix}."
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-nosql-access"
  description    = "NoSQL access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "terraform_data" "nosql_contract" {
  input = {
    table_id        = oci_nosql_table.this.id
    table_name      = oci_nosql_table.this.name
    secondary_index = var.create_secondary_index ? try(oci_nosql_index.secondary[0].name, null) : null
    replica_region  = var.enable_table_replica ? var.replica_region : null
    capacity = {
      mode           = var.table_capacity_mode
      max_read       = var.table_max_read_units
      max_write      = var.table_max_write_units
      max_storage_gb = var.table_max_storage_in_gbs
    }
  }
}
