# Last successful validation: 2026-10-23 | blueprint Terraform validate and DEFAULT Sao Paulo plan | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-13 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: OCI network foundation only; Bastion disabled for missing approved client CIDRs. No session or packet-flow test.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-REVIEW-20261023-61-70.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: OCI hub/spoke foundation planned; Bastion remained disabled.
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
# Historical lifecycle scope: OCI network foundation only; Bastion disabled for missing approved client CIDRs. No session or packet-flow test.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-REVIEW-20261023-61-70.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: Bastion remained disabled because approved client CIDRs were not supplied; no session test.
module "bastion" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/security/bastion?ref=v0.2.0"

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
