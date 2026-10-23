# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-13 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: Declared hub/spoke/DRG foundation; no workload packet paths or HA probes tested. No workload packet-flow verification.
# Current scope: schema and DEFAULT Sao Paulo hub/spoke/DRG plan; no apply or packet-flow test.
# Evidence: docs/INDUSTRY-NETWORK-REVIEW-20261023.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: hub VCN topology was planned; no new apply or packet-flow test in this round.
module "hub_vcn" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/hub-vcn?ref=v0.2.0"

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

# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-13 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: Declared hub/spoke/DRG foundation; no workload packet paths or HA probes tested. No workload packet-flow verification.
# Current scope: schema and DEFAULT Sao Paulo hub/spoke/DRG plan; no apply or packet-flow test.
# Evidence: docs/INDUSTRY-NETWORK-REVIEW-20261023.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: DRG attachments and routing were planned; no new apply or route-propagation test in this round.
module "drg" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/drg?ref=v0.2.0"

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

# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-13 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: Declared hub/spoke/DRG foundation; no workload packet paths or HA probes tested. No workload packet-flow verification.
# Current scope: schema and DEFAULT Sao Paulo hub/spoke/DRG plan; no apply or packet-flow test.
# Evidence: docs/INDUSTRY-NETWORK-REVIEW-20261023.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: spoke VCN topology was planned; no new apply or spoke-to-hub traffic test in this round.
module "spoke_vcns" {
  source   = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/spoke-vcn?ref=v0.2.0"
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
