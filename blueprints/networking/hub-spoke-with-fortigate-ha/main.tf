module "network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=v0.2.0"

  tenancy_ocid         = var.tenancy_ocid
  current_user_ocid    = var.current_user_ocid
  region               = var.region
  home_region          = var.home_region
  oci_config_profile   = var.oci_config_profile
  compartment_ocid     = local.target_compartment_ocid
  org                  = var.org
  environment          = var.environment
  region_key           = var.region_key
  hub_vcn_dns_label    = var.hub_vcn_dns_label
  hub_vcn_cidr_block   = var.hub_vcn_cidr_block
  hub_subnets          = var.hub_subnets
  spoke_vcns           = var.spoke_vcns
  spoke_route_tables   = var.spoke_route_tables
  spoke_security_lists = var.spoke_security_lists
  defined_tags         = var.defined_tags
  freeform_tags        = var.freeform_tags
}

resource "terraform_data" "fortigate_input_validation" {
  input = var.enable_fortigate_ha

  lifecycle {
    precondition {
      condition     = !var.enable_fortigate_ha || length(var.fortigate_nodes) == 2
      error_message = "When enable_fortigate_ha is true, fortigate_nodes must contain exactly two nodes."
    }

    precondition {
      condition = !var.enable_fortigate_ha || var.fortigate_image_id != null || alltrue([
        for node in values(var.fortigate_nodes) : try(node.image_id, null) != null
      ])
      error_message = "When enable_fortigate_ha is true, set fortigate_image_id or set image_id on both FortiGate nodes."
    }

    precondition {
      condition = alltrue(flatten([
        for interfaces in values(local.fortigate_node_interfaces) : [
          for interface in values(interfaces) : contains(keys(var.hub_subnets), interface.subnet_key)
        ]
      ]))
      error_message = "Every FortiGate interface subnet_key must exist in hub_subnets."
    }

    precondition {
      condition = alltrue([
        for floating_ip in values(var.fortigate_floating_ips) : contains(keys(var.hub_subnets), floating_ip.subnet_key)
      ])
      error_message = "Every FortiGate floating IP subnet_key must exist in hub_subnets."
    }

    precondition {
      condition = alltrue([
        for floating_ip in values(var.fortigate_floating_ips) :
        try(floating_ip.active_node_key, null) == null || contains(keys(var.fortigate_nodes), floating_ip.active_node_key)
      ])
      error_message = "Every FortiGate floating IP active_node_key must exist in fortigate_nodes."
    }

    precondition {
      condition = alltrue([
        for floating_ip in values(var.fortigate_floating_ips) :
        try(floating_ip.active_node_key, null) == null || contains(["untrust", "trust", "ha_sync"], coalesce(try(floating_ip.interface_name, null), ""))
      ])
      error_message = "A FortiGate floating IP with active_node_key must set interface_name to untrust, trust, or ha_sync."
    }
  }
}

resource "oci_core_instance" "fortigate" {
  for_each = var.enable_fortigate_ha ? var.fortigate_nodes : {}

  availability_domain = each.value.availability_domain
  compartment_id      = local.target_compartment_ocid
  display_name        = coalesce(try(each.value.display_name, null), "${local.name_prefix}-nva-fortigate-${each.key}")
  shape               = try(each.value.shape, "VM.Standard.E4.Flex")
  defined_tags        = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
      Role      = "fortigate-ha-node"
      HA        = each.key
    }
  )

  create_vnic_details {
    assign_public_ip       = try(local.fortigate_node_interfaces[each.key].mgmt.assign_public_ip, false)
    display_name           = "${local.name_prefix}-vnic-nva-${each.key}-mgmt"
    hostname_label         = try(local.fortigate_node_interfaces[each.key].mgmt.hostname_label, null)
    nsg_ids                = try(local.fortigate_node_interfaces[each.key].mgmt.nsg_ids, [])
    private_ip             = try(local.fortigate_node_interfaces[each.key].mgmt.private_ip, null)
    skip_source_dest_check = try(local.fortigate_node_interfaces[each.key].mgmt.skip_source_dest_check, true)
    subnet_id              = module.network.hub_subnet_ids[local.fortigate_node_interfaces[each.key].mgmt.subnet_key]
  }

  shape_config {
    memory_in_gbs = try(each.value.memory_in_gbs, 16)
    ocpus         = try(each.value.ocpus, 4)
  }

  source_details {
    source_id   = coalesce(try(each.value.image_id, null), var.fortigate_image_id)
    source_type = "image"
  }

  metadata = try(each.value.bootstrap_user_data, null) == null ? {} : {
    user_data = each.value.bootstrap_user_data
  }

  lifecycle {
    precondition {
      condition     = coalesce(try(each.value.image_id, null), var.fortigate_image_id) != null
      error_message = "Each FortiGate node requires image_id, or fortigate_image_id must be set."
    }
  }
}

resource "oci_core_vnic_attachment" "fortigate_interface" {
  for_each = var.enable_fortigate_ha ? local.fortigate_secondary_interfaces : {}

  instance_id  = oci_core_instance.fortigate[each.value.node_key].id
  display_name = "${local.name_prefix}-vnic-nva-${each.value.node_key}-${each.value.interface_name}"

  create_vnic_details {
    assign_public_ip       = try(each.value.assign_public_ip, false)
    display_name           = "${local.name_prefix}-vnic-nva-${each.value.node_key}-${each.value.interface_name}"
    hostname_label         = try(each.value.hostname_label, null)
    nsg_ids                = try(each.value.nsg_ids, [])
    private_ip             = try(each.value.private_ip, null)
    skip_source_dest_check = try(each.value.skip_source_dest_check, true)
    subnet_id              = module.network.hub_subnet_ids[each.value.subnet_key]
  }
}

resource "oci_core_private_ip" "fortigate_floating" {
  for_each = var.enable_fortigate_floating_ips ? var.fortigate_floating_ips : {}

  subnet_id = try(each.value.active_node_key, null) == null ? module.network.hub_subnet_ids[each.value.subnet_key] : null
  vnic_id = try(each.value.active_node_key, null) == null ? null : oci_core_vnic_attachment.fortigate_interface[
    "${each.value.active_node_key}-${each.value.interface_name}"
  ].vnic_id
  display_name   = coalesce(try(each.value.display_name, null), "${local.name_prefix}-ip-fortigate-float-${each.key}")
  hostname_label = try(each.value.hostname_label, null)
  ip_address     = try(each.value.ip_address, null)
  defined_tags   = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
      Role      = "fortigate-floating-private-ip"
    }
  )

  lifecycle {
    ignore_changes = [vnic_id]
  }
}

resource "oci_identity_dynamic_group" "fortigate" {
  count = var.enable_fortigate_ha && var.enable_fortigate_instance_principal_policy ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = local.fortigate_dynamic_group_name
  description    = "FortiGate HA nodes allowed to manage OCI private IP failover in ${local.name_prefix}."
  matching_rule  = "Any {${join(", ", local.fortigate_instance_matching_rules)}}"
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}

resource "oci_identity_policy" "fortigate" {
  count = var.enable_fortigate_ha && var.enable_fortigate_instance_principal_policy ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = local.fortigate_policy_name
  description    = "OCI API permissions for FortiGate HA SDN connector failover automation."
  statements     = local.fortigate_instance_principal_policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags

  depends_on = [oci_identity_dynamic_group.fortigate]
}
