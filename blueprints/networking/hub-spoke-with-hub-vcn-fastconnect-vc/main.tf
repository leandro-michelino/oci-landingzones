# Last successful validation: 2026-10-23 | blueprint Terraform validate and DEFAULT Sao Paulo plan | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-13 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: OCI network foundation only; paid FastConnect virtual circuit disabled. No circuit or packet-flow test.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-REVIEW-20261023-61-70.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: OCI hub/spoke foundation planned; no dedicated connectivity test.
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
# Last successful lifecycle: 2026-10-13 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: OCI network foundation only; paid FastConnect virtual circuit disabled. No circuit or packet-flow test.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-REVIEW-20261023-61-70.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: Paid FastConnect virtual circuit remained disabled; no circuit or BGP test.
module "fastconnect" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/fastconnect?ref=v0.2.0"

  tenancy_ocid              = var.tenancy_ocid
  compartment_ocid          = local.target_compartment_ocid
  region                    = var.region
  org                       = var.org
  environment               = var.environment
  region_key                = var.region_key
  enable_fastconnect        = var.enable_fastconnect
  virtual_circuit_label     = var.virtual_circuit_label
  virtual_circuit_type      = var.virtual_circuit_type
  bandwidth_shape_name      = var.bandwidth_shape_name
  drg_id                    = module.network.drg_id
  customer_bgp_asn          = var.customer_bgp_asn
  provider_service_id       = var.provider_service_id
  provider_service_key_name = var.provider_service_key_name
  defined_tags              = var.defined_tags
  freeform_tags             = var.freeform_tags
}
