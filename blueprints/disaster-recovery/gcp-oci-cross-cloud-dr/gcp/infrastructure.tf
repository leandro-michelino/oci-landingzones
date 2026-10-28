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
resource "google_storage_bucket" "backup" {
  count                       = var.enabled && var.costs_approved ? 1 : 0
  project                     = var.project_id
  name                        = "${var.project_id}-${var.name}-dr"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false
  versioning { enabled = true }
}
resource "google_service_account" "standby" {
  count      = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  project    = var.project_id
  account_id = "${var.name}-dr"
}
resource "google_compute_instance" "standby" {
  count        = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  project      = var.project_id
  zone         = var.zone
  name         = "${var.name}-standby"
  machine_type = "e2-standard-2"
  tags         = [module.network.network_tag]
  boot_disk {
    initialize_params { image = var.standby_image }
  }
  network_interface { subnetwork = module.network.subnet_id }
  service_account {
    email  = google_service_account.standby[0].email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = { enable-oslogin = "TRUE", block-project-ssh-keys = "TRUE" }
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  deletion_protection = true
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
      condition     = !var.enable_workload || var.standby_image != null
      error_message = "Review cloud cost, workload, identity and network prerequisites."
    }
  }
}
