mock_provider "oci" {}
mock_provider "oci" { alias = "home" }

variables {
  tenancy_ocid       = "ocid1.tenancy.oc1..example"
  current_user_ocid  = "ocid1.user.oc1..example"
  compartment_ocid   = "ocid1.compartment.oc1..example"
  region             = "sa-saopaulo-1"
  oci_config_profile = "DEFAULT"
  org                = "test"
  environment        = "dev"
  region_key         = "sao"
}

run "all_creation_disabled_by_default" {
  command = plan

  assert {
    condition     = length(oci_core_vcn.oda) == 0 && length(oci_oda_oda_instance.this) == 0 && length(oci_oda_oda_private_endpoint.this) == 0 && length(oci_oda_oda_private_endpoint_attachment.this) == 0 && length(oci_ons_notification_topic.alert) == 0
    error_message = "ODA defaults must not create network, service, attachment, or topic resources."
  }
}

run "private_backend_network_only" {
  command = plan
  variables {
    enable_oda_network      = true
    oda_egress_allowed_cidr = "10.86.20.0/24"
  }

  assert {
    condition     = length(oci_core_vcn.oda) == 1 && oci_core_subnet.oda[0].prohibit_public_ip_on_vnic && length(oci_core_route_table.oda[0].route_rules) == 0 && length(oci_core_security_list.oda[0].ingress_security_rules) == 0 && length(oci_core_network_security_group_security_rule.oda_egress_all) == 1 && length(oci_oda_oda_instance.this) == 0
    error_message = "The isolated ODA fixture must use a private subnet with scoped outbound HTTPS and no ODA instance."
  }
}

run "reject_network_without_backend_cidr" {
  command = plan
  variables { enable_oda_network = true }
  expect_failures = [var.oda_egress_allowed_cidr]
}
