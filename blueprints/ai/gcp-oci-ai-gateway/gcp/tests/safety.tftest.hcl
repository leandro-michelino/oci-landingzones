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
run "public_identity_rejected" {
  command = plan
  variables { invoker_members = ["allUsers"] }
  expect_failures = [terraform_data.guard]
}

run "private_enabled_branch" {
  command = plan
  variables {
    enabled         = true
    costs_approved  = true
    enable_workload = true
    adapter_image   = "example.invalid/adapter@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    oci_adapter_url = "https://example.invalid/inference"
    invoker_members = ["serviceAccount:caller@example-project.iam.gserviceaccount.com"]
  }
  assert {
    condition     = google_cloud_run_v2_service.adapter[0].ingress == "INGRESS_TRAFFIC_INTERNAL_ONLY" && length(google_cloud_run_v2_service_iam_member.invoker) == 1
    error_message = "Enabled resources must retain private access, explicit destinations and deletion protection."
  }
}
