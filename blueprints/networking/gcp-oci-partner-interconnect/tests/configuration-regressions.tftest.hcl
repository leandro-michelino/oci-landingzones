mock_provider "oci" {}
mock_provider "google" {}
variables {
  tenancy_ocid     = "ocid1.tenancy.oc1..example"
  compartment_ocid = "ocid1.compartment.oc1..example"
  region           = "sa-saopaulo-1"
  org              = "example"
  environment      = "dev"
  region_key       = "gru"
  gcp_project_id   = "example-project"
  gcp_region       = "southamerica-east1"
}
run "disabled_defaults" {
  command = plan
  assert {
    condition     = length(oci_core_vcn.this) == 0 && length(google_compute_network.this) == 0 && length(google_compute_interconnect_attachment.this) == 0
    error_message = "Disabled defaults must not create cloud resources."
  }
}
run "foundation_with_scoped_access" {
  command = plan
  variables {
    costs_approved    = true
    enable_foundation = true
    allowed_tcp_ports = [443]
  }
  assert {
    condition     = oci_core_subnet.this[0].prohibit_public_ip_on_vnic && length(oci_core_virtual_circuit.this) == 0
    error_message = "Foundation must remain private with circuits disabled."
  }
  assert {
    condition     = length(google_compute_interconnect_attachment.this) == 2 && !google_compute_interconnect_attachment.this["primary"].admin_enabled && google_compute_network.this[0].delete_default_routes_on_create
    error_message = "Remote foundation must retain explicit access and routing controls."
  }
}
run "circuit_requires_cost_approval" {
  command = plan
  variables {
    enable_foundation   = true
    enable_interconnect = true
  }
  expect_failures = [terraform_data.guard]
}
run "overlapping_ranges_rejected" {
  command = plan
  variables { remote_subnet_cidr = "10.56.20.0/24" }
  expect_failures = [terraform_data.guard]
}
run "invalid_ports_rejected" {
  command = plan
  variables { allowed_tcp_ports = [0, 65536] }
  expect_failures = [terraform_data.guard]
}
run "subnet_outside_vcn_rejected" {
  command = plan
  variables { oci_subnet_cidr = "192.168.5.0/24" }
  expect_failures = [terraform_data.guard]
}
run "approved_circuit_configuration" {
  command = plan
  variables {
    region_pair_verified = true
    enable_foundation    = true
    enable_interconnect  = true
    costs_approved       = true
    provider_service_id  = "ocid1.providerservice.oc1..verified-example"
    enable_bgp           = true
    activate_attachments = true
    bgp_sessions = {
      primary   = { google_ip_cidr = "169.254.10.1/30", oracle_ip_cidr = "169.254.10.2/30" }
      secondary = { google_ip_cidr = "169.254.20.1/30", oracle_ip_cidr = "169.254.20.2/30" }
    }
  }
  assert {
    condition     = length(oci_core_virtual_circuit.this) == 2 && length(google_compute_router_interface.this) == 2 && length(google_compute_router_peer.this) == 2 && google_compute_router_peer.this["primary"].peer_asn == 31898
    error_message = "Approved circuit topology must include the correct remote pairing configuration."
  }
}
run "invalid_partner_asn_rejected" {
  command = plan
  variables { gcp_router_asn = 64512 }
  expect_failures = [terraform_data.guard]
}
run "missing_bgp_pairs_rejected" {
  command = plan
  variables {
    enable_foundation    = true
    enable_interconnect  = true
    costs_approved       = true
    provider_service_id  = "ocid1.providerservice.oc1..verified-example"
    region_pair_verified = true
  }
  expect_failures = [terraform_data.guard]
}
run "foundation_requires_cost_approval" {
  command = plan
  variables { enable_foundation = true }
  expect_failures = [terraform_data.guard]
}
run "region_pair_must_be_verified" {
  command = plan
  variables {
    enable_foundation   = true
    enable_interconnect = true
    costs_approved      = true
    provider_service_id = "ocid1.providerservice.oc1..verified-example"
  }
  expect_failures = [terraform_data.guard]
}
