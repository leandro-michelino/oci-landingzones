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
    admin_password  = "Example-Only-Mock-Password-927!"
  }
  assert {
    condition     = !google_sql_database_instance.standby[0].settings[0].ip_configuration[0].ipv4_enabled && google_sql_database_instance.standby[0].settings[0].ip_configuration[0].ssl_mode == "ENCRYPTED_ONLY" && google_sql_database_instance.standby[0].deletion_protection
    error_message = "Enabled resources must retain private access, explicit destinations and deletion protection."
  }
}
