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
