mock_provider "oci" {}
variables {
  tenancy_ocid             = "ocid1.tenancy.oc1..example"
  current_user_ocid        = "ocid1.user.oc1..example"
  region                   = "us-ashburn-1"
  org                      = "test"
  environment              = "dev"
  region_key               = "iad"
  network_load_balancer_id = "ocid1.networkloadbalancer.oc1.iad..example"
}
run "disabled_root" {
  command = plan
  assert {
    condition     = length(oci_network_load_balancer_network_load_balancer.this) == 0 && length(oci_network_load_balancer_backend.this) == 0
    error_message = "The default NLB root must not create a load balancer or targets."
  }
}
run "distinct_backend_keys_retained" {
  command = plan
  variables {
    backend_sets = {
      a = { health_checker = { protocol = "TCP", port = 443 }, backends = { first = { ip_address = "10.0.1.10", port = 443 } } }
      b = { health_checker = { protocol = "TCP", port = 443 }, backends = { first = { ip_address = "10.0.2.10", port = 443 } } }
    }
  }
  assert {
    condition     = length(oci_network_load_balancer_backend.this) == 2
    error_message = "Both unique backend identities must remain in the plan."
  }
}
run "ambiguous_backend_keys_rejected" {
  command = plan
  variables {
    backend_sets = {
      a-b = { health_checker = { protocol = "TCP", port = 443 }, backends = { c = { ip_address = "10.0.1.10", port = 443 } } }
      a   = { health_checker = { protocol = "TCP", port = 443 }, backends = { b-c = { ip_address = "10.0.2.10", port = 443 } } }
    }
  }
  expect_failures = [var.backend_sets]
}
