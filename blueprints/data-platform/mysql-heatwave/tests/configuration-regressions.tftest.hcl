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
  create_db_system       = false
  create_private_network = false
}

run "disabled_without_external_subnet" {
  command = plan

  assert {
    condition     = length(oci_core_subnet.mysql) == 0 && output.mysql_db_system_id == null
    error_message = "A disabled MySQL plan must accept absent subnet and DB inputs."
  }
}

run "isolated_private_network_without_database" {
  command = plan
  variables {
    create_private_network = true
    allowed_client_cidrs   = ["10.83.20.0/24"]
  }

  assert {
    condition     = length(oci_core_security_list.mysql) == 1 && length(oci_core_security_list.mysql[0].ingress_security_rules) == 0 && length(oci_core_security_list.mysql[0].egress_security_rules) == 0 && length(oci_core_subnet.mysql[0].security_list_ids) == 1 && length(oci_mysql_mysql_db_system.this) == 0 && contains(keys(output.private_network), "security_list_id") && contains(keys(output.resource_ids), "security_list")
    error_message = "The private subnet must use only its empty security list while the paid DB remains disabled."
  }
}

run "reject_mixed_external_and_new_network" {
  command = plan
  variables {
    create_private_network = true
    subnet_id              = "mock-subnet"
  }
  expect_failures = [var.create_private_network]
}

run "reject_database_without_credentials" {
  command = plan
  variables {
    create_private_network = true
    create_db_system       = true
  }
  expect_failures = [oci_mysql_mysql_db_system.this]
}

run "reject_heatwave_without_database" {
  command = plan
  variables { create_heatwave_cluster = true }
  expect_failures = [oci_mysql_heat_wave_cluster.this]
}
