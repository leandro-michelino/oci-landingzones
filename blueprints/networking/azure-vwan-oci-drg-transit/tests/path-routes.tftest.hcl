mock_provider "oci" {}
variables {
  tenancy_ocid      = "ocid1.tenancy.oc1..example"
  current_user_ocid = "ocid1.user.oc1..example"
  region            = "us-ashburn-1"
  org               = "test"
  environment       = "dev"
  region_key        = "iad"
}
run "no_path_has_no_remote_route" {
  command = plan
  assert {
    condition     = length([for r in oci_core_route_table.primary[0].route_rules : r if r.destination != "0.0.0.0/0"]) == 0 && length(oci_core_ipsec.azure) == 0
    error_message = "No dedicated circuit or VPN must leave remote-prefix routes absent."
  }
}
run "dedicated_path_without_vpn_keeps_routes" {
  command = plan
  variables {
    connectivity_mode              = "interconnect"
    fastconnect_virtual_circuit_id = "ocid1.virtualcircuit.oc1.iad..example"
    expressroute_circuit_id        = "/subscriptions/example/expressRouteCircuits/example"
    azure_virtual_wan_id           = "/subscriptions/example/virtualWans/example"
    azure_virtual_hub_id           = "/subscriptions/example/virtualHubs/example"
  }
  assert {
    condition     = length([for r in oci_core_route_table.primary[0].route_rules : r if r.destination == "10.88.0.0/16"]) == 1 && length(oci_core_ipsec.azure) == 0
    error_message = "Interconnect must keep remote-prefix routes independently of VPN."
  }
}
