# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_core_vcn" "oda" {
  count = var.enable_oda_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cidr_block     = var.oda_vcn_cidr
  display_name   = local.oda_vcn_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_internet_gateway" "oda" {
  count = var.enable_oda_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.oda[0].id
  display_name   = local.oda_igw_name
  enabled        = true
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_route_table" "oda" {
  count = var.enable_oda_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.oda[0].id
  display_name   = local.oda_rt_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oda[0].id
  }
}

resource "oci_core_security_list" "oda" {
  count = var.enable_oda_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.oda[0].id
  display_name   = local.oda_sl_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  ingress_security_rules {
    protocol = "6"
    source   = var.oda_ingress_allowed_cidr
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination      = var.oda_egress_allowed_cidr
    destination_type = "CIDR_BLOCK"

    tcp_options {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_subnet" "oda" {
  count = var.enable_oda_network ? 1 : 0

  compartment_id             = local.target_compartment_ocid
  vcn_id                     = oci_core_vcn.oda[0].id
  cidr_block                 = var.oda_subnet_cidr
  display_name               = local.oda_subnet_name
  route_table_id             = oci_core_route_table.oda[0].id
  security_list_ids          = [oci_core_security_list.oda[0].id]
  prohibit_public_ip_on_vnic = false
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "oci_core_network_security_group" "oda" {
  count = var.enable_oda_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.oda[0].id
  display_name   = local.oda_nsg_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_network_security_group_security_rule" "oda_ingress_https" {
  count = var.enable_oda_network ? 1 : 0

  network_security_group_id = oci_core_network_security_group.oda[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.oda_ingress_allowed_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  description               = "Allow HTTPS ingress to ODA private endpoint NSG."

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "oda_egress_all" {
  count = var.enable_oda_network ? 1 : 0

  network_security_group_id = oci_core_network_security_group.oda[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = var.oda_egress_allowed_cidr
  destination_type          = "CIDR_BLOCK"
  description               = "Allow HTTPS egress from ODA private endpoint NSG."

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "terraform_data" "oda_network_contract" {
  input = {
    enabled        = var.enable_oda_network
    vcn_id         = try(oci_core_vcn.oda[0].id, null)
    subnet_id      = try(oci_core_subnet.oda[0].id, null)
    nsg_id         = try(oci_core_network_security_group.oda[0].id, null)
    route_table_id = try(oci_core_route_table.oda[0].id, null)
  }
}

resource "oci_oda_oda_instance" "this" {
  count = var.create_oda_instance ? 1 : 0

  compartment_id       = local.target_compartment_ocid
  shape_name           = var.oda_shape_name
  display_name         = local.oda_display_name
  description          = var.oda_description
  identity_domain      = var.oda_identity_domain
  is_role_based_access = var.oda_is_role_based_access
  defined_tags         = var.defined_tags
  freeform_tags        = local.common_freeform_tags
}

resource "oci_oda_oda_private_endpoint" "this" {
  count = var.create_oda_private_endpoint ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.oda_private_endpoint_name
  description    = var.oda_private_endpoint_description
  subnet_id      = local.oda_private_endpoint_subnet_id_effective
  nsg_ids        = local.oda_private_endpoint_nsg_ids_effective
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  lifecycle {
    precondition {
      condition     = local.oda_private_endpoint_subnet_id_effective != null
      error_message = "ODA private endpoint requires subnet_id from enable_oda_network=true or oda_private_endpoint_subnet_id."
    }
    precondition {
      condition     = length(local.oda_private_endpoint_nsg_ids_effective) > 0
      error_message = "ODA private endpoint requires at least one NSG ID."
    }
  }
}

resource "oci_oda_oda_private_endpoint_attachment" "this" {
  count = var.attach_private_endpoint_to_instance ? 1 : 0

  oda_instance_id         = local.oda_instance_id_effective
  oda_private_endpoint_id = local.oda_private_endpoint_id_effective

  lifecycle {
    precondition {
      condition     = local.oda_instance_id_effective != null
      error_message = "ODA private endpoint attachment requires an ODA instance via create_oda_instance=true or oda_instance_id."
    }
    precondition {
      condition     = local.oda_private_endpoint_id_effective != null
      error_message = "ODA private endpoint attachment requires a private endpoint via create_oda_private_endpoint=true or oda_private_endpoint_id."
    }
  }
}

resource "oci_ons_notification_topic" "alert" {
  count = var.create_alert_topic ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.alert_topic_name
  description    = "ODA operations and channel integration alerts for ${local.name_prefix}."
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-oda-access"
  description    = "ODA access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "terraform_data" "oda_contract" {
  input = {
    oda_instance_id             = local.oda_instance_id_effective
    oda_private_endpoint_id     = local.oda_private_endpoint_id_effective
    oda_private_endpoint_subnet = local.oda_private_endpoint_subnet_id_effective
    role_based_access           = var.oda_is_role_based_access
    shape_name                  = var.oda_shape_name
  }
}
