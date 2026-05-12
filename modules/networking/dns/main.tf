# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_dns_view" "private" {
  count = var.enable_private_dns ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-dns-view-${var.dns_label}"
  scope          = "PRIVATE"
  defined_tags   = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.module_name
    }
  )
}

resource "oci_dns_zone" "private" {
  for_each = var.enable_private_dns ? var.private_zones : {}

  compartment_id = var.compartment_ocid
  name           = each.value.name
  scope          = try(each.value.scope, "PRIVATE")
  view_id        = oci_dns_view.private[0].id
  zone_type      = try(each.value.zone_type, "PRIMARY")
  defined_tags   = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.module_name
    },
    try(each.value.description, null) == null ? {} : { Description = each.value.description }
  )
}

data "oci_core_vcn_dns_resolver_association" "this" {
  for_each = var.enable_private_dns && var.attach_private_view_to_vcn_resolvers ? var.vcn_ids : {}

  vcn_id = each.value
}

resource "oci_dns_resolver" "vcn" {
  for_each = data.oci_core_vcn_dns_resolver_association.this

  resolver_id = each.value.dns_resolver_id

  attached_views {
    view_id = oci_dns_view.private[0].id
  }

  dynamic "rules" {
    for_each = var.resolver_rules

    content {
      action                    = rules.value.action
      source_endpoint_name      = rules.value.source_endpoint_name
      destination_addresses     = rules.value.destination_addresses
      client_address_conditions = try(rules.value.client_address_conditions, [])
      qname_cover_conditions    = try(rules.value.qname_cover_conditions, [])
    }
  }
}

resource "oci_dns_resolver_endpoint" "this" {
  for_each = var.enable_resolver_endpoints ? var.resolver_endpoints : {}

  is_forwarding      = each.value.is_forwarding
  is_listening       = each.value.is_listening
  name               = each.key
  resolver_id        = coalesce(try(each.value.resolver_id, null), try(data.oci_core_vcn_dns_resolver_association.this[each.value.vcn_key].dns_resolver_id, null))
  subnet_id          = each.value.subnet_id
  endpoint_type      = try(each.value.endpoint_type, "VNIC")
  forwarding_address = try(each.value.forwarding_address, null)
  listening_address  = try(each.value.listening_address, null)
  nsg_ids            = try(each.value.nsg_ids, [])
}
