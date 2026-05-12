# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "hub_vcn" {
  source = "../../../modules/networking/hub-vcn"

  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = local.target_compartment_ocid
  region                  = var.region
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  vcn_label               = "hub"
  vcn_dns_label           = var.hub_vcn_dns_label
  vcn_cidr_blocks         = [var.hub_vcn_cidr_block]
  enable_internet_gateway = true
  enable_nat_gateway      = true
  enable_service_gateway  = true
  subnets                 = var.hub_subnets
  defined_tags            = var.defined_tags
  freeform_tags           = var.freeform_tags
}

module "drg" {
  source = "../../../modules/networking/drg"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = local.target_compartment_ocid
  region           = var.region
  org              = var.org
  environment      = var.environment
  region_key       = var.region_key
  drg_label        = "hub"
  defined_tags     = var.defined_tags
  freeform_tags    = var.freeform_tags
}

module "spoke_vcns" {
  source   = "../../../modules/networking/spoke-vcn"
  for_each = var.spoke_vcns

  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = local.target_compartment_ocid
  region                  = var.region
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  vcn_label               = each.key
  vcn_dns_label           = each.value.dns_label
  vcn_cidr_blocks         = [each.value.cidr_block]
  drg_id                  = module.drg.drg_id
  enable_internet_gateway = false
  enable_nat_gateway      = false
  enable_service_gateway  = true
  subnets                 = each.value.subnets
  route_tables            = var.spoke_route_tables
  security_lists          = var.spoke_security_lists
  defined_tags            = var.defined_tags
  freeform_tags           = var.freeform_tags
}

resource "oci_core_drg_attachment" "hub" {
  drg_id       = module.drg.drg_id
  display_name = "${local.name_prefix}-drga-hub"
  defined_tags = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    { Role = "hub" }
  )

  network_details {
    id   = module.hub_vcn.vcn_id
    type = "VCN"
  }
}

resource "oci_core_drg_attachment" "spokes" {
  for_each = module.spoke_vcns

  drg_id       = module.drg.drg_id
  display_name = "${local.name_prefix}-drga-${each.key}"
  defined_tags = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    { Role = "spoke" }
  )

  network_details {
    id   = each.value.vcn_id
    type = "VCN"
  }
}
