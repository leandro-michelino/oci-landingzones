# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "primary_network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=v0.1.0"

  tenancy_ocid       = var.tenancy_ocid
  current_user_ocid  = var.current_user_ocid
  region             = var.region
  home_region        = var.home_region
  oci_config_profile = var.oci_config_profile
  compartment_ocid   = local.primary_compartment_ocid
  org                = var.org
  environment        = var.environment
  region_key         = var.region_key
  defined_tags       = var.defined_tags
  freeform_tags      = merge(var.freeform_tags, { RegionRole = "primary" })
}

module "secondary_network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=v0.1.0"

  tenancy_ocid       = var.tenancy_ocid
  current_user_ocid  = var.current_user_ocid
  region             = var.secondary_region
  home_region        = var.home_region
  oci_config_profile = var.oci_config_profile
  compartment_ocid   = local.secondary_compartment_ocid
  org                = var.org
  environment        = var.environment
  region_key         = var.secondary_region_key
  defined_tags       = var.defined_tags
  freeform_tags      = merge(var.freeform_tags, { RegionRole = "secondary" })
}
