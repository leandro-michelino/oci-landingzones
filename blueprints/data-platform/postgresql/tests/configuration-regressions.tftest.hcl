mock_provider "oci" {
  mock_resource "oci_identity_policy" { defaults = { id = "workload-policy" } }
}
mock_provider "oci" {
  alias = "home"
  mock_resource "oci_identity_policy" { defaults = { id = "home-policy" } }
}

variables {
  tenancy_ocid                  = "ocid1.tenancy.oc1..example"
  current_user_ocid             = "ocid1.user.oc1..example"
  compartment_ocid              = "ocid1.compartment.oc1..example"
  region                        = "sa-saopaulo-1"
  home_region                   = "me-abudhabi-1"
  oci_config_profile            = "DEFAULT"
  org                           = "test"
  environment                   = "dev"
  region_key                    = "sao"
  enable_db_system              = false
  create_private_network        = false
  subnet_id                     = null
  nsg_ids                       = []
  admin_password                = null
  admin_password_type           = "PLAIN_TEXT" # gitleaks:allow - credential mode enum, no secret value
  admin_password_secret_id      = null
  admin_password_secret_version = null
  is_regionally_durable         = true
  policy_statements             = []
}

run "disabled_database_and_network" {
  command = plan
  assert {
    condition     = length(oci_psql_db_system.this) == 0 && length(oci_core_vcn.postgresql) == 0
    error_message = "A disabled PostgreSQL plan must accept absent subnet and credential inputs."
  }
}

run "network_without_paid_database" {
  command = apply
  variables {
    create_private_network = true
    allowed_client_cidrs   = ["10.81.1.0/24"]
  }
  assert {
    condition = (
      length(oci_psql_db_system.this) == 0 &&
      length(oci_core_security_list.postgresql[0].ingress_security_rules) == 0 &&
      toset(oci_core_subnet.postgresql[0].security_list_ids) == toset([oci_core_security_list.postgresql[0].id]) &&
      oci_core_network_security_group_security_rule.postgresql_ingress["10.81.1.0/24"].tcp_options[0].destination_port_range[0].min == 5432
    )
    error_message = "The private subnet must exclude the default list and only expose PostgreSQL through the approved NSG rule."
  }
}

run "database_requires_approved_network" {
  command = plan
  variables {
    enable_db_system = true
    admin_password   = "mock-material" # gitleaks:allow - synthetic test fixture, not a credential
  }
  expect_failures = [var.enable_db_system]
}

run "database_requires_credential_source" {
  command = plan
  variables {
    enable_db_system       = true
    create_private_network = true
  }
  expect_failures = [var.enable_db_system]
}

run "policy_uses_home_provider" {
  command = apply
  variables {
    policy_statements = ["Allow group MockDBAs to read postgres-db-systems in compartment MockCompartment"]
  }
  assert {
    condition     = oci_identity_policy.access[0].id == "home-policy"
    error_message = "The optional PostgreSQL IAM policy must use the tenancy-home OCI provider."
  }
}
