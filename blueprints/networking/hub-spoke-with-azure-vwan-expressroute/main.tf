# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=v0.2.0"

  tenancy_ocid       = var.tenancy_ocid
  current_user_ocid  = var.current_user_ocid
  region             = var.region
  home_region        = var.home_region
  oci_config_profile = var.oci_config_profile
  compartment_ocid   = var.compartment_ocid
  org                = var.org
  environment        = var.environment
  region_key         = var.region_key
  defined_tags       = var.defined_tags
  freeform_tags      = var.freeform_tags

  hub_vcn_dns_label    = var.hub_vcn_dns_label
  hub_vcn_cidr_block   = var.hub_vcn_cidr_block
  hub_subnets          = var.hub_subnets
  spoke_vcns           = var.spoke_vcns
  spoke_route_tables   = var.spoke_route_tables
  spoke_security_lists = var.spoke_security_lists
}

module "fastconnect" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/fastconnect?ref=main"

  tenancy_ocid              = var.tenancy_ocid
  compartment_ocid          = local.target_compartment_ocid
  region                    = var.region
  org                       = var.org
  environment               = var.environment
  region_key                = var.region_key
  enable_fastconnect        = var.enable_fastconnect
  virtual_circuit_label     = "azure-vwan"
  drg_id                    = module.network.drg_id
  customer_bgp_asn          = var.customer_bgp_asn
  provider_service_id       = var.provider_service_id
  provider_service_key_name = var.provider_service_key_name
  cross_connect_mappings    = var.cross_connect_mappings
  defined_tags              = var.defined_tags
  freeform_tags             = var.freeform_tags
}

module "ipsec_vpn" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/ipsec-vpn?ref=v0.2.0"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = local.target_compartment_ocid
  region           = var.region
  org              = var.org
  environment      = var.environment
  region_key       = var.region_key
  enable_ipsec     = var.enable_ipsec
  vpn_label        = "azure-vwan"
  drg_id           = module.network.drg_id
  cpe_ip_address   = var.cpe_ip_address
  static_routes    = var.remote_cloud_cidr_blocks
  defined_tags     = var.defined_tags
  freeform_tags    = var.freeform_tags
}

resource "terraform_data" "azure_vwan_contract" {
  input = local.azure_vwan_contract

  lifecycle {
    precondition {
      condition = (
        !var.enable_route_contract_validation ||
        (
          var.expressroute_circuit_id != null &&
          var.expressroute_circuit_peering_id != null &&
          length(var.azure_vnet_peerings) > 0
        )
      )
      error_message = "Set expressroute_circuit_id, expressroute_circuit_peering_id, and at least one azure_vnet_peerings entry, or disable enable_route_contract_validation for early planning."
    }
  }
}
