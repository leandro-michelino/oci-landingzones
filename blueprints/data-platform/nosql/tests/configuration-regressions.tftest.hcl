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
}

run "network_only_without_nosql_table" {
  command = plan
  variables {
    create_table       = false
    create_alert_topic = false
  }

  assert {
    condition     = length(oci_nosql_table.this) == 0 && length(oci_nosql_index.secondary) == 0 && length(oci_nosql_table_replica.this) == 0 && length(oci_core_vcn.app) == 1 && length(oci_core_security_list.app[0].ingress_security_rules) == 0 && length(oci_core_subnet.app[0].security_list_ids) == 1 && output.nosql_table_id == null && output.nosql_table_name == null && output.nosql_capacity_contract == null && output.resource_ids.nosql_table_id == null
    error_message = "A network-only plan must not create NoSQL services or allow unsolicited HTTPS ingress."
  }
}

run "explicit_https_app_ingress" {
  command = plan
  variables {
    create_table             = false
    create_alert_topic       = false
    app_ingress_allowed_cidr = "10.84.20.0/24"
  }

  assert {
    condition     = length(oci_core_security_list.app[0].ingress_security_rules) == 1 && one(oci_core_security_list.app[0].ingress_security_rules).source == "10.84.20.0/24"
    error_message = "App ingress must require an explicit client CIDR."
  }
}

run "table_only_keeps_table_creation" {
  command = plan
  variables {
    enable_app_network = false
    create_alert_topic = false
  }

  assert {
    condition     = length(oci_nosql_table.this) == 1 && length(oci_core_vcn.app) == 0
    error_message = "The existing table-only mode must still create one NoSQL table."
  }
}

run "reject_index_without_table" {
  command = plan
  variables {
    create_table           = false
    create_secondary_index = true
    create_alert_topic     = false
  }
  expect_failures = [var.create_table]
}

run "reject_replica_without_table" {
  command = plan
  variables {
    create_table         = false
    enable_table_replica = true
    create_alert_topic   = false
  }
  expect_failures = [var.create_table]
}
