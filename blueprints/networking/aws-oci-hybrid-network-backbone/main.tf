# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_core_vcn" "backbone" {
  count = var.enable_oci_backbone_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cidr_block     = var.oci_backbone_vcn_cidr
  display_name   = local.backbone_vcn_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_internet_gateway" "backbone" {
  count = var.enable_oci_backbone_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.backbone[0].id
  display_name   = local.backbone_igw_name
  enabled        = true
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_route_table" "backbone" {
  count = var.enable_oci_backbone_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.backbone[0].id
  display_name   = local.backbone_rt_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.backbone[0].id
  }

  dynamic "route_rules" {
    for_each = var.enable_site_to_site_vpn ? var.aws_backbone_cidrs : []

    content {
      destination       = route_rules.value
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.primary.id
    }
  }
}

resource "oci_core_security_list" "backbone" {
  count = var.enable_oci_backbone_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.backbone[0].id
  display_name   = local.backbone_sl_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  ingress_security_rules {
    protocol = "6"
    source   = var.oci_backbone_ingress_allowed_cidr
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

resource "oci_core_subnet" "backbone" {
  count = var.enable_oci_backbone_network ? 1 : 0

  compartment_id             = local.target_compartment_ocid
  vcn_id                     = oci_core_vcn.backbone[0].id
  cidr_block                 = var.oci_backbone_subnet_cidr
  display_name               = local.backbone_subnet_name
  route_table_id             = oci_core_route_table.backbone[0].id
  security_list_ids          = [oci_core_security_list.backbone[0].id]
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

resource "oci_core_drg_attachment" "backbone" {
  count = var.enable_oci_backbone_network ? 1 : 0

  drg_id       = oci_core_drg.primary.id
  vcn_id       = oci_core_vcn.backbone[0].id
  display_name = local.drg_attach_name

  defined_tags  = var.defined_tags
  freeform_tags = local.common_freeform_tags
}

resource "oci_core_cpe" "aws" {
  count = var.enable_site_to_site_vpn ? 1 : 0

  compartment_id = local.target_compartment_ocid
  ip_address     = var.aws_cpe_public_ip
  display_name   = local.cpe_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_ipsec" "aws" {
  count = var.enable_site_to_site_vpn ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cpe_id         = oci_core_cpe.aws[0].id
  drg_id         = oci_core_drg.primary.id
  display_name   = local.ipsec_name
  static_routes  = var.aws_backbone_cidrs

  defined_tags  = var.defined_tags
  freeform_tags = local.common_freeform_tags
}

resource "oci_ons_notification_topic" "backbone_alert" {
  count = var.enable_backbone_alert_topic ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.alert_topic_name
  description    = "Hybrid backbone alerts for ${local.name_prefix}."
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "terraform_data" "oci_network_contract" {
  input = {
    enabled          = var.enable_oci_backbone_network
    vcn_id           = try(oci_core_vcn.backbone[0].id, null)
    subnet_id        = try(oci_core_subnet.backbone[0].id, null)
    route_table_id   = try(oci_core_route_table.backbone[0].id, null)
    security_list_id = try(oci_core_security_list.backbone[0].id, null)
  }
}

resource "terraform_data" "connectivity_contract" {
  input = local.connectivity_contract

  lifecycle {
    precondition {
      condition = (
        var.connectivity_mode == "interconnect" &&
        var.fastconnect_virtual_circuit_id != null &&
        var.direct_connect_connection_id != null
        ) || (
        var.connectivity_mode == "without-interconnect" &&
        var.fastconnect_virtual_circuit_id == null &&
        var.direct_connect_connection_id == null
      )
      error_message = "For connectivity_mode=interconnect, set fastconnect_virtual_circuit_id and direct_connect_connection_id. For connectivity_mode=without-interconnect, set both values to null."
    }

    precondition {
      condition     = !var.enable_site_to_site_vpn || var.aws_cpe_public_ip != null
      error_message = "When enable_site_to_site_vpn=true, set aws_cpe_public_ip."
    }
  }
}

resource "terraform_data" "routing_contract" {
  input = local.routing_contract
}
