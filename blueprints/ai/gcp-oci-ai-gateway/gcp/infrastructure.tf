# Last successful validation: 2026-10-28 | Terraform validate and 4 mocked plans | hashicorp/google 7.46.2.
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
resource "google_service_account" "adapter" {
  count      = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  project    = var.project_id
  account_id = "${var.name}-ai"
}
resource "google_project_iam_member" "vertex" {
  count   = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.adapter[0].email}"
}
resource "google_cloud_run_v2_service" "adapter" {
  count               = var.enabled && var.costs_approved && var.enable_workload ? 1 : 0
  project             = var.project_id
  name                = var.name
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  deletion_protection = true
  template {
    service_account = google_service_account.adapter[0].email
    scaling { max_instance_count = 2 }
    containers {
      image = var.adapter_image
      env {
        name  = "OCI_ADAPTER_URL"
        value = var.oci_adapter_url
      }
    }
    vpc_access {
      egress = "ALL_TRAFFIC"
      network_interfaces {
        network    = module.network.network_id
        subnetwork = module.network.subnet_id
      }
    }
  }
  depends_on = [google_project_iam_member.vertex]
}
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  for_each = var.enabled && var.costs_approved && var.enable_workload ? var.invoker_members : []
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.adapter[0].name
  role     = "roles/run.invoker"
  member   = each.value
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
      condition     = !var.enable_workload || (var.adapter_image != null && try(startswith(var.oci_adapter_url, "https://"), false) && length(var.invoker_members) > 0)
      error_message = "Review cloud cost, workload, identity and network prerequisites."
    }
    precondition {
      condition     = alltrue([for m in var.invoker_members : !contains(["allUsers", "allAuthenticatedUsers"], m)])
      error_message = "Review cloud cost, workload, identity and network prerequisites."
    }
  }
}
