mock_provider "oci" {}
variables {
  tenancy_ocid          = "ocid1.tenancy.oc1..example"
  compartment_ocid      = "ocid1.compartment.oc1..workload"
  region                = "sa-saopaulo-1"
  org                   = "test"
  environment           = "dev"
  region_key            = "sao"
  enable_budgets        = true
  default_budget_amount = 100
}
run "default_budget_root_ownership_and_target" {
  command = plan
  assert {
    condition     = oci_budget_budget.this["landing_zone"].compartment_id == var.tenancy_ocid && toset(oci_budget_budget.this["landing_zone"].targets) == toset([var.compartment_ocid])
    error_message = "Budgets must be owned by the tenancy root while tracking the workload compartment."
  }
}
run "custom_target_override_does_not_change_ownership" {
  command = plan
  variables {
    enable_default_budget = false
    budgets = {
      custom = { amount = 200, compartment_ocid = "ocid1.compartment.oc1..target" }
    }
  }
  assert {
    condition     = oci_budget_budget.this["custom"].compartment_id == var.tenancy_ocid && toset(oci_budget_budget.this["custom"].targets) == toset(["ocid1.compartment.oc1..target"])
    error_message = "A per-budget target override must not alter root ownership."
  }
}
