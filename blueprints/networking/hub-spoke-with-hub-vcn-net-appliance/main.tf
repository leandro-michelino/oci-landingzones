# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "network" {
  source = "../hub-spoke-with-drg-and-three-tier-vcns"

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

module "net_appliance" {
  source = "../../../modules/networking/net-appliance"

  tenancy_ocid                         = var.tenancy_ocid
  compartment_ocid                     = local.target_compartment_ocid
  region                               = var.region
  org                                  = var.org
  environment                          = var.environment
  region_key                           = var.region_key
  enable_net_appliance                 = var.enable_net_appliance
  enable_reserved_route_ips            = var.enable_reserved_route_ips
  appliances                           = var.appliances
  reserved_route_ips                   = var.reserved_route_ips
  existing_route_target_private_ip_ids = var.existing_route_target_private_ip_ids
  defined_tags                         = var.defined_tags
  freeform_tags                        = var.freeform_tags
}
