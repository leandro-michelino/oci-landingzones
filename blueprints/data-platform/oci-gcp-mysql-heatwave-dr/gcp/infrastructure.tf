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
}
resource "google_compute_global_address" "sql" {
  count         = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  project       = var.project_id
  name          = "${var.name}-sql-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.network.network_id
}
resource "google_service_networking_connection" "sql" {
  count                   = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  network                 = module.network.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.sql[0].name]
}
resource "google_sql_database_instance" "standby" {
  count               = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  project             = var.project_id
  region              = var.region
  name                = var.name
  database_version    = "MYSQL_8_0"
  deletion_protection = true
  settings {
    tier              = "db-custom-2-7680"
    availability_type = "REGIONAL"
    disk_autoresize   = true
    disk_type         = "PD_SSD"
    ip_configuration {
      ipv4_enabled       = false
      private_network    = module.network.network_id
      allocated_ip_range = google_compute_global_address.sql[0].name
      ssl_mode           = "ENCRYPTED_ONLY"
    }
    backup_configuration {
      enabled                        = true
      binary_log_enabled             = true
      transaction_log_retention_days = 7
    }
  }
  depends_on = [google_service_networking_connection.sql]
}
resource "google_sql_user" "admin" {
  count    = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  project  = var.project_id
  instance = google_sql_database_instance.standby[0].name
  name     = "lzadmin"
  password = var.admin_password
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
      condition     = !var.enable_workload || var.admin_password != null
      error_message = "Review cloud cost, workload, identity and network prerequisites."
    }
  }
}
