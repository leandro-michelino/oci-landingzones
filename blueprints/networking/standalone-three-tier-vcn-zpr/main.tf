# Last successful validation: 2026-10-23 | blueprint Terraform validate and DEFAULT Sao Paulo plan | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-14 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: default network foundation; ZPR disabled; no workload packet-flow verification.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-GOVERNANCE-REVIEW-20261023-71-80.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: Three-tier VCN planned with NAT; no workload or traffic test.
module "workload_vcn" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/spoke-vcn?ref=v0.2.0"

  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = local.target_compartment_ocid
  region                  = var.region
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  vcn_label               = var.vcn_label
  vcn_dns_label           = var.vcn_dns_label
  vcn_cidr_blocks         = [var.vcn_cidr_block]
  enable_internet_gateway = true
  enable_nat_gateway      = true
  enable_service_gateway  = true
  subnets                 = var.subnets
  route_tables            = var.route_tables
  security_lists          = var.security_lists
  defined_tags            = var.defined_tags
  freeform_tags           = var.freeform_tags
}

# Last successful validation: 2026-10-23 | blueprint Terraform validate and DEFAULT Sao Paulo plan | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-14 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: default network foundation; ZPR disabled; no workload packet-flow verification.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-GOVERNANCE-REVIEW-20261023-71-80.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: Tenancy-root ZPR onboarding and policies remained disabled; no policy enforcement test.
module "zpr" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/zpr?ref=d7938f4baef1aa512fc8dcee99a545ec17e0dab2"

  tenancy_ocid             = var.tenancy_ocid
  compartment_ocid         = local.target_compartment_ocid
  region                   = var.region
  org                      = var.org
  environment              = var.environment
  region_key               = var.region_key
  enable_zpr_configuration = var.enable_zpr_configuration
  enable_zpr_policies      = var.enable_zpr_policies
  zpr_policies             = var.zpr_policies
  defined_tags             = var.defined_tags
  freeform_tags            = var.freeform_tags
}
