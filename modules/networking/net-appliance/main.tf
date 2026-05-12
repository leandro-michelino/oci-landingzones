# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_core_instance" "appliance" {
  for_each = var.enable_net_appliance ? var.appliances : {}

  availability_domain = each.value.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${local.name_prefix}-nva-${each.key}"
  shape               = try(each.value.shape, "VM.Standard.E4.Flex")
  defined_tags        = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.module_name
      Role      = "network-appliance"
    }
  )

  create_vnic_details {
    assign_public_ip       = try(each.value.assign_public_ip, false)
    display_name           = "${local.name_prefix}-vnic-nva-${each.key}"
    hostname_label         = try(each.value.hostname_label, each.key)
    nsg_ids                = try(each.value.nsg_ids, [])
    private_ip             = try(each.value.private_ip, null)
    skip_source_dest_check = true
    subnet_id              = each.value.subnet_id
  }

  shape_config {
    memory_in_gbs = try(each.value.memory_in_gbs, 8)
    ocpus         = try(each.value.ocpus, 1)
  }

  source_details {
    source_id   = each.value.image_id
    source_type = "image"
  }

  metadata = try(each.value.user_data, null) == null ? {} : {
    user_data = each.value.user_data
  }
}

resource "oci_core_private_ip" "route_target" {
  for_each = var.enable_reserved_route_ips ? var.reserved_route_ips : {}

  subnet_id      = each.value.subnet_id
  display_name   = coalesce(try(each.value.display_name, null), "${local.name_prefix}-nva-route-ip-${each.key}")
  hostname_label = try(each.value.hostname_label, null)
  ip_address     = try(each.value.ip_address, null)
  route_table_id = try(each.value.route_table_id, null)
  defined_tags   = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.module_name
      Role      = "nva-route-target"
    }
  )
}
