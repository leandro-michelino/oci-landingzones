# Last successful validation: 2026-10-28 | Terraform validate and 3 mocked plans | oracle/oci 9.11.0.
# Scope: local schema and configuration contracts only; no cloud provisioning, connectivity, replication or workload test.
# Evidence: tests/safety.tftest.hcl; docs/multicloud/GCP-COUNTERPARTS-20261028.md.
resource "terraform_data" "guard" {
  lifecycle {
    precondition {
      condition     = !var.enable_oci || var.costs_approved
      error_message = "Review explicit cost, service, network and connectivity prerequisites before creation."
    }
    precondition {
      condition     = !var.enable_interconnect || (var.enable_oci && var.region_pair_verified && var.provider_service_id != null && toset(keys(var.circuits)) == toset(["primary", "secondary"]))
      error_message = "Review explicit cost, service, network and connectivity prerequisites before creation."
    }
  }
}
module "network" {
  count                   = var.enable_oci && var.costs_approved ? 1 : 0
  source                  = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/spoke-vcn?ref=1d95764bd67c1629452af3b95acd51ae5b60b51d"
  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = var.compartment_ocid
  region                  = var.region
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  enable_internet_gateway = false
  enable_nat_gateway      = false
  enable_service_gateway  = false
  vcn_cidr_blocks         = [var.oci_vcn_cidr]
  route_tables            = { private = { route_rules = [{ destination = var.peer_cidr, network_entity_id = oci_core_drg.this[0].id }] } }
  security_lists = { private = {
    ingress_rules = [for port in var.allowed_tcp_ports : { protocol = "6", source = var.peer_cidr, tcp_options = { min = port, max = port } }]
    egress_rules  = [for port in var.allowed_tcp_ports : { protocol = "6", destination = var.peer_cidr, tcp_options = { min = port, max = port } }]
  } }
  subnets = { workload = { cidr_block = var.oci_subnet_cidr, security_list_keys = ["private"], route_table_key = "private", prohibit_internet_ingress = true, prohibit_public_ip_on_vnic = true } }
}
resource "oci_core_drg" "this" {
  count          = var.enable_oci && var.costs_approved ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${var.org}-${var.environment}-${var.region_key}-drg-gcp"
}
resource "oci_core_drg_attachment" "this" {
  count  = var.enable_oci && var.costs_approved ? 1 : 0
  drg_id = oci_core_drg.this[0].id
  network_details {
    id   = module.network[0].vcn_id
    type = "VCN"
  }
}
resource "oci_core_virtual_circuit" "this" {
  for_each                  = var.enable_oci && var.costs_approved && var.enable_interconnect ? var.circuits : {}
  compartment_id            = var.compartment_ocid
  display_name              = "${var.org}-${var.environment}-${var.region_key}-fc-gcp-${each.key}"
  type                      = "PRIVATE"
  gateway_id                = oci_core_drg.this[0].id
  provider_service_id       = var.provider_service_id
  provider_service_key_name = each.value.pairing_key
  bandwidth_shape_name      = each.value.bandwidth
  customer_asn              = each.value.customer_asn
  cross_connect_mappings {
    customer_bgp_peering_ip = each.value.customer_ip
    oracle_bgp_peering_ip   = each.value.oracle_ip
  }
  depends_on = [terraform_data.guard]
}

resource "oci_core_cpe" "gcp" {
  for_each       = var.enable_oci && var.costs_approved && var.enable_vpn ? var.gcp_vpn_public_ips : {}
  compartment_id = var.compartment_ocid
  display_name   = "${var.org}-${var.environment}-${var.region_key}-cpe-gcp-${each.key}"
  ip_address     = each.value
  depends_on     = [terraform_data.vpn_guard]
}
resource "oci_core_ipsec" "gcp" {
  for_each       = oci_core_cpe.gcp
  compartment_id = var.compartment_ocid
  cpe_id         = each.value.id
  drg_id         = oci_core_drg.this[0].id
  static_routes  = []
  display_name   = "${var.org}-${var.environment}-${var.region_key}-ipsec-gcp-${each.key}"
}
resource "oci_core_ipsec_connection_tunnel_management" "gcp" {
  for_each      = var.enable_oci && var.costs_approved && var.enable_vpn ? var.vpn_tunnels : {}
  ipsec_id      = oci_core_ipsec.gcp[each.value.edge_key].id
  tunnel_id     = each.value.tunnel_id
  ike_version   = "V2"
  routing       = "BGP"
  shared_secret = var.vpn_psks[each.key]
  bgp_session_info {
    customer_bgp_asn      = var.gcp_vpn_asn
    customer_interface_ip = each.value.customer_ip
    oracle_interface_ip   = each.value.oracle_ip
  }
  depends_on = [terraform_data.vpn_guard]
}
resource "terraform_data" "vpn_guard" {
  lifecycle {
    precondition {
      condition     = !var.enable_vpn || (var.enable_oci && var.costs_approved && toset(keys(var.gcp_vpn_public_ips)) == toset(["primary", "secondary"]))
      error_message = "VPN requires approved OCI foundation and both GCP gateway public addresses."
    }
    precondition {
      condition     = !var.enable_vpn || (var.gcp_vpn_asn != 16550 && (length(var.vpn_tunnels) == 0 || (length(var.vpn_tunnels) == 4 && alltrue([for k, t in var.vpn_tunnels : contains(["primary", "secondary"], t.edge_key) && contains(keys(var.vpn_psks), k)]))))
      error_message = "Use a separate VPN ASN and four reviewed tunnel bindings/keys after connection creation; empty bindings support staged discovery."
    }
  }
}
