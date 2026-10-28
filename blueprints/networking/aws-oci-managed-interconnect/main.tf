# Last successful validation: 2026-10-28 | Terraform validate and 9 mocked plan regressions | oracle/oci 9.11.0; hashicorp/aws 6.70.0.
# Scope: local schema and simulated plans only; no live provisioning, BGP, traffic, resilience or cleanup test.
# Evidence: tests/configuration-regressions.tftest.hcl; docs/multicloud/INTERCONNECT-COVERAGE.md.
resource "terraform_data" "guard" {
  input = { foundation = var.enable_foundation, circuit = var.enable_interconnect }
  lifecycle {
    precondition {
      condition     = !var.enable_foundation || var.costs_approved
      error_message = "Networking foundation creation requires costs_approved=true, including billed external dependencies."
    }
    precondition {
      condition     = !var.enable_interconnect || (var.enable_foundation && var.costs_approved && var.region_pair_verified && var.provider_service_id != null)
      error_message = "Circuit creation requires foundation, cost approval, verified region eligibility and provider service."
    }
    precondition {
      condition     = can(cidrhost(var.oci_vcn_cidr, 0)) && can(cidrhost(var.oci_subnet_cidr, 0)) && can(cidrhost(var.remote_subnet_cidr, 0)) && alltrue([for cidr in values(local.cidr_ranges) : cidr.first >= 0 && cidr.last >= 0])
      error_message = "All network prefixes must be valid IPv4 CIDRs."
    }
    precondition {
      condition     = alltrue([for port in var.allowed_tcp_ports : port >= 1 && port <= 65535 && floor(port) == port])
      error_message = "Application TCP ports must be integers from 1 through 65535."
    }
    precondition {
      condition     = local.cidr_ranges.subnet.first >= local.cidr_ranges.vcn.first && local.cidr_ranges.subnet.last <= local.cidr_ranges.vcn.last
      error_message = "OCI subnet must start inside the OCI VCN."
    }
    precondition {
      condition     = local.cidr_ranges.remote.last < local.cidr_ranges.vcn.first || local.cidr_ranges.remote.first > local.cidr_ranges.vcn.last
      error_message = "OCI and remote workload CIDRs must not overlap."
    }

    precondition {
      condition     = local.cidr_ranges.remote.first >= local.cidr_ranges.aws.first && local.cidr_ranges.remote.last <= local.cidr_ranges.aws.last && (local.cidr_ranges.aws.last < local.cidr_ranges.vcn.first || local.cidr_ranges.aws.first > local.cidr_ranges.vcn.last) && var.aws_dx_asn != var.aws_vgw_asn
      error_message = "AWS subnet must fit in its VPC; cloud VPC/VCN ranges and gateway ASNs must differ."
    }
  }
}

resource "oci_core_vcn" "this" {
  count          = var.enable_foundation ? 1 : 0
  compartment_id = var.compartment_ocid
  cidr_block     = var.oci_vcn_cidr
  display_name   = "${local.name_prefix}-vcn-interconnect"
  defined_tags   = var.defined_tags
  freeform_tags  = local.tags
  depends_on     = [terraform_data.guard]
}
resource "oci_core_drg" "this" {
  count          = var.enable_foundation ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-drg-interconnect"
  defined_tags   = var.defined_tags
  freeform_tags  = local.tags
  depends_on     = [terraform_data.guard]
}
resource "oci_core_drg_attachment" "this" {
  count  = var.enable_foundation ? 1 : 0
  drg_id = oci_core_drg.this[0].id
  network_details {
    id   = oci_core_vcn.this[0].id
    type = "VCN"
  }
  display_name  = "${local.name_prefix}-drga-interconnect"
  defined_tags  = var.defined_tags
  freeform_tags = local.tags
}
resource "oci_core_route_table" "this" {
  count          = var.enable_foundation ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${local.name_prefix}-rt-interconnect"
  route_rules {
    destination       = var.remote_subnet_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.this[0].id
  }
  defined_tags  = var.defined_tags
  freeform_tags = local.tags
}
resource "oci_core_security_list" "this" {
  #checkov:skip=CKV_OCI_16:No SSH ingress is created; explicit reviewed application ports default empty.
  count          = var.enable_foundation ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${local.name_prefix}-sl-interconnect"
  dynamic "ingress_security_rules" {
    for_each = var.allowed_tcp_ports
    content {
      protocol  = "6"
      source    = var.remote_subnet_cidr
      stateless = false
      tcp_options {
        min = ingress_security_rules.value
        max = ingress_security_rules.value
      }
    }
  }
  dynamic "egress_security_rules" {
    for_each = var.allowed_tcp_ports
    content {
      protocol    = "6"
      destination = var.remote_subnet_cidr
      stateless   = false
      tcp_options {
        min = egress_security_rules.value
        max = egress_security_rules.value
      }
    }
  }
  defined_tags  = var.defined_tags
  freeform_tags = local.tags
}
resource "oci_core_subnet" "this" {
  count                      = var.enable_foundation ? 1 : 0
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this[0].id
  cidr_block                 = var.oci_subnet_cidr
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.this[0].id
  security_list_ids          = [oci_core_security_list.this[0].id]
  display_name               = "${local.name_prefix}-sn-interconnect"
  defined_tags               = var.defined_tags
  freeform_tags              = local.tags
}

