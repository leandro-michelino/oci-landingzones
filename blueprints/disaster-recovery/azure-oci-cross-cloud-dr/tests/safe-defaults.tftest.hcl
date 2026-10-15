mock_provider "oci" {}

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

run "disabled_fixture_creates_no_oci_resources" {
  command = plan
  variables {
    enable_oci_primary_network   = false
    enable_dr_evidence_bucket    = false
    enable_dr_alert_topic        = false
    enable_dns_failover_contract = false
    connectivity_mode            = "without-interconnect"
  }

  assert {
    condition = (
      length(oci_core_vcn.primary) == 0 &&
      length(oci_core_subnet.primary_app) == 0 &&
      length(data.oci_objectstorage_namespace.this) == 0 &&
      length(oci_objectstorage_bucket.dr_evidence) == 0 &&
      length(oci_ons_notification_topic.dr_alert) == 0 &&
      output.connectivity_contract.mode == "without-interconnect" &&
      output.dns_failover_contract == null
    )
    error_message = "The explicitly disabled fixture must not create OCI resources or claim DNS failover."
  }
}

run "network_requires_explicit_ingress_cidr" {
  command = plan
  variables {
    enable_oci_primary_network   = true
    enable_dr_evidence_bucket    = false
    enable_dr_alert_topic        = false
    enable_dns_failover_contract = false
    connectivity_mode            = "without-interconnect"
  }
  expect_failures = [var.oci_primary_ingress_allowed_cidr]
}

run "opted_in_network_has_explicit_ingress" {
  command = plan
  variables {
    enable_oci_primary_network       = true
    oci_primary_ingress_allowed_cidr = "203.0.113.8/32"
    enable_dr_evidence_bucket        = false
    enable_dr_alert_topic            = false
    enable_dns_failover_contract     = false
    connectivity_mode                = "without-interconnect"
  }

  assert {
    condition = (
      length(oci_core_vcn.primary) == 1 &&
      length(oci_core_subnet.primary_app) == 1 &&
      alltrue([for rule in oci_core_security_list.primary_app[0].ingress_security_rules : rule.source == "203.0.113.8/32"])
    )
    error_message = "Opted-in OCI networking must use the caller's explicit source CIDR."
  }
}

run "interconnect_requires_both_ids" {
  command = plan
  variables {
    enable_oci_primary_network   = false
    enable_dr_evidence_bucket    = false
    enable_dr_alert_topic        = false
    enable_dns_failover_contract = false
    connectivity_mode            = "interconnect"
  }
  expect_failures = [terraform_data.connectivity_contract]
}

run "dns_contract_requires_both_endpoints" {
  command = plan
  variables {
    enable_oci_primary_network   = false
    enable_dr_evidence_bucket    = false
    enable_dr_alert_topic        = false
    enable_dns_failover_contract = true
    connectivity_mode            = "without-interconnect"
  }
  expect_failures = [terraform_data.dns_failover_contract]
}

run "dns_contract_rejects_blank_primary_endpoint" {
  command = plan
  variables {
    enable_oci_primary_network   = false
    enable_dr_evidence_bucket    = false
    enable_dr_alert_topic        = false
    enable_dns_failover_contract = true
    connectivity_mode            = "without-interconnect"
    oci_primary_endpoint         = "  "
    azure_standby_endpoint       = "azure.example.test"
  }
  expect_failures = [terraform_data.dns_failover_contract]
}

run "dns_contract_rejects_blank_standby_endpoint" {
  command = plan
  variables {
    enable_oci_primary_network   = false
    enable_dr_evidence_bucket    = false
    enable_dr_alert_topic        = false
    enable_dns_failover_contract = true
    connectivity_mode            = "without-interconnect"
    oci_primary_endpoint         = "oci.example.test"
    azure_standby_endpoint       = "  "
  }
  expect_failures = [terraform_data.dns_failover_contract]
}

run "complete_contract_is_metadata_only" {
  command = plan
  variables {
    enable_oci_primary_network     = false
    enable_dr_evidence_bucket      = false
    enable_dr_alert_topic          = false
    connectivity_mode              = "interconnect"
    fastconnect_virtual_circuit_id = "mock-fastconnect-id"
    expressroute_circuit_id        = "mock-peer-circuit-id"
    enable_dns_failover_contract   = true
    app_fqdn                       = "app.example.test"
    oci_primary_endpoint           = "oci.example.test"
    azure_standby_endpoint         = "azure.example.test"
  }

  assert {
    condition = (
      length(oci_core_vcn.primary) == 0 &&
      length(oci_objectstorage_bucket.dr_evidence) == 0 &&
      output.connectivity_contract.mode == "interconnect" &&
      output.dns_failover_contract.secondary.endpoint == "azure.example.test"
    )
    error_message = "Complete connectivity and DNS inputs produce contracts without provisioning networking or DNS."
  }
}
