# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    regex  = true
    values = ["All .* Services In Oracle Services Network"]
  }
}

resource "oci_core_vcn" "this" {
  cidr_blocks    = var.vcn_cidr_blocks
  compartment_id = var.compartment_ocid
  display_name   = local.vcn_name
  dns_label      = var.vcn_dns_label
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}

resource "oci_core_internet_gateway" "this" {
  count = var.enable_internet_gateway ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-igw-${var.vcn_label}"
  enabled        = true
  vcn_id         = oci_core_vcn.this.id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}

resource "oci_core_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-nat-${var.vcn_label}"
  vcn_id         = oci_core_vcn.this.id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}

resource "oci_core_service_gateway" "this" {
  count = var.enable_service_gateway ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-sgw-${var.vcn_label}"
  vcn_id         = oci_core_vcn.this.id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags

  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
}

resource "oci_core_security_list" "this" {
  for_each = var.security_lists

  compartment_id = var.compartment_ocid
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-sl-${var.vcn_label}-${each.key}")
  vcn_id         = oci_core_vcn.this.id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags

  dynamic "ingress_security_rules" {
    for_each = each.value.ingress_rules

    content {
      description = try(ingress_security_rules.value.description, null)
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = try(ingress_security_rules.value.source_type, null)
      stateless   = try(ingress_security_rules.value.stateless, false)

      dynamic "tcp_options" {
        for_each = try(ingress_security_rules.value.tcp_options, null) == null ? [] : [ingress_security_rules.value.tcp_options]

        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = try(ingress_security_rules.value.udp_options, null) == null ? [] : [ingress_security_rules.value.udp_options]

        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = try(ingress_security_rules.value.icmp_options, null) == null ? [] : [ingress_security_rules.value.icmp_options]

        content {
          type = icmp_options.value.type
          code = try(icmp_options.value.code, null)
        }
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = each.value.egress_rules

    content {
      description      = try(egress_security_rules.value.description, null)
      destination      = egress_security_rules.value.destination
      destination_type = try(egress_security_rules.value.destination_type, null)
      protocol         = egress_security_rules.value.protocol
      stateless        = try(egress_security_rules.value.stateless, false)

      dynamic "tcp_options" {
        for_each = try(egress_security_rules.value.tcp_options, null) == null ? [] : [egress_security_rules.value.tcp_options]

        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = try(egress_security_rules.value.udp_options, null) == null ? [] : [egress_security_rules.value.udp_options]

        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = try(egress_security_rules.value.icmp_options, null) == null ? [] : [egress_security_rules.value.icmp_options]

        content {
          type = icmp_options.value.type
          code = try(icmp_options.value.code, null)
        }
      }
    }
  }
}

resource "oci_core_route_table" "this" {
  for_each = var.route_tables

  compartment_id = var.compartment_ocid
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-rt-${var.vcn_label}-${each.key}")
  vcn_id         = oci_core_vcn.this.id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags

  dynamic "route_rules" {
    for_each = each.value.route_rules

    content {
      description       = try(route_rules.value.description, null)
      destination       = coalesce(try(route_rules.value.destination, null), try(local.route_destinations[route_rules.value.destination_key], null))
      destination_type  = try(route_rules.value.destination_type, "CIDR_BLOCK")
      network_entity_id = coalesce(try(route_rules.value.network_entity_id, null), try(local.route_entity_ids[route_rules.value.network_entity_key], null))
    }
  }
}

resource "oci_core_subnet" "this" {
  for_each = var.subnets

  cidr_block                 = each.value.cidr_block
  compartment_id             = var.compartment_ocid
  display_name               = coalesce(each.value.display_name, "${local.name_prefix}-sn-${var.vcn_label}-${each.key}")
  dns_label                  = each.value.dns_label
  prohibit_internet_ingress  = each.value.prohibit_internet_ingress
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic
  route_table_id             = oci_core_route_table.this[each.value.route_table_key].id
  security_list_ids          = [for key in each.value.security_list_keys : local.security_list_ids[key]]
  vcn_id                     = oci_core_vcn.this.id
  defined_tags               = var.defined_tags
  freeform_tags              = var.freeform_tags
}
