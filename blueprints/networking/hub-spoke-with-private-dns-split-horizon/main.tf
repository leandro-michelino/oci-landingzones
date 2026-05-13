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

module "private_dns" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/dns?ref=v0.2.0"

  tenancy_ocid                         = var.tenancy_ocid
  compartment_ocid                     = local.target_compartment_ocid
  region                               = var.region
  org                                  = var.org
  environment                          = var.environment
  region_key                           = var.region_key
  enable_private_dns                   = var.enable_private_dns
  dns_label                            = var.dns_label
  private_zones                        = var.private_zones
  vcn_ids                              = merge({ hub = module.network.hub_vcn_id }, module.network.spoke_vcn_ids)
  attach_private_view_to_vcn_resolvers = var.attach_private_view_to_vcn_resolvers
  defined_tags                         = var.defined_tags
  freeform_tags                        = var.freeform_tags
}
