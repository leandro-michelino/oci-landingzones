# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=v0.1.0"

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

module "bastion" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/security/bastion?ref=v0.1.0"

  tenancy_ocid                 = var.tenancy_ocid
  compartment_ocid             = local.target_compartment_ocid
  region                       = var.region
  org                          = var.org
  environment                  = var.environment
  region_key                   = var.region_key
  enable_bastion               = var.enable_bastion
  bastion_label                = var.bastion_label
  target_subnet_id             = lookup(module.network.hub_subnet_ids, var.bastion_subnet_key, null)
  client_cidr_block_allow_list = var.client_cidr_block_allow_list
  max_session_ttl_in_seconds   = var.max_session_ttl_in_seconds
  defined_tags                 = var.defined_tags
  freeform_tags                = var.freeform_tags
}
