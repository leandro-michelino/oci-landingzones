mock_provider "oci" {
  mock_data "oci_core_services" {
    defaults = {
      services = [{ id = "mock-service", name = "All Mock Services In Oracle Services Network", cidr_block = "all-sao-services-in-oracle-services-network" }]
    }
  }
  mock_data "oci_objectstorage_namespace" { defaults = { namespace = "mocknamespace" } }
}

variables {
  tenancy_ocid                           = "ocid1.tenancy.oc1..example"
  current_user_ocid                      = "ocid1.user.oc1..example"
  compartment_ocid                       = "ocid1.compartment.oc1..example"
  region                                 = "sa-saopaulo-1"
  home_region                            = "me-abudhabi-1"
  oci_config_profile                     = "DEFAULT"
  org                                    = "test"
  environment                            = "dev"
  region_key                             = "sao"
  enable_vault                           = false
  enable_default_vault                   = false
  enable_default_key                     = false
  enable_data_bucket                     = false
  enable_object_storage_private_endpoint = false
  enable_streaming                       = false
  private_endpoint_subnet_id             = null
  private_endpoint_nsg_ids               = []
  streaming_private_endpoint_subnet_id   = null
  streaming_private_endpoint_nsg_ids     = []
}

run "explicit_network_only_mode_has_no_paid_data_services" {
  command = plan
  assert {
    condition = (
      length(module.vault.vault_ids) == 0 &&
      length(module.streaming.stream_ids) == 0 &&
      length(oci_objectstorage_bucket.data) == 0 &&
      length(oci_objectstorage_private_endpoint.data) == 0 &&
      contains(keys(module.network.subnet_ids), "endpoints")
    )
    error_message = "An explicit network-only plan must omit Vault, bucket, endpoint, and Streaming resources."
  }
}

run "private_endpoint_requires_bucket" {
  command = plan
  variables { enable_object_storage_private_endpoint = true }
  expect_failures = [var.enable_object_storage_private_endpoint]
}

run "private_endpoint_uses_approved_https_nsg" {
  command = plan
  variables {
    enable_data_bucket                     = true
    enable_object_storage_private_endpoint = true
    private_endpoint_allowed_client_cidrs  = ["10.20.1.0/24"]
  }
  assert {
    condition = (
      length(oci_core_network_security_group.object_storage_endpoint) == 1 &&
      oci_core_network_security_group_security_rule.object_storage_https_ingress["10.20.1.0/24"].tcp_options[0].destination_port_range[0].min == 443 &&
      length(oci_objectstorage_private_endpoint.data) == 1
    )
    error_message = "The managed Object Storage endpoint must attach an NSG with HTTPS ingress from approved clients."
  }
}

run "streaming_private_endpoint_uses_rest_and_kafka_rules" {
  command = plan
  variables {
    enable_streaming               = true
    streaming_allowed_client_cidrs = ["10.20.1.0/24"]
  }
  assert {
    condition = (
      length(oci_core_network_security_group.streaming_endpoint) == 1 &&
      oci_core_network_security_group_security_rule.streaming_client_ingress["10.20.1.0/24:443"].tcp_options[0].destination_port_range[0].min == 443 &&
      oci_core_network_security_group_security_rule.streaming_client_ingress["10.20.1.0/24:9092"].tcp_options[0].destination_port_range[0].min == 9092
    )
    error_message = "The managed Streaming endpoint must attach approved REST and Kafka client rules."
  }
}
