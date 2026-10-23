# Last successful validation: 2026-10-23 | blueprint Terraform validate and DEFAULT Sao Paulo plan | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-14 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: OCI network foundation only; optional services disabled; no workload packet-flow verification.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-REVIEW-20261023-61-70.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: OCI hub/spoke foundation planned; no tenant-isolation or traffic test.
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

# Last successful validation: 2026-10-23 | blueprint Terraform validate and DEFAULT Sao Paulo plan | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-14 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: OCI network foundation only; optional services disabled; no workload packet-flow verification.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-REVIEW-20261023-61-70.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: Default plan includes private DNS view, zone, and resolver associations; no apply or shared DNS query test.
module "shared_dns" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/dns?ref=v0.2.0"

  tenancy_ocid                         = var.tenancy_ocid
  compartment_ocid                     = local.target_compartment_ocid
  region                               = var.region
  org                                  = var.org
  environment                          = var.environment
  region_key                           = var.region_key
  enable_private_dns                   = var.enable_private_dns
  dns_label                            = "shared"
  private_zones                        = var.private_zones
  vcn_ids                              = merge({ hub = module.network.hub_vcn_id }, module.network.spoke_vcn_ids)
  attach_private_view_to_vcn_resolvers = true
  defined_tags                         = var.defined_tags
  freeform_tags                        = var.freeform_tags
}
