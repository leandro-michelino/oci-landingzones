mock_provider "oci" {}
mock_provider "oci" { alias = "home" }

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
  require_complete_dr_contracts = false
}

run "private_network_without_paid_or_external_services" {
  command = plan
  variables {
    create_lakehouse_bucket = false
    enable_dr_alert_topic   = false
  }

  assert {
    condition     = length(oci_core_vcn.primary) == 1 && length(oci_core_route_table.primary_db[0].route_rules) == 0 && length(oci_core_ipsec.aws) == 0 && length(oci_mysql_mysql_db_system.primary) == 0 && output.replication_contract.complete == false && length(oci_core_security_list.primary_db[0].ingress_security_rules) == 1 && contains([for rule in oci_core_security_list.primary_db[0].ingress_security_rules : rule.source], "10.74.0.0/16") && !contains([for rule in oci_core_security_list.primary_db[0].ingress_security_rules : rule.source], var.aws_replication_cidr)
    error_message = "A reduced private foundation must omit VPN and AWS replication ingress while marking DR contracts incomplete."
  }
}

run "static_ipsec_uses_cpe_public_ip" {
  command = apply
  variables {
    enable_ipsec_connectivity = true
    aws_cpe_public_ip         = "203.0.113.10"
    create_lakehouse_bucket   = false
    enable_dr_alert_topic     = false
  }

  assert {
    condition     = length(oci_core_ipsec.aws) == 1 && oci_core_ipsec.aws[0].static_routes[0] == var.aws_replication_cidr && oci_core_cpe.aws[0].ip_address == var.aws_cpe_public_ip && output.connectivity_contract.mode == "ipsec-static" && length(oci_core_security_list.primary_db[0].ingress_security_rules) == 2
    error_message = "The optional OCI IPSec leg must use static routes, the CPE public IP, and conditional AWS ingress."
  }
}

run "reject_incomplete_operational_contracts" {
  command = plan
  variables {
    require_complete_dr_contracts = true
    create_lakehouse_bucket       = false
    enable_dr_alert_topic         = false
  }
  expect_failures = [terraform_data.replication_contract, terraform_data.dns_failover_contract]
}

run "reject_blank_oci_endpoint_in_operational_contracts" {
  command = plan
  variables {
    require_complete_dr_contracts = true
    create_lakehouse_bucket       = false
    enable_dr_alert_topic         = false
    oci_primary_endpoint          = "  "
    aws_secondary_endpoint        = "aws.example.test:3306"
  }
  expect_failures = [terraform_data.replication_contract, terraform_data.dns_failover_contract]
}

run "reject_blank_aws_endpoint_in_operational_contracts" {
  command = plan
  variables {
    require_complete_dr_contracts = true
    create_lakehouse_bucket       = false
    enable_dr_alert_topic         = false
    oci_primary_endpoint          = "oci.example.test:3306"
    aws_secondary_endpoint        = "  "
  }
  expect_failures = [terraform_data.replication_contract, terraform_data.dns_failover_contract]
}

run "reject_unattached_ipsec" {
  command = plan
  variables {
    enable_oci_primary_network = false
    enable_ipsec_connectivity  = true
    aws_cpe_public_ip          = "203.0.113.10"
    create_lakehouse_bucket    = false
    enable_dr_alert_topic      = false
  }
  expect_failures = [var.enable_ipsec_connectivity]
}
