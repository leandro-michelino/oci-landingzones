# Last successful validation: 2026-10-23 | blueprint Terraform validate and DEFAULT Sao Paulo plan | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-14 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: default network foundation with NAT; no workload packet-flow verification.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-GOVERNANCE-REVIEW-20261023-71-80.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: Custom three-tier VCN planned with NAT and internet gateway; no workload or traffic test.
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
  vcn_cidr_blocks         = var.vcn_cidr_blocks
  enable_internet_gateway = var.enable_internet_gateway
  enable_nat_gateway      = var.enable_nat_gateway
  enable_service_gateway  = var.enable_service_gateway
  subnets                 = var.subnets
  route_tables            = var.route_tables
  security_lists          = var.security_lists
  defined_tags            = var.defined_tags
  freeform_tags           = var.freeform_tags
}
