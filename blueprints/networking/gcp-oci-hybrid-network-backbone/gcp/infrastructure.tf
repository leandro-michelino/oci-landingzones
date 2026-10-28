# Last successful validation: 2026-10-28 | Terraform validate and 6 mocked plans | hashicorp/google 7.46.2.
# Scope: local schema and configuration contracts only; no cloud provisioning, connectivity, replication or workload test.
# Evidence: tests/safety.tftest.hcl; docs/multicloud/GCP-COUNTERPARTS-20261028.md.
module "network" {
  source            = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/gcp-private-network?ref=e851f11166184cf9c3e66ba93091bcd0459a77b1"
  project_id        = var.project_id
  region            = var.region
  name              = var.name
  enabled           = var.enabled && var.costs_approved
  costs_approved    = var.costs_approved
  subnet_cidr       = var.subnet_cidr
  peer_cidrs        = var.peer_cidrs
  allowed_tcp_ports = var.allowed_tcp_ports
  enable_nat        = var.enable_nat && var.enabled && var.costs_approved
}
resource "google_compute_interconnect_attachment" "this" {
  for_each                 = var.enabled && var.costs_approved ? { primary = "AVAILABILITY_DOMAIN_1", secondary = "AVAILABILITY_DOMAIN_2" } : {}
  project                  = var.project_id
  region                   = var.region
  name                     = "${var.name}-partner-${each.key}"
  type                     = "PARTNER"
  router                   = module.network.router_id
  edge_availability_domain = each.value
  admin_enabled            = var.activate_attachments
}
resource "google_compute_router_interface" "this" {
  for_each                = var.enabled && var.costs_approved && var.enable_bgp ? var.bgp_sessions : {}
  project                 = var.project_id
  region                  = var.region
  name                    = "${var.name}-${each.key}"
  router                  = module.network.router_name
  interconnect_attachment = google_compute_interconnect_attachment.this[each.key].id
  ip_range                = each.value.customer_ip
}
resource "google_compute_router_peer" "this" {
  for_each                  = var.enabled && var.costs_approved && var.enable_bgp ? var.bgp_sessions : {}
  project                   = var.project_id
  region                    = var.region
  name                      = "${var.name}-${each.key}"
  router                    = module.network.router_name
  interface                 = google_compute_router_interface.this[each.key].name
  peer_ip_address           = cidrhost(each.value.oracle_ip, 0)
  peer_asn                  = each.value.peer_asn
  advertised_route_priority = 100
}
resource "terraform_data" "guard" {
  lifecycle {
    precondition {
      condition     = !var.enabled || var.costs_approved
      error_message = "Review cloud cost, workload, identity and network prerequisites."
    }
    precondition {
      condition     = !var.enable_workload || var.enabled
      error_message = "Review cloud cost, workload, identity and network prerequisites."
    }
    precondition {
      condition     = !var.enable_bgp || (var.enabled && var.activate_attachments && toset(keys(var.bgp_sessions)) == toset(["primary", "secondary"]))
      error_message = "Review cloud cost, workload, identity and network prerequisites."
    }
  }
}

resource "google_compute_ha_vpn_gateway" "this" {
  count      = var.enabled && var.costs_approved && var.enable_vpn ? 1 : 0
  project    = var.project_id
  region     = var.region
  name       = "${var.name}-ha-vpn"
  network    = module.network.network_id
  depends_on = [terraform_data.vpn_guard]
}
resource "google_compute_router" "vpn" {
  count   = var.enabled && var.costs_approved && var.enable_vpn ? 1 : 0
  project = var.project_id
  region  = var.region
  name    = "${var.name}-vpn-router"
  network = module.network.network_id
  bgp { asn = var.vpn_asn }
}
resource "google_compute_external_vpn_gateway" "oci" {
  count           = var.enabled && var.costs_approved && var.enable_vpn_tunnels ? 1 : 0
  project         = var.project_id
  name            = "${var.name}-oci-peer"
  redundancy_type = "FOUR_IPS_REDUNDANCY"
  dynamic "interface" {
    for_each = var.vpn_tunnels
    content {
      id         = interface.value.peer_interface
      ip_address = interface.value.oracle_public_ip
    }
  }
  depends_on = [terraform_data.vpn_guard]
}
resource "google_compute_vpn_tunnel" "oci" {
  for_each                        = var.enabled && var.costs_approved && var.enable_vpn_tunnels ? var.vpn_tunnels : {}
  project                         = var.project_id
  region                          = var.region
  name                            = "${var.name}-${each.key}"
  vpn_gateway                     = google_compute_ha_vpn_gateway.this[0].id
  vpn_gateway_interface           = each.value.gateway_interface
  peer_external_gateway           = google_compute_external_vpn_gateway.oci[0].id
  peer_external_gateway_interface = each.value.peer_interface
  router                          = google_compute_router.vpn[0].id
  shared_secret                   = var.vpn_psks[each.key]
  ike_version                     = 2
}
resource "google_compute_router_interface" "vpn" {
  for_each   = google_compute_vpn_tunnel.oci
  project    = var.project_id
  region     = var.region
  name       = "${var.name}-vpn-${each.key}"
  router     = google_compute_router.vpn[0].name
  vpn_tunnel = each.value.id
  ip_range   = var.vpn_tunnels[each.key].customer_ip
}
resource "google_compute_router_peer" "vpn" {
  for_each                  = google_compute_vpn_tunnel.oci
  project                   = var.project_id
  region                    = var.region
  name                      = "${var.name}-vpn-${each.key}"
  router                    = google_compute_router.vpn[0].name
  interface                 = google_compute_router_interface.vpn[each.key].name
  peer_ip_address           = cidrhost(var.vpn_tunnels[each.key].oracle_ip, 0)
  peer_asn                  = var.oci_vpn_asn
  advertised_route_priority = 200
}
resource "terraform_data" "vpn_guard" {
  lifecycle {
    precondition {
      condition     = !var.enable_vpn || (var.enabled && var.costs_approved && var.vpn_asn != 16550)
      error_message = "HA VPN requires approved foundation and a separate VPN ASN/router."
    }
    precondition {
      condition     = !var.enable_vpn_tunnels || (var.enable_vpn && length(var.vpn_tunnels) == 4 && toset([for t in values(var.vpn_tunnels) : t.peer_interface]) == toset([0, 1, 2, 3]) && toset([for t in values(var.vpn_tunnels) : t.gateway_interface]) == toset([0, 1]) && alltrue([for k, t in var.vpn_tunnels : contains(keys(var.vpn_psks), k)]))
      error_message = "Four reviewed peer endpoints and keys must cover HA gateway interfaces 0/1 and peer interfaces 0/1/2/3."
    }
  }
}
