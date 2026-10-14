mock_provider "oci" {}
variables {
  tenancy_ocid     = "ocid1.tenancy.oc1..example"
  compartment_ocid = "ocid1.compartment.oc1..example"
  region           = "sa-saopaulo-1"
  org              = "test"
  environment      = "dev"
  region_key       = "sao"
}
run "disabled_without_policy" {
  command = plan
  assert {
    condition     = output.network_firewall_policy_id == null && output.network_firewall_id == null
    error_message = "Disabled Firewall must plan successfully and return null IDs when no existing policy is supplied."
  }
}
run "disabled_with_existing_policy" {
  command = plan
  variables { network_firewall_policy_id = "ocid1.networkfirewallpolicy.oc1..example" }
  assert {
    condition     = output.network_firewall_policy_id == var.network_firewall_policy_id && length(oci_network_firewall_network_firewall.this) == 0
    error_message = "Disabled Firewall must preserve a supplied policy reference without creating an instance."
  }
}
