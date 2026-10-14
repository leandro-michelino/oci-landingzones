mock_provider "oci" {}
variables {
  tenancy_ocid             = "ocid1.tenancy.oc1..example"
  compartment_ocid         = "ocid1.compartment.oc1..example"
  region                   = "me-abudhabi-1"
  org                      = "test"
  environment              = "dev"
  region_key               = "auh"
  enable_zpr_configuration = true
  enable_zpr_policies      = true
  zpr_policies             = { smoke = { name = "test-smoke", description = "mocked scope regression", statements = ["in test.zone VCN allow test.role endpoints to connect to test.role endpoints"] } }
}
run "zpr_uses_tenancy_root" {
  command = plan
  assert {
    condition     = oci_zpr_configuration.this[0].compartment_id == var.tenancy_ocid && oci_zpr_zpr_policy.this["smoke"].compartment_id == var.tenancy_ocid
    error_message = "ZPR configuration and policies must target tenancy root, not workload compartment."
  }
}
