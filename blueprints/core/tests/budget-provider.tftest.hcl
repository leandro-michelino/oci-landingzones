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
  tenancy_ocid            = "ocid1.tenancy.oc1..example"
  current_user_ocid       = "ocid1.user.oc1..example"
  parent_compartment_ocid = "ocid1.compartment.oc1..example"
  region                  = "sa-saopaulo-1"
  home_region             = "me-abudhabi-1"
  oci_config_profile      = "DEFAULT"
  org                     = "test"
  environment             = "dev"
  region_key              = "sao"
}
run "budget_module_uses_home_provider" {
  command = apply
  variables {
    enable_budgets        = true
    default_budget_amount = 100
  }
  assert {
    condition     = module.budgets.budget_ids["landing_zone"] == "home-budget"
    error_message = "The Core budget module must inherit the tenancy-home provider."
  }
}
