# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema only; no DEFAULT live plan because a second region is outside the selected scope.
# Evidence: docs/INDUSTRY-NETWORK-REVIEW-20261023.md.
# Review: no functional change; cross-region DR and failover remain untested.
module "primary_network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=d7938f4baef1aa512fc8dcee99a545ec17e0dab2"

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

# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema only; no DEFAULT live plan because a second region is outside the selected scope.
# Evidence: docs/INDUSTRY-NETWORK-REVIEW-20261023.md.
# Review: no functional change; cross-region DR and failover remain untested.
module "secondary_network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=d7938f4baef1aa512fc8dcee99a545ec17e0dab2"

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
