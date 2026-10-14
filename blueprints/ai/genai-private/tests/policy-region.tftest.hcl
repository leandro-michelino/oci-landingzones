mock_provider "oci" {
  mock_resource "oci_identity_policy" { defaults = { id = "workload-region-policy" } }
}
mock_provider "oci" {
  alias = "home"
  mock_resource "oci_identity_policy" { defaults = { id = "home-region-policy" } }
}
variables {
  tenancy_ocid       = "ocid1.tenancy.oc1..example"
  current_user_ocid  = "ocid1.user.oc1..example"
  compartment_ocid   = "ocid1.compartment.oc1..example"
  region             = "sa-saopaulo-1"
  home_region        = "me-abudhabi-1"
  oci_config_profile = "DEFAULT"
  org                = "test"
  environment        = "dev"
  region_key         = "sao"
}
run "iam_policy_uses_home_provider" {
  command = apply
  variables {
    policy_compartment_ocid = "ocid1.compartment.oc1..example"
    policy_statements       = ["Allow group MockGroup to read generative-ai-family in compartment MockCompartment"]
  }
  assert {
    condition     = oci_identity_policy.access[0].id == "home-region-policy"
    error_message = "IAM policy creation must use the home-region provider alias."
  }
}
