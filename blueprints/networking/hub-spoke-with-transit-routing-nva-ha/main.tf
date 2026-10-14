# Last successful validation: 2026-10-14 | blueprint Terraform init/validate | oracle/oci 9.9.0.
# Last successful lifecycle: 2026-10-14 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Scope: OCI network foundation only; optional services disabled; no workload packet-flow verification.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md; module call validated in this blueprint context.
module "network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=d7938f4baef1aa512fc8dcee99a545ec17e0dab2"

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

# Last successful validation: 2026-10-14 | blueprint Terraform init/validate | oracle/oci 9.9.0.
# Last successful lifecycle: 2026-10-14 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Scope: OCI network foundation only; optional services disabled; no workload packet-flow verification.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md; module call validated in this blueprint context.
module "nva_ha" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/net-appliance?ref=v0.2.0"

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
