mock_provider "google" {}
variables {
  project_id = "example-project"
  region     = "southamerica-east1"
  name       = "example-test"
  zone       = "southamerica-east1-a"
}
run "disabled_defaults" {
  command = plan
  assert {
    condition     = module.network.network_id == null && !var.enable_workload
    error_message = "Default must not create networks or workloads."
  }
}
run "approval_required" {
  command = plan
  variables { enabled = true }
  expect_failures = [terraform_data.guard]
}

run "private_enabled_branch" {
  command = plan
  variables {
    enabled         = true
    costs_approved  = true
    enable_workload = true
    standby_image   = "projects/debian-cloud/global/images/family/debian-12"
  }
  assert {
    condition     = google_compute_instance.standby[0].deletion_protection && length(google_compute_instance.standby[0].network_interface[0].access_config) == 0 && google_storage_bucket.backup[0].public_access_prevention == "enforced"
    error_message = "Enabled resources must retain private access, explicit destinations and deletion protection."
  }
}
