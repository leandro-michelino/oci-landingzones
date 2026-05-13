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
}

module "ipsec_vpn" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/ipsec-vpn?ref=v0.2.0"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  region           = var.region
  org              = var.org
  environment      = var.environment
  region_key       = var.region_key
  enable_ipsec     = var.enable_ipsec
  vpn_label        = var.vpn_label
  drg_id           = module.network.drg_id
  cpe_ip_address   = var.cpe_ip_address
  cpe_is_private   = var.cpe_is_private
  static_routes    = var.on_premises_cidr_blocks
  defined_tags     = var.defined_tags
  freeform_tags    = var.freeform_tags
}
