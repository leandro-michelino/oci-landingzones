mock_provider "google" {}
variables {
  project_id = "example-project"
  region     = "southamerica-east1"
  name       = "example-test"
}
run "disabled" {
  command = plan
  assert {
    condition     = length(google_compute_network.this) == 0 && length(google_compute_router_nat.this) == 0
    error_message = "Default fixtures must not create cloud networks or NAT."
  }
}
run "approval_required" {
  command = plan
  variables { enabled = true }
  expect_failures = [terraform_data.guard]
}
run "private_scoped" {
  command = plan
  variables {
    enabled           = true
    costs_approved    = true
    peer_cidrs        = ["10.95.10.0/24"]
    allowed_tcp_ports = [443]
  }
  assert {
    condition     = google_compute_network.this[0].delete_default_routes_on_create && google_compute_subnetwork.this[0].private_ip_google_access && length(google_compute_route.egress) == 0 && google_compute_firewall.peer[0].source_ranges == toset(["10.95.10.0/24"])
    error_message = "Network must retain explicit route ownership and scoped ingress."
  }
}
run "invalid_port" {
  command = plan
  variables { allowed_tcp_ports = [65536] }
  expect_failures = [terraform_data.guard]
}
