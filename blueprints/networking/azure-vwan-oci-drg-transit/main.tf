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

  dynamic "route_rules" {
    for_each = var.azure_network_cidrs

    content {
      destination       = route_rules.value
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.primary.id
    }
  }
}

resource "oci_core_security_list" "primary_hub" {
  count = var.enable_oci_primary_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.primary[0].id
  display_name   = local.primary_sl_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  ingress_security_rules {
    protocol = "6"
    source   = var.oci_primary_ingress_allowed_cidr
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

resource "oci_core_subnet" "primary_hub" {
  count = var.enable_oci_primary_network ? 1 : 0

  cidr_block                 = var.oci_primary_hub_subnet_cidr
  compartment_id             = local.target_compartment_ocid
  vcn_id                     = oci_core_vcn.primary[0].id
  display_name               = local.primary_subnet_name
  route_table_id             = oci_core_route_table.primary[0].id
  security_list_ids          = [oci_core_security_list.primary_hub[0].id]
  prohibit_public_ip_on_vnic = false
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "oci_core_drg" "primary" {
  compartment_id = local.target_compartment_ocid
  display_name   = local.drg_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_drg_attachment" "primary" {
  count = var.enable_oci_primary_network ? 1 : 0

  drg_id       = oci_core_drg.primary.id
  vcn_id       = oci_core_vcn.primary[0].id
  display_name = local.drg_attachment_name

  defined_tags  = var.defined_tags
  freeform_tags = local.common_freeform_tags
}

resource "oci_core_cpe" "azure" {
  count = var.enable_ipsec_fallback ? 1 : 0

  compartment_id = local.target_compartment_ocid
  ip_address     = var.azure_cpe_public_ip
  display_name   = local.cpe_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_ipsec" "azure" {
  count = var.enable_ipsec_fallback ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cpe_id         = oci_core_cpe.azure[0].id
  drg_id         = oci_core_drg.primary.id
  display_name   = local.ipsec_name
  static_routes  = var.azure_network_cidrs

  defined_tags  = var.defined_tags
  freeform_tags = local.common_freeform_tags
}

resource "oci_ons_notification_topic" "transit_alert" {
  count = var.enable_transit_alert_topic ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.transit_topic_name
  description    = "Azure vWAN and OCI DRG transit alerts for ${local.name_prefix}."
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "terraform_data" "oci_network_contract" {
  input = {
    enabled          = var.enable_oci_primary_network
    vcn_id           = try(oci_core_vcn.primary[0].id, null)
    subnet_id        = try(oci_core_subnet.primary_hub[0].id, null)
    route_table_id   = try(oci_core_route_table.primary[0].id, null)
    security_list_id = try(oci_core_security_list.primary_hub[0].id, null)
    drg_id           = oci_core_drg.primary.id
  }
}

resource "terraform_data" "interconnect_contract" {
  input = local.interconnect_contract

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

    precondition {
      condition = (
        var.azure_virtual_wan_id != null &&
        var.azure_virtual_hub_id != null
      ) || var.connectivity_mode == "without-interconnect"
      error_message = "Set azure_virtual_wan_id and azure_virtual_hub_id for interconnect mode, or switch to without-interconnect."
    }

    precondition {
      condition     = !var.enable_ipsec_fallback || var.azure_cpe_public_ip != null
      error_message = "When enable_ipsec_fallback=true, set azure_cpe_public_ip."
    }
  }
}

resource "terraform_data" "ipsec_fallback_contract" {
  input = local.ipsec_fallback_contract
}

resource "terraform_data" "transit_contract" {
  input = local.transit_contract
}

resource "terraform_data" "dns_contract" {
  count = var.enable_dns_contract ? 1 : 0

  input = local.dns_contract

  lifecycle {
    precondition {
      condition = (
        trimspace(var.private_dns_zone_fqdn) != "" &&
        trimspace(var.health_probe_fqdn) != ""
      )
      error_message = "When enable_dns_contract=true, set private_dns_zone_fqdn and health_probe_fqdn."
    }
  }
}

resource "terraform_data" "runbook_contract" {
  input = local.runbook_contract
}
