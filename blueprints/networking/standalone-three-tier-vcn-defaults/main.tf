# Last successful validation: 2026-10-14 | blueprint Terraform init/validate | oracle/oci 9.9.0.
# Last successful lifecycle: 2026-10-14 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Scope: default network foundation with NAT; no workload packet-flow verification.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md; module call validated in this blueprint context.
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
