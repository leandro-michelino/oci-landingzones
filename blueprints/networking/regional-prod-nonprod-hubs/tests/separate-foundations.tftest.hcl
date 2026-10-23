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
}

run "prod_and_nonprod_export_separate_hubs_and_drgs" {
  command = plan

  assert {
    condition = (
      module.prod_network.name_prefix != module.nonprod_network.name_prefix &&
      contains(keys(output.resource_ids), "prod_hub_vcn") &&
      contains(keys(output.resource_ids), "prod_drg") &&
      contains(keys(output.resource_ids), "nonprod_hub_vcn") &&
      contains(keys(output.resource_ids), "nonprod_drg")
    )
    error_message = "Production and nonproduction must expose distinct named hub and DRG foundations."
  }
}
