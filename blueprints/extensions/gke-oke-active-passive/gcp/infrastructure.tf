# Last successful validation: 2026-10-28 | Terraform validate and 3 mocked plans | hashicorp/google 7.46.2.
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
  secondary_ranges  = { pods = "10.97.0.0/16", services = "10.98.0.0/20" }
}
resource "google_service_account" "nodes" {
  count      = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  project    = var.project_id
  account_id = "${var.name}-nodes"
}
resource "google_project_iam_member" "nodes" {
  count   = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.nodes[0].email}"
}
resource "google_container_cluster" "standby" {
  count               = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  project             = var.project_id
  location            = var.region
  name                = var.name
  network             = module.network.network_id
  subnetwork          = module.network.subnet_id
  enable_autopilot    = true
  deletion_protection = true
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.28.0.0/28"
  }
  node_config {
    service_account = google_service_account.nodes[0].email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  release_channel { channel = "REGULAR" }
  workload_identity_config { workload_pool = "${var.project_id}.svc.id.goog" }
  depends_on = [google_project_iam_member.nodes]
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
  }
}
