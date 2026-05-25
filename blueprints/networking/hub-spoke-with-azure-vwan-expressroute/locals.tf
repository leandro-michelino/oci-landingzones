# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "hub-spoke-with-azure-vwan-expressroute"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)

  oci_spoke_cidr_blocks = { for key, spoke in var.spoke_vcns : key => spoke.cidr_block }
  oci_advertised_cidr_blocks = distinct(concat(
    [var.hub_vcn_cidr_block],
    values(local.oci_spoke_cidr_blocks)
  ))
  azure_advertised_cidr_blocks = distinct(flatten([
    for _, peering in var.azure_vnet_peerings : peering.cidr_blocks
  ]))

  spoke_vnet_peering_matrix = flatten([
    for vnet_key, peering in var.azure_vnet_peerings : [
      for spoke_key in peering.connected_spoke_keys : {
        azure_vnet_key   = vnet_key
        azure_vnet_id    = peering.vnet_id
        azure_cidrs      = peering.cidr_blocks
        oci_spoke_key    = spoke_key
        oci_spoke_vcn_id = try(module.network.spoke_vcn_ids[spoke_key], null)
        oci_spoke_cidr   = try(local.oci_spoke_cidr_blocks[spoke_key], null)
      }
    ]
  ])

  azure_vwan_contract = {
    pattern = "oci-hub-spoke-to-azure-virtual-wan"
    azure = {
      virtual_wan_id             = var.azure_virtual_wan_id
      virtual_hub_id             = var.azure_virtual_hub_id
      expressroute_gateway_id    = var.azure_expressroute_gateway_id
      expressroute_circuit_id    = var.expressroute_circuit_id
      expressroute_peering_id    = var.expressroute_circuit_peering_id
      virtual_hub_region         = var.azure_virtual_hub_region
      virtual_hub_address_prefix = var.azure_virtual_hub_address_prefix
      route_table_name           = var.azure_route_table_name
      vnet_peerings              = var.azure_vnet_peerings
      advertised_cidr_blocks     = local.azure_advertised_cidr_blocks
    }
    oci = {
      hub_vcn_id                     = module.network.hub_vcn_id
      hub_vcn_cidr_block             = var.hub_vcn_cidr_block
      drg_id                         = module.network.drg_id
      fastconnect_virtual_circuit_id = module.fastconnect.virtual_circuit_id
      ipsec_id                       = module.ipsec_vpn.ipsec_id
      spoke_vcn_ids                  = module.network.spoke_vcn_ids
      spoke_cidr_blocks              = local.oci_spoke_cidr_blocks
      advertised_cidr_blocks         = local.oci_advertised_cidr_blocks
    }
    route_exchange = {
      primary_path           = "azure-vwan-expressroute-gateway-to-oci-fastconnect"
      backup_path            = var.enable_ipsec ? "ipsec" : "none"
      route_exchange_model   = "bgp"
      oci_advertised_cidrs   = local.oci_advertised_cidr_blocks
      azure_advertised_cidrs = local.azure_advertised_cidr_blocks
      azure_route_table_name = var.azure_route_table_name
    }
    peering_matrix = local.spoke_vnet_peering_matrix
  }
}
