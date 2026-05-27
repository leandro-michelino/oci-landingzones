locals {
  blueprint_name          = "networking-hub-spoke-with-fortigate-ha"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)

  fortigate_interface_names = ["mgmt", "untrust", "trust", "ha_sync"]

  fortigate_node_interfaces = {
    for node_key, node in var.fortigate_nodes : node_key => {
      for interface_name in local.fortigate_interface_names : interface_name => {
        subnet_key             = coalesce(try(node.interfaces[interface_name].subnet_key, null), lookup(var.fortigate_interface_subnet_keys, interface_name, interface_name))
        private_ip             = try(node.interfaces[interface_name].private_ip, null)
        hostname_label         = coalesce(try(node.interfaces[interface_name].hostname_label, null), lower(replace("${substr(node_key, 0, 8)}${substr(interface_name, 0, 5)}", "_", "")))
        assign_public_ip       = coalesce(try(node.interfaces[interface_name].assign_public_ip, null), false)
        nsg_ids                = coalesce(try(node.interfaces[interface_name].nsg_ids, null), [])
        skip_source_dest_check = coalesce(try(node.interfaces[interface_name].skip_source_dest_check, null), true)
      }
    }
  }

  fortigate_secondary_interfaces = merge(
    {},
    [
      for node_key, interfaces in local.fortigate_node_interfaces : {
        for interface_name, interface in interfaces : "${node_key}-${interface_name}" => merge(interface, {
          node_key       = node_key
          interface_name = interface_name
        })
        if interface_name != "mgmt"
      }
    ]...
  )

  fortigate_dynamic_group_name = coalesce(var.fortigate_dynamic_group_name, "${local.name_prefix}-dgrp-fortigate-ha")
  fortigate_policy_name        = coalesce(var.fortigate_policy_name, "${local.name_prefix}-pol-fortigate-ha")

  fortigate_instance_matching_rules = [
    for instance in values(oci_core_instance.fortigate) : "instance.id = '${instance.id}'"
  ]

  fortigate_instance_principal_policy_statements = concat(
    [
      "Allow dynamic-group ${local.fortigate_dynamic_group_name} to read compartments in tenancy",
      "Allow dynamic-group ${local.fortigate_dynamic_group_name} to read instances in tenancy",
      "Allow dynamic-group ${local.fortigate_dynamic_group_name} to read vnic-attachments in tenancy",
      "Allow dynamic-group ${local.fortigate_dynamic_group_name} to read private-ips in tenancy",
      "Allow dynamic-group ${local.fortigate_dynamic_group_name} to read public-ips in tenancy",
      "Allow dynamic-group ${local.fortigate_dynamic_group_name} to manage private-ips in tenancy",
      "Allow dynamic-group ${local.fortigate_dynamic_group_name} to manage public-ips in tenancy",
      "Allow dynamic-group ${local.fortigate_dynamic_group_name} to manage vnics in tenancy"
    ],
    var.additional_fortigate_policy_statements
  )
}
