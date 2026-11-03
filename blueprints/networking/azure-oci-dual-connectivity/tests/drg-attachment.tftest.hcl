mock_provider "oci" {}

variables {
  tenancy_ocid                    = "ocid1.tenancy.oc1..example"
  current_user_ocid               = "ocid1.user.oc1..example"
  compartment_ocid                = "ocid1.compartment.oc1..example"
  region                          = "sa-saopaulo-1"
  oci_config_profile              = "DEFAULT"
  org                             = "test"
  environment                     = "dev"
  region_key                      = "sao"
  enable_ipsec_fallback           = false
  enable_connectivity_alert_topic = false
  enable_dns_contract             = false
}

run "new_vcn_and_drg_plan_together" {
  command = plan

  assert {
    condition     = length(oci_core_drg_attachment.primary) == 1
    error_message = "A new VCN and DRG must plan their attachment without staged applies."
  }
}

run "attachment_can_be_disabled" {
  command = plan

  variables {
    attach_oci_primary_vcn_to_drg = false
  }

  assert {
    condition     = length(oci_core_drg_attachment.primary) == 0
    error_message = "The explicit attachment toggle must disable creation."
  }
}

run "interconnect_without_vpn_keeps_routes" {
  command = plan
  variables {
    connectivity_mode              = "interconnect"
    fastconnect_virtual_circuit_id = "ocid1.virtualcircuit.oc1.jnb..example"
    expressroute_circuit_id        = "/subscriptions/example/resourceGroups/example/providers/Microsoft.Network/expressRouteCircuits/example"
  }
  assert {
    condition     = length([for r in oci_core_route_table.primary[0].route_rules : r if r.destination == "10.88.0.0/16"]) == 1 && length(oci_core_ipsec.azure) == 0
    error_message = "Interconnect needs remote-prefix routes even with VPN fallback disabled."
  }
}
