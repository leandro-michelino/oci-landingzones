mock_provider "oci" {}
variables {
  tenancy_ocid      = "ocid1.tenancy.oc1..example"
  current_user_ocid = "ocid1.user.oc1..example"
  compartment_ocid  = "ocid1.compartment.oc1..example"
  region            = "sa-saopaulo-1"
}
run "disabled_defaults" {
  command = plan
  assert {
    condition     = !var.enable_oci && !var.costs_approved
    error_message = "Safe fixture must retain disabled cloud flags."
  }
}
run "cost_approval_required" {
  command = plan
  variables { enable_oci = true }
  expect_failures = [terraform_data.guard]
}
