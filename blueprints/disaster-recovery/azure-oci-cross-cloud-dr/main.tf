# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_core_vcn" "primary" {
  count = var.enable_oci_primary_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cidr_block     = var.oci_primary_vcn_cidr
  display_name   = local.primary_vcn_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_internet_gateway" "primary" {
  count = var.enable_oci_primary_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.primary[0].id
  display_name   = local.primary_igw_name
  enabled        = true
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_route_table" "primary" {
  count = var.enable_oci_primary_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.primary[0].id
  display_name   = local.primary_rt_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.primary[0].id
  }
}

resource "oci_core_security_list" "primary_app" {
  count = var.enable_oci_primary_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.primary[0].id
  display_name   = local.primary_sl_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.oci_primary_ingress_allowed_cidr
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.oci_primary_ingress_allowed_cidr
    tcp_options {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_subnet" "primary_app" {
  count = var.enable_oci_primary_network ? 1 : 0

  cidr_block        = var.oci_primary_app_subnet_cidr
  compartment_id    = local.target_compartment_ocid
  vcn_id            = oci_core_vcn.primary[0].id
  display_name      = local.primary_subnet_name
  route_table_id    = oci_core_route_table.primary[0].id
  security_list_ids = [oci_core_security_list.primary_app[0].id]

  prohibit_public_ip_on_vnic = false
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "terraform_data" "oci_network_contract" {
  input = {
    enabled       = var.enable_oci_primary_network
    vcn_id        = try(oci_core_vcn.primary[0].id, null)
    app_subnet_id = try(oci_core_subnet.primary_app[0].id, null)
  }
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = local.target_compartment_ocid
}

resource "oci_objectstorage_bucket" "dr_evidence" {
  count = var.enable_dr_evidence_bucket ? 1 : 0

  compartment_id = local.target_compartment_ocid
  namespace      = data.oci_objectstorage_namespace.this.namespace
  name           = local.evidence_bucket_name

  storage_tier = "Standard"
  versioning   = "Enabled"

  defined_tags  = var.defined_tags
  freeform_tags = local.common_freeform_tags
}

resource "oci_ons_notification_topic" "dr_alert" {
  count = var.enable_dr_alert_topic ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.alert_topic_name
  description    = var.dr_alert_topic_description

  defined_tags  = var.defined_tags
  freeform_tags = local.common_freeform_tags
}

resource "terraform_data" "connectivity_contract" {
  input = local.effective_interconnect

  lifecycle {
    precondition {
      condition = (
        var.connectivity_mode == "interconnect" &&
        var.fastconnect_virtual_circuit_id != null &&
        var.expressroute_circuit_id != null
        ) || (
        var.connectivity_mode == "without-interconnect" &&
        var.fastconnect_virtual_circuit_id == null &&
        var.expressroute_circuit_id == null
      )
      error_message = "For connectivity_mode=interconnect, set both fastconnect_virtual_circuit_id and expressroute_circuit_id. For connectivity_mode=without-interconnect, keep both values null."
    }
  }
}

resource "terraform_data" "dns_failover_contract" {
  count = var.enable_dns_failover_contract ? 1 : 0

  input = local.dns_failover_contract

  lifecycle {
    precondition {
      condition = (
        var.oci_primary_endpoint != null &&
        var.azure_standby_endpoint != null &&
        trimspace(var.app_fqdn) != ""
      )
      error_message = "When enable_dns_failover_contract=true, set app_fqdn, oci_primary_endpoint, and azure_standby_endpoint."
    }
  }
}

resource "terraform_data" "runbook_contract" {
  count = var.enable_runbook_contract ? 1 : 0

  input = local.runbook_contract
}
