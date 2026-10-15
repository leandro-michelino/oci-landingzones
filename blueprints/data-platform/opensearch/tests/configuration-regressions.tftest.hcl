mock_provider "oci" {
  mock_resource "oci_identity_policy" { defaults = { id = "workload-policy" } }
}
mock_provider "oci" {
  alias = "home"
  mock_resource "oci_identity_policy" { defaults = { id = "home-policy" } }
}

variables {
  tenancy_ocid           = "ocid1.tenancy.oc1..example"
  current_user_ocid      = "ocid1.user.oc1..example"
  compartment_ocid       = "ocid1.compartment.oc1..example"
  region                 = "sa-saopaulo-1"
  home_region            = "me-abudhabi-1"
  oci_config_profile     = "DEFAULT"
  org                    = "test"
  environment            = "dev"
  region_key             = "sao"
  create_cluster         = false
  create_private_network = false
  create_snapshot_bucket = false
  vcn_id                 = null
  subnet_id              = null
  nsg_id                 = null
  policy_statements      = []
}

run "disabled_cluster_and_network" {
  command = plan
  assert {
    condition     = length(oci_opensearch_opensearch_cluster.this) == 0 && length(oci_core_vcn.opensearch) == 0
    error_message = "A disabled OpenSearch plan must accept absent network inputs without provisioning a cluster."
  }
}

run "created_network_blocks_default_list_and_limits_clients" {
  command = apply
  variables {
    create_private_network         = true
    allowed_search_client_cidrs    = ["10.85.1.0/24"]
    allowed_dashboard_client_cidrs = ["10.85.2.0/24"]
  }
  assert {
    condition = (
      length(oci_opensearch_opensearch_cluster.this) == 0 &&
      length(oci_core_security_list.opensearch[0].ingress_security_rules) == 0 &&
      toset(oci_core_subnet.opensearch[0].security_list_ids) == toset([oci_core_security_list.opensearch[0].id]) &&
      oci_core_network_security_group_security_rule.search_ingress["10.85.1.0/24"].tcp_options[0].destination_port_range[0].min == 9200 &&
      oci_core_network_security_group_security_rule.dashboard_ingress["10.85.2.0/24"].tcp_options[0].destination_port_range[0].min == 5601
    )
    error_message = "The subnet must avoid the VCN default list and NSG ingress must use distinct approved API and Dashboard ports."
  }
}

run "cluster_requires_complete_existing_network" {
  command = plan
  variables { create_cluster = true }
  expect_failures = [var.create_cluster]
}

run "policy_uses_home_provider" {
  command = apply
  variables {
    policy_statements = ["Allow group MockReaders to read search-family in compartment MockCompartment"]
  }
  assert {
    condition     = oci_identity_policy.access[0].id == "home-policy"
    error_message = "The optional IAM policy must use the tenancy-home OCI provider."
  }
}
