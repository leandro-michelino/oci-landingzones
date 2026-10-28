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

run "four_tunnel_bgp_configuration" {
  command = plan
  variables {
    costs_approved     = true
    enable_oci         = true
    enable_vpn         = true
    gcp_vpn_public_ips = { primary = "198.51.100.10", secondary = "198.51.100.20" }
    vpn_tunnels = {
      "tunnel-0" = { edge_key = "primary", tunnel_id = "ocid1.ipsectunnel.oc1.sa-saopaulo-1.example0", customer_ip = "169.254.21.2/30", oracle_ip = "169.254.21.1/30" }
      "tunnel-1" = { edge_key = "primary", tunnel_id = "ocid1.ipsectunnel.oc1.sa-saopaulo-1.example1", customer_ip = "169.254.22.2/30", oracle_ip = "169.254.22.1/30" }
      "tunnel-2" = { edge_key = "secondary", tunnel_id = "ocid1.ipsectunnel.oc1.sa-saopaulo-1.example2", customer_ip = "169.254.23.2/30", oracle_ip = "169.254.23.1/30" }
      "tunnel-3" = { edge_key = "secondary", tunnel_id = "ocid1.ipsectunnel.oc1.sa-saopaulo-1.example3", customer_ip = "169.254.24.2/30", oracle_ip = "169.254.24.1/30" }
    }
    vpn_psks = {
      "tunnel-0" = "Mock-Only-Shared-Secret-0-Not-Real"
      "tunnel-1" = "Mock-Only-Shared-Secret-1-Not-Real"
      "tunnel-2" = "Mock-Only-Shared-Secret-2-Not-Real"
      "tunnel-3" = "Mock-Only-Shared-Secret-3-Not-Real"
    }
  }
  assert {
    condition     = length(oci_core_ipsec_connection_tunnel_management.gcp) == 4 && alltrue([for t in values(oci_core_ipsec_connection_tunnel_management.gcp) : t.routing == "BGP" && t.ike_version == "V2"])
    error_message = "Both gateway interfaces must retain four IKEv2 BGP tunnel configurations."
  }
}
