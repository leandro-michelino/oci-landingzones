mock_provider "google" {}
variables {
  project_id = "example-project"
  region     = "southamerica-east1"
  name       = "example-test"
}
run "disabled_defaults" {
  command = plan
  assert {
    condition     = module.network.network_id == null && !var.enable_workload
    error_message = "Default must not create networks or workloads."
  }
}
run "approval_required" {
  command = plan
  variables { enabled = true }
  expect_failures = [terraform_data.guard]
}

run "private_enabled_branch" {
  command = plan
  variables {
    enabled         = true
    costs_approved  = true
    enable_workload = false

  }
  assert {
    condition     = length(google_compute_interconnect_attachment.this) == 2 && !google_compute_interconnect_attachment.this["primary"].admin_enabled
    error_message = "Enabled resources must retain private access, explicit destinations and deletion protection."
  }
}

run "vpn_router_is_separate" {
  command = plan
  variables {
    enabled        = true
    costs_approved = true
    enable_vpn     = true
  }
  assert {
    condition     = google_compute_router.vpn[0].bgp[0].asn == 64514 && length(google_compute_ha_vpn_gateway.this) == 1 && length(google_compute_vpn_tunnel.oci) == 0
    error_message = "VPN gateway must use its independent ASN; tunnels require separate endpoint handoff."
  }
}
run "partner_asn_rejected_for_vpn" {
  command = plan
  variables {
    enabled        = true
    costs_approved = true
    enable_vpn     = true
    vpn_asn        = 16550
  }
  expect_failures = [terraform_data.vpn_guard]
}

run "four_tunnel_bgp_configuration" {
  command = plan
  variables {
    costs_approved     = true
    enabled            = true
    enable_vpn         = true
    enable_vpn_tunnels = true
    vpn_tunnels = {
      "tunnel-0" = { peer_interface = 0, gateway_interface = 0, oracle_public_ip = "203.0.113.10", customer_ip = "169.254.21.2/30", oracle_ip = "169.254.21.1/30" }
      "tunnel-1" = { peer_interface = 1, gateway_interface = 0, oracle_public_ip = "203.0.113.11", customer_ip = "169.254.22.2/30", oracle_ip = "169.254.22.1/30" }
      "tunnel-2" = { peer_interface = 2, gateway_interface = 1, oracle_public_ip = "203.0.113.12", customer_ip = "169.254.23.2/30", oracle_ip = "169.254.23.1/30" }
      "tunnel-3" = { peer_interface = 3, gateway_interface = 1, oracle_public_ip = "203.0.113.13", customer_ip = "169.254.24.2/30", oracle_ip = "169.254.24.1/30" }
    }
    vpn_psks = {
      "tunnel-0" = "Mock-Only-Shared-Secret-0-Not-Real"
      "tunnel-1" = "Mock-Only-Shared-Secret-1-Not-Real"
      "tunnel-2" = "Mock-Only-Shared-Secret-2-Not-Real"
      "tunnel-3" = "Mock-Only-Shared-Secret-3-Not-Real"
    }
  }
  assert {
    condition     = length(google_compute_vpn_tunnel.oci) == 4 && length(google_compute_router_peer.vpn) == 4 && alltrue([for t in values(google_compute_vpn_tunnel.oci) : t.ike_version == 2])
    error_message = "Both gateway interfaces must retain four IKEv2 BGP tunnel configurations."
  }
}
