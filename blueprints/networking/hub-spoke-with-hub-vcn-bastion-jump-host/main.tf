# Last successful validation: 2026-10-13 | blueprint Terraform init/validate | oracle/oci 9.9.0.
# Last successful lifecycle: 2026-10-13 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Scope: OCI network foundation only; managed Bastion disabled because approved client CIDRs were not supplied. No workload packet-flow verification.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md; module call validated in this blueprint context.
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

# Last successful validation: 2026-10-13 | blueprint Terraform init/validate | oracle/oci 9.9.0.
# Last successful lifecycle: 2026-10-13 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Scope: OCI network foundation only; managed Bastion disabled because approved client CIDRs were not supplied. No workload packet-flow verification.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md; module call validated in this blueprint context.
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
