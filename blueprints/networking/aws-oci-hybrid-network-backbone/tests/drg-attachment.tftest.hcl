mock_provider "oci" {}

variables {
  tenancy_ocid                = "ocid1.tenancy.oc1..example"
  current_user_ocid           = "ocid1.user.oc1..example"
  compartment_ocid            = "ocid1.compartment.oc1..example"
  region                      = "sa-saopaulo-1"
  oci_config_profile          = "DEFAULT"
  org                         = "test"
  environment                 = "dev"
  region_key                  = "sao"
  enable_site_to_site_vpn     = false
  enable_backbone_alert_topic = false
}

run "new_vcn_and_drg_plan_together" {
  command = plan

  assert {
    condition     = length(oci_core_drg_attachment.backbone) == 1
    error_message = "A new VCN and DRG must plan their attachment without staged applies."
  }
}

run "attachment_can_be_disabled" {
  command = plan

  variables {
    attach_oci_backbone_vcn_to_drg = false
  }

  assert {
    condition     = length(oci_core_drg_attachment.backbone) == 0
    error_message = "The explicit attachment toggle must disable creation."
  }
}

run "managed_interconnect_without_vpn_keeps_routes" {
  command = plan
  variables {
    region                         = "us-ashburn-1"
    aws_region                     = "us-east-1"
    connectivity_mode              = "managed-interconnect"
    fastconnect_virtual_circuit_id = "ocid1.virtualcircuit.oc1.iad..example"
    aws_interconnect_id            = "example-activated-interconnect"
  }
  assert {
    condition     = length([for r in oci_core_route_table.backbone[0].route_rules : r if r.destination == "10.94.0.0/16"]) == 1 && length(oci_core_ipsec.aws) == 0
    error_message = "Managed Interconnect needs remote-prefix routes even with VPN disabled."
  }
}
run "managed_pair_rejects_madrid" {
  command = plan
  variables {
    region                         = "eu-madrid-1"
    aws_region                     = "us-east-1"
    connectivity_mode              = "managed-interconnect"
    fastconnect_virtual_circuit_id = "ocid1.virtualcircuit.oc1..example"
    aws_interconnect_id            = "example-activated-interconnect"
  }
  expect_failures = [terraform_data.connectivity_contract]
}
run "partner_interconnect_without_vpn_keeps_routes" {
  command = plan
  variables {
    connectivity_mode              = "interconnect"
    fastconnect_virtual_circuit_id = "ocid1.virtualcircuit.oc1..example"
    direct_connect_connection_id   = "dxcon-example"
  }
  assert {
    condition     = length([for r in oci_core_route_table.backbone[0].route_rules : r if r.destination == "10.94.0.0/16"]) == 1
    error_message = "Partner Interconnect needs Internet and remote-prefix routes without VPN."
  }
}
