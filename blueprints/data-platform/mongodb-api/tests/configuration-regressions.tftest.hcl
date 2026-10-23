mock_provider "oci" {}
mock_provider "oci" { alias = "home" }
variables {
  tenancy_ocid       = "ocid1.tenancy.oc1..example"
  current_user_ocid  = "ocid1.user.oc1..example"
  compartment_ocid   = "ocid1.compartment.oc1..example"
  region             = "sa-saopaulo-1"
  home_region        = "me-abudhabi-1"
  oci_config_profile = "DEFAULT"
  org                = "test"
  environment        = "dev"
  region_key         = "sao"
  # Keep regression defaults independent of an operator's ignored terraform.tfvars.
  enable_mongodb_api_database = false
  create_private_network      = false
}
run "disabled_database_and_network" {
  command = plan
  assert {
    condition     = output.autonomous_database_id == null && length(oci_core_vcn.mongodb_api) == 0
    error_message = "A disabled/public database plan must permit absent private endpoint inputs."
  }
}
run "private_network_without_paid_database" {
  command = plan
  variables {
    create_private_network = true
    allowed_client_cidrs   = ["10.99.0.0/24"]
  }
  assert {
    condition     = length(oci_core_security_list.mongodb_api) == 1 && length(oci_database_autonomous_database.this) == 0 && oci_core_network_security_group_security_rule.mongodb_api_ingress["10.99.0.0/24"].tcp_options[0].destination_port_range[0].min == 27017
    error_message = "The private network must constrain its client rule without creating a paid database."
  }
}
run "always_free_rejects_non_home_region" {
  command = plan
  variables {
    enable_mongodb_api_database = true
    is_free_tier                = true
  }
  expect_failures = [var.is_free_tier]
}
