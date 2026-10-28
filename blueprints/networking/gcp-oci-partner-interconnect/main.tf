# Last successful validation: 2026-10-28 | Terraform validate and 11 mocked plan regressions | oracle/oci 9.11.0; hashicorp/google 7.46.2.
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
      condition     = (!var.enable_bgp || var.enable_interconnect) && (!var.activate_attachments || var.costs_approved) && var.gcp_router_asn == 16550
      error_message = "BGP requires circuits; attachment activation requires cost approval; Partner ASN must be 16550."
    }
    precondition {
      condition     = !var.enable_interconnect || (length(var.bgp_sessions) == 2 && alltrue([for key in keys(local.edges) : try(can(cidrhost(var.bgp_sessions[key].google_ip_cidr, 0)) && can(cidrhost(var.bgp_sessions[key].oracle_ip_cidr, 0)) && cidrhost(var.bgp_sessions[key].google_ip_cidr, 0) == cidrhost(var.bgp_sessions[key].oracle_ip_cidr, 0) && split("/", var.bgp_sessions[key].google_ip_cidr)[0] != split("/", var.bgp_sessions[key].oracle_ip_cidr)[0], false)]))
      error_message = "Provide primary and secondary approved BGP address pairs in the same subnet with distinct host IPs."
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

resource "google_compute_network" "this" {
  count                           = var.enable_foundation ? 1 : 0
  name                            = "${local.name_prefix}-vcn-gcp"
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = true
  depends_on                      = [terraform_data.guard]
}
resource "google_compute_subnetwork" "this" {
  count                    = var.enable_foundation ? 1 : 0
  name                     = "${local.name_prefix}-sn-gcp"
  network                  = google_compute_network.this[0].id
  ip_cidr_range            = var.remote_subnet_cidr
  private_ip_google_access = true
  region                   = var.gcp_region
}
resource "google_compute_router" "this" {
  count   = var.enable_foundation ? 1 : 0
  name    = "${local.name_prefix}-drg-gcp"
  network = google_compute_network.this[0].id
  region  = var.gcp_region
  bgp {
    asn            = var.gcp_router_asn
    advertise_mode = "CUSTOM"
    advertised_ip_ranges { range = var.remote_subnet_cidr }
  }
}
resource "google_compute_interconnect_attachment" "this" {
  for_each                 = var.enable_foundation ? local.edges : {}
  name                     = "${local.name_prefix}-fc-${each.key}"
  region                   = var.gcp_region
  router                   = google_compute_router.this[0].id
  type                     = "PARTNER"
  edge_availability_domain = each.value
  mtu                      = 1500
  admin_enabled            = var.activate_attachments
}
resource "google_compute_firewall" "ingress" {
  count         = var.enable_foundation && length(var.allowed_tcp_ports) > 0 ? 1 : 0
  name          = "${local.name_prefix}-nsg-gcp-in"
  network       = google_compute_network.this[0].id
  direction     = "INGRESS"
  source_ranges = [var.oci_subnet_cidr]
  target_tags   = ["interconnect-client"]
  allow {
    protocol = "tcp"
    ports    = [for port in var.allowed_tcp_ports : tostring(port)]
  }
}
resource "google_compute_firewall" "egress" {
  count              = var.enable_foundation && length(var.allowed_tcp_ports) > 0 ? 1 : 0
  name               = "${local.name_prefix}-nsg-gcp-out"
  network            = google_compute_network.this[0].id
  direction          = "EGRESS"
  priority           = 900
  destination_ranges = [var.oci_subnet_cidr]
  target_tags        = ["interconnect-client"]
  allow {
    protocol = "tcp"
    ports    = [for port in var.allowed_tcp_ports : tostring(port)]
  }
}
resource "google_compute_firewall" "deny_egress" {
  count              = var.enable_foundation ? 1 : 0
  name               = "${local.name_prefix}-nsg-gcp-deny"
  network            = google_compute_network.this[0].id
  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["interconnect-client"]
  deny { protocol = "all" }
}
resource "oci_core_virtual_circuit" "this" {
  for_each                  = var.enable_interconnect ? local.edges : {}
  compartment_id            = var.compartment_ocid
  type                      = "PRIVATE"
  gateway_id                = oci_core_drg.this[0].id
  provider_service_id       = var.provider_service_id
  provider_service_key_name = google_compute_interconnect_attachment.this[each.key].pairing_key
  bandwidth_shape_name      = var.bandwidth_shape_name
  customer_asn              = var.gcp_router_asn
  ip_mtu                    = "1500"
  cross_connect_mappings {
    customer_bgp_peering_ip = try(var.bgp_sessions[each.key].google_ip_cidr, null)
    oracle_bgp_peering_ip   = try(var.bgp_sessions[each.key].oracle_ip_cidr, null)
  }
  display_name  = "${local.name_prefix}-fc-${each.key}"
  defined_tags  = var.defined_tags
  freeform_tags = local.tags
  depends_on    = [terraform_data.guard]
}
resource "google_compute_router_interface" "this" {
  for_each                = var.enable_bgp ? local.edges : {}
  name                    = "${local.name_prefix}-vnic-${each.key}"
  region                  = var.gcp_region
  router                  = google_compute_router.this[0].name
  interconnect_attachment = google_compute_interconnect_attachment.this[each.key].self_link
  ip_range                = var.bgp_sessions[each.key].google_ip_cidr
}
resource "google_compute_router_peer" "this" {
  for_each                  = var.enable_bgp ? local.edges : {}
  name                      = "${local.name_prefix}-drg-peer-${each.key}"
  region                    = var.gcp_region
  router                    = google_compute_router.this[0].name
  interface                 = google_compute_router_interface.this[each.key].name
  peer_asn                  = 31898
  peer_ip_address           = split("/", var.bgp_sessions[each.key].oracle_ip_cidr)[0]
  advertised_route_priority = 100
}
