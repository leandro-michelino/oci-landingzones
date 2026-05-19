# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_core_vcn" "primary" {
  count = var.enable_oci_primary_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cidr_block     = var.oci_primary_vcn_cidr
  display_name   = local.db_vcn_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_internet_gateway" "primary" {
  count = var.enable_oci_primary_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.primary[0].id
  display_name   = local.db_igw_name
  enabled        = true
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_drg" "primary" {
  count = var.enable_ipsec_connectivity ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.drg_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_route_table" "primary_db" {
  count = var.enable_oci_primary_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.primary[0].id
  display_name   = local.db_route_table_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.primary[0].id
  }

  dynamic "route_rules" {
    for_each = var.enable_ipsec_connectivity ? [var.aws_replication_cidr] : []
    content {
      destination       = route_rules.value
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.primary[0].id
    }
  }
}

resource "oci_core_security_list" "primary_db" {
  count = var.enable_oci_primary_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.primary[0].id
  display_name   = local.db_security_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.oci_app_ingress_allowed_cidr
    tcp_options {
      min = 3306
      max = 3306
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.aws_replication_cidr
    tcp_options {
      min = 3306
      max = 3306
    }
  }
}

resource "oci_core_subnet" "primary_db" {
  count = var.enable_oci_primary_network ? 1 : 0

  cidr_block                 = var.oci_primary_db_subnet_cidr
  compartment_id             = local.target_compartment_ocid
  vcn_id                     = oci_core_vcn.primary[0].id
  display_name               = local.db_subnet_name
  route_table_id             = oci_core_route_table.primary_db[0].id
  security_list_ids          = [oci_core_security_list.primary_db[0].id]
  prohibit_public_ip_on_vnic = true
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "oci_core_drg_attachment" "primary_db" {
  count = var.enable_oci_primary_network && var.enable_ipsec_connectivity ? 1 : 0

  drg_id         = oci_core_drg.primary[0].id
  vcn_id         = oci_core_vcn.primary[0].id
  display_name   = local.drg_attachment_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
  route_table_id = oci_core_route_table.primary_db[0].id
}

resource "oci_core_cpe" "aws" {
  count = var.enable_ipsec_connectivity ? 1 : 0

  compartment_id      = local.target_compartment_ocid
  ip_address          = var.aws_cpe_public_ip
  cpe_device_shape_id = "CPE"
  display_name        = local.cpe_name
  defined_tags        = var.defined_tags
  freeform_tags       = local.common_freeform_tags
}

resource "oci_core_ipsec" "aws" {
  count = var.enable_ipsec_connectivity ? 1 : 0

  compartment_id            = local.target_compartment_ocid
  cpe_id                    = oci_core_cpe.aws[0].id
  drg_id                    = oci_core_drg.primary[0].id
  static_routes             = [var.aws_replication_cidr]
  display_name              = local.ipsec_name
  cpe_local_identifier      = tostring(var.aws_bgp_asn)
  cpe_local_identifier_type = "ASN"
  defined_tags              = var.defined_tags
  freeform_tags             = local.common_freeform_tags
}

data "oci_objectstorage_namespace" "this" {
  count          = var.create_lakehouse_bucket ? 1 : 0
  compartment_id = local.target_compartment_ocid
}

resource "oci_objectstorage_bucket" "lakehouse" {
  count = var.create_lakehouse_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = local.lakehouse_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = "Standard"
  versioning            = "Enabled"
  object_events_enabled = true
  kms_key_id            = var.kms_key_id
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_mysql_mysql_db_system" "primary" {
  count = var.create_db_system ? 1 : 0

  compartment_id          = local.target_compartment_ocid
  display_name            = local.db_system_display_name
  description             = "OCI primary MySQL HeatWave DB System for cross-cloud DR."
  availability_domain     = var.availability_domain
  fault_domain            = var.fault_domain
  shape_name              = var.db_shape_name
  subnet_id               = local.db_subnet_id_effective
  mysql_version           = var.mysql_version
  admin_username          = var.admin_username
  admin_password          = var.admin_password
  data_storage_size_in_gb = var.data_storage_size_in_gb
  is_highly_available     = var.is_highly_available
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
      condition     = local.db_subnet_id_effective != null
      error_message = "When create_db_system=true, enable_oci_primary_network must be true so the DB subnet is available."
    }
    precondition {
      condition     = var.admin_username != null && var.admin_password != null
      error_message = "When create_db_system=true, set admin_username and admin_password."
    }
  }
}

resource "oci_mysql_heat_wave_cluster" "primary" {
  count = var.create_heatwave_cluster ? 1 : 0

  db_system_id         = local.db_system_id_effective
  shape_name           = var.heatwave_shape_name
  cluster_size         = var.heatwave_cluster_size
  is_lakehouse_enabled = var.enable_heatwave_lakehouse

  lifecycle {
    precondition {
      condition     = local.db_system_id_effective != null
      error_message = "When create_heatwave_cluster=true, a valid DB System must exist (create_db_system=true or existing_db_system_id set)."
    }
  }
}

resource "oci_ons_notification_topic" "dr_alert" {
  count = var.enable_dr_alert_topic ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.alert_topic_name
  description    = "MySQL HeatWave cross-cloud DR alert topic"
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "terraform_data" "oci_network_contract" {
  input = local.oci_network_contract
}

resource "terraform_data" "connectivity_contract" {
  input = local.connectivity_contract

  lifecycle {
    precondition {
      condition = (
        var.enable_ipsec_connectivity == false && var.aws_cpe_public_ip == null
        ) || (
        var.enable_ipsec_connectivity == true && var.aws_cpe_public_ip != null
      )
      error_message = "When enable_ipsec_connectivity=true, set aws_cpe_public_ip. When false, keep aws_cpe_public_ip null."
    }
  }
}

resource "terraform_data" "replication_contract" {
  input = local.replication_contract

  lifecycle {
    precondition {
      condition     = var.oci_primary_endpoint != null && var.aws_secondary_endpoint != null
      error_message = "Set oci_primary_endpoint and aws_secondary_endpoint to publish replication contract output."
    }
  }
}

resource "terraform_data" "dns_failover_contract" {
  input = local.dns_failover_contract

  lifecycle {
    precondition {
      condition     = trimspace(var.primary_dns_name) != "" && var.oci_primary_endpoint != null && var.aws_secondary_endpoint != null
      error_message = "Set primary_dns_name, oci_primary_endpoint, and aws_secondary_endpoint for DNS failover contract output."
    }
  }
}

resource "terraform_data" "runbook_contract" {
  input = local.runbook_contract
}
