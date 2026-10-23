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

run "no_oic_services_by_default" {
  command = plan

  assert {
    condition     = length(oci_integration_integration_instance.this) == 0 && length(oci_integration_private_endpoint_outbound_connection.this) == 0
    error_message = "OIC resources must remain disabled by default."
  }
}

run "reject_outbound_without_instance" {
  command = plan
  variables {
    enable_private_outbound_connection = true
    outbound_subnet_id                 = "ocid1.subnet.oc1.sa-saopaulo-1.example"
  }
  expect_failures = [oci_integration_private_endpoint_outbound_connection.this]
}

run "reject_outbound_without_subnet" {
  command = plan
  variables {
    enable_private_outbound_connection = true
    existing_integration_instance_id   = "ocid1.integrationinstance.oc1.sa-saopaulo-1.example"
  }
  expect_failures = [oci_integration_private_endpoint_outbound_connection.this]
}

run "accept_existing_instance_and_subnet" {
  command = plan
  variables {
    enable_private_outbound_connection = true
    existing_integration_instance_id   = "ocid1.integrationinstance.oc1.sa-saopaulo-1.example"
    outbound_subnet_id                 = "ocid1.subnet.oc1.sa-saopaulo-1.example"
  }

  assert {
    condition     = length(oci_integration_integration_instance.this) == 0 && oci_integration_private_endpoint_outbound_connection.this[0].integration_instance_id == var.existing_integration_instance_id
    error_message = "The outbound connection must use the supplied existing OIC instance."
  }
}
