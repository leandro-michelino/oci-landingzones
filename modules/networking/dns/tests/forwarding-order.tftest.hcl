mock_provider "oci" {
  mock_data "oci_core_vcn_dns_resolver_association" {
    defaults = { dns_resolver_id = "ocid1.dnsresolver.oc1..example" }
  }
}
variables {
  tenancy_ocid     = "ocid1.tenancy.oc1..example"
  compartment_ocid = "ocid1.compartment.oc1..example"
  region           = "us-ashburn-1"
  org              = "test"
  environment      = "dev"
  region_key       = "iad"
}
run "disabled_dns" {
  command = plan
  variables { enable_private_dns = false }
  assert {
    condition     = length(oci_dns_view.private) == 0 && length(oci_dns_resolver.vcn) == 0
    error_message = "Disabled DNS must not create view or resolver management resources."
  }
}
run "forwarding_endpoint_and_rule_plan_together" {
  command = plan
  variables {
    vcn_ids                   = { hub = "ocid1.vcn.oc1.iad..example" }
    enable_resolver_endpoints = true
    resolver_endpoints        = { outbound = { vcn_key = "hub", subnet_id = "ocid1.subnet.oc1.iad..example", is_forwarding = true, is_listening = false } }
    resolver_rules            = [{ action = "FORWARD", source_endpoint_name = "outbound", destination_addresses = ["10.2.0.53"], qname_cover_conditions = ["example.internal"] }]
  }
  assert {
    condition     = length(oci_dns_resolver.vcn) == 1 && length(oci_dns_resolver_endpoint.this) == 1
    error_message = "Resolver rules and their named outbound endpoint must plan in one dependency graph."
  }
}
