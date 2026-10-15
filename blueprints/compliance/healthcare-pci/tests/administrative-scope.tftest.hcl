mock_provider "oci" {
  mock_resource "oci_budget_budget" { defaults = { id = "workload-budget" } }
  mock_resource "oci_identity_policy" { defaults = { id = "workload-policy" } }
}
mock_provider "oci" {
  alias = "home"
  mock_resource "oci_budget_budget" { defaults = { id = "home-budget" } }
  mock_resource "oci_identity_policy" { defaults = { id = "home-policy" } }
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
run "root_budget_and_home_region_policy" {
  command = apply
  variables {
    enable_budget               = true
    guardrail_policy_statements = ["Allow group MockAuditors to read all-resources in compartment MockCompartment"]
  }
  assert {
    condition     = oci_budget_budget.this[0].id == "home-budget" && oci_budget_budget.this[0].compartment_id == var.tenancy_ocid && toset(oci_budget_budget.this[0].targets) == toset([var.compartment_ocid]) && oci_identity_policy.guardrails[0].id == "home-policy"
    error_message = "Budget ownership and IAM creation must use the administrative provider, while spending targets remain scoped to the workload."
  }
}

run "data_safe_requires_existing_autonomous_database" {
  command = plan
  variables { enable_data_safe_target_database = true }
  expect_failures = [oci_data_safe_target_database.this]
}
