mock_provider "google" {}
variables {
  project_id = "example-project"
  region     = "southamerica-east1"
  name       = "example-test"
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

  }
  assert {
    condition     = google_container_cluster.standby[0].private_cluster_config[0].enable_private_nodes && google_container_cluster.standby[0].private_cluster_config[0].enable_private_endpoint && google_container_cluster.standby[0].deletion_protection
    error_message = "Enabled resources must retain private access, explicit destinations and deletion protection."
  }
}
