# Last successful validation: 2026-10-28 | Terraform validate and 4 mocked plans | hashicorp/google 7.46.2.
# Scope: local schema and safety contracts only; no project/API call, provisioning, route or traffic validation.
# Evidence: tests/safety.tftest.hcl; README.md.
resource "terraform_data" "guard" {
  lifecycle {
    precondition {
      condition     = !var.enabled || var.costs_approved
      error_message = "Network creation requires explicit cost approval."
    }
    precondition {
      condition     = alltrue([for p in var.allowed_tcp_ports : p >= 1 && p <= 65535 && floor(p) == p]) && can(cidrhost(var.subnet_cidr, 0)) && alltrue([for c in var.peer_cidrs : can(cidrhost(c, 0))])
      error_message = "Use valid IPv4 CIDRs and TCP ports 1 through 65535."
    }
    precondition {
      condition     = !var.enable_nat || var.enabled
      error_message = "NAT requires the enabled network."
    }
  }
}
resource "google_compute_network" "this" {
  count                           = var.enabled ? 1 : 0
  project                         = var.project_id
  name                            = "${var.name}-vpc"
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
  depends_on                      = [terraform_data.guard]
}
resource "google_compute_subnetwork" "this" {
  count                    = var.enabled ? 1 : 0
  project                  = var.project_id
  region                   = var.region
  name                     = "${var.name}-subnet"
  network                  = google_compute_network.this[0].id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  dynamic "secondary_ip_range" {
    for_each = var.secondary_ranges
    content {
      range_name    = secondary_ip_range.key
      ip_cidr_range = secondary_ip_range.value
    }
  }
}
resource "google_compute_router" "this" {
  count   = var.enabled ? 1 : 0
  project = var.project_id
  region  = var.region
  name    = "${var.name}-router"
  network = google_compute_network.this[0].id
  bgp { asn = 16550 }
}
resource "google_compute_firewall" "peer" {
  count         = var.enabled && length(var.allowed_tcp_ports) > 0 && length(var.peer_cidrs) > 0 ? 1 : 0
  project       = var.project_id
  name          = "${var.name}-peer-ingress"
  network       = google_compute_network.this[0].id
  direction     = "INGRESS"
  source_ranges = var.peer_cidrs
  target_tags   = [var.name]
  allow {
    protocol = "tcp"
    ports    = [for p in var.allowed_tcp_ports : tostring(p)]
  }
  log_config { metadata = "INCLUDE_ALL_METADATA" }
}
resource "google_compute_route" "egress" {
  count            = var.enabled && var.enable_nat ? 1 : 0
  project          = var.project_id
  name             = "${var.name}-nat-egress"
  network          = google_compute_network.this[0].id
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}
resource "google_compute_router_nat" "this" {
  count                              = var.enabled && var.enable_nat ? 1 : 0
  project                            = var.project_id
  region                             = var.region
  name                               = "${var.name}-nat"
  router                             = google_compute_router.this[0].name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.this[0].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
