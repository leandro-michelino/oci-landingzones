locals {
  blueprint_name = "aws-oci-managed-interconnect"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
  tags           = merge(var.freeform_tags, { ManagedBy = "Terraform", Blueprint = local.blueprint_name })
  edges          = { primary = "AVAILABILITY_DOMAIN_1", secondary = "AVAILABILITY_DOMAIN_2" }
  # Numeric endpoints permit IPv4 containment/overlap checks without provider API calls.
  cidr_ranges = { for name, cidr in { vcn = var.oci_vcn_cidr, subnet = var.oci_subnet_cidr, remote = var.remote_subnet_cidr, aws = var.aws_vpc_cidr } : name => {
    first = try(sum([for i, octet in split(".", cidrhost(cidr, 0)) : parseint(octet, 10) * pow(256, 3 - i)]), -1)
    last  = try(sum([for i, octet in split(".", cidrhost(cidr, -1)) : parseint(octet, 10) * pow(256, 3 - i)]), -1)
  } }
}
