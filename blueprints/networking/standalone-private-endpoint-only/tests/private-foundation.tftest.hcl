mock_provider "oci" {
  mock_data "oci_core_services" {
    defaults = {
      services = [{ id = "mock-service", name = "All Mock Services In Oracle Services Network", cidr_block = "all-gru-services-in-oracle-services-network" }]
    }
  }
}

variables {
  tenancy_ocid       = "ocid1.tenancy.oc1..example"
  current_user_ocid  = "ocid1.user.oc1..example"
  compartment_ocid   = "ocid1.compartment.oc1..example"
  region             = "sa-saopaulo-1"
  oci_config_profile = "DEFAULT"
  org                = "test"
  environment        = "dev"
  region_key         = "sao"
  enable_nat_gateway = false
}

run "default_foundation_has_no_internet_gateway_or_nat" {
  command = plan

  assert {
    condition = (
      output.gateway_ids.internet == null &&
      output.gateway_ids.nat == null &&
      keys(output.route_table_ids) == ["private"] &&
      keys(output.subnet_ids) == ["app", "data", "endpoints"]
    )
    error_message = "The default private foundation must expose only private subnets and routing, without internet or NAT gateways."
  }
}
