# Last successful validation: 2026-10-23 | blueprint Terraform validate and DEFAULT Sao Paulo plan | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-14 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: default network foundation; ZPR disabled; no workload packet-flow verification.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-GOVERNANCE-REVIEW-20261023-71-80.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: Private VCN foundation planned without NAT or internet gateway; no private endpoint workload or traffic test.
module "private_vcn" {
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
  enable_internet_gateway = false
  enable_nat_gateway      = var.enable_nat_gateway
  enable_service_gateway  = true
  subnets                 = var.subnets
  route_tables            = var.route_tables
  security_lists          = local.effective_security_lists
  defined_tags            = var.defined_tags
  freeform_tags           = var.freeform_tags
}

# Service-gateway routing also requires egress permission to the regional OSN label.
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    regex  = true
    values = ["All .* Services In Oracle Services Network"]
  }
}

locals {
  effective_security_lists = {
    for key, value in var.security_lists : key => merge(value, {
      egress_rules = concat([for rule in value.egress_rules : rule], var.enable_service_gateway_https_egress && key == "baseline" ? [{
        description      = "HTTPS to regional Oracle Services Network through the service gateway."
        protocol         = "6"
        destination      = data.oci_core_services.all_services.services[0].cidr_block
        destination_type = "SERVICE_CIDR_BLOCK"
        stateless        = false
        tcp_options      = { min = 443, max = 443 }
        udp_options      = null
        icmp_options     = null
      }] : [])
    })
  }
}
