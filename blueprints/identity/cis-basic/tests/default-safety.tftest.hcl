mock_provider "oci" {}

variables {
  tenancy_ocid      = "ocid1.tenancy.oc1..example"
  current_user_ocid = "ocid1.user.oc1..example"
  compartment_ocid  = "ocid1.compartment.oc1..example"
  region            = "sa-saopaulo-1"
  home_region       = "me-abudhabi-1"
  org               = "test"
  environment       = "dev"
  region_key        = "sao"
}

run "no_iam_baseline_by_default" {
  command = plan

  assert {
    condition     = length(module.groups.group_ids) == 0 && length(module.dynamic_groups.dynamic_group_ids) == 0 && length(module.policies.policy_ids) == 0
    error_message = "CIS groups, dynamic groups, and policies must be explicitly enabled."
  }
}