resource "aws_vpc" "this" {
  count                = var.enable_foundation ? 1 : 0
  cidr_block           = var.aws_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${local.name_prefix}-vcn-aws" }
  depends_on           = [terraform_data.guard]
}
resource "aws_subnet" "this" {
  count                   = var.enable_foundation ? 1 : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.remote_subnet_cidr
  availability_zone       = var.aws_az
  map_public_ip_on_launch = false
  tags                    = { Name = "${local.name_prefix}-sn-aws" }
}
resource "aws_route_table" "this" {
  count  = var.enable_foundation ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags   = { Name = "${local.name_prefix}-rt-aws" }
}
resource "aws_route_table_association" "this" {
  count          = var.enable_foundation ? 1 : 0
  subnet_id      = aws_subnet.this[0].id
  route_table_id = aws_route_table.this[0].id
}
resource "aws_vpn_gateway" "this" {
  count           = var.enable_foundation ? 1 : 0
  vpc_id          = aws_vpc.this[0].id
  amazon_side_asn = var.aws_vgw_asn
  tags            = { Name = "${local.name_prefix}-drg-vgw" }
}
resource "aws_dx_gateway" "this" {
  count           = var.enable_foundation ? 1 : 0
  name            = "${local.name_prefix}-drg-dxgw"
  amazon_side_asn = var.aws_dx_asn
}
resource "aws_dx_gateway_association" "this" {
  count                 = var.enable_foundation ? 1 : 0
  dx_gateway_id         = aws_dx_gateway.this[0].id
  associated_gateway_id = aws_vpn_gateway.this[0].id
  allowed_prefixes      = [var.remote_subnet_cidr]
}
resource "aws_route" "oci" {
  count                  = var.enable_foundation ? 1 : 0
  route_table_id         = aws_route_table.this[0].id
  destination_cidr_block = var.oci_subnet_cidr
  gateway_id             = aws_vpn_gateway.this[0].id
}
resource "aws_security_group" "this" {
  count       = var.enable_foundation ? 1 : 0
  name        = "${local.name_prefix}-nsg-aws"
  description = "Explicit application access over OCI interconnect; attach to approved workload ENIs."
  vpc_id      = aws_vpc.this[0].id
  tags        = { Name = "${local.name_prefix}-nsg-aws" }
}
resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each          = var.enable_foundation ? toset([for port in var.allowed_tcp_ports : tostring(port)]) : toset([])
  security_group_id = aws_security_group.this[0].id
  cidr_ipv4         = var.oci_subnet_cidr
  ip_protocol       = "tcp"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
  description       = "Approved OCI application ingress"
}
resource "aws_vpc_security_group_egress_rule" "this" {
  for_each          = var.enable_foundation ? toset([for port in var.allowed_tcp_ports : tostring(port)]) : toset([])
  security_group_id = aws_security_group.this[0].id
  cidr_ipv4         = var.oci_subnet_cidr
  ip_protocol       = "tcp"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
  description       = "Approved OCI application egress"
}
resource "oci_core_virtual_circuit" "this" {
  count                  = var.enable_interconnect ? 1 : 0
  compartment_id         = var.compartment_ocid
  type                   = "PRIVATE"
  gateway_id             = oci_core_drg.this[0].id
  provider_service_id    = var.provider_service_id
  provider_remote_region = var.aws_region
  remote_account_id      = var.aws_account_id
  bandwidth_shape_name   = var.bandwidth_shape_name
  display_name           = "${local.name_prefix}-fc-aws"
  defined_tags           = var.defined_tags
  freeform_tags          = local.tags
  depends_on             = [terraform_data.guard]
}
