# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
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
