# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "networking-aws-oci-hybrid-network-backbone"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)

  backbone_vcn_name    = "${local.name_prefix}-vcn-hybrid-backbone"
  backbone_igw_name    = "${local.name_prefix}-igw-hybrid-backbone"
  backbone_rt_name     = "${local.name_prefix}-rt-hybrid-backbone"
  backbone_sl_name     = "${local.name_prefix}-sl-hybrid-backbone"
  backbone_subnet_name = "${local.name_prefix}-sn-hybrid-backbone"

  drg_name         = "${local.name_prefix}-drg-hybrid-primary"
  drg_attach_name  = "${local.name_prefix}-drga-hybrid-backbone"
  cpe_name         = "${local.name_prefix}-cpe-hybrid-aws"
  ipsec_name       = "${local.name_prefix}-vpn-hybrid-aws"
  alert_topic_name = coalesce(var.backbone_alert_topic_name, "${local.name_prefix}-top-hybrid-alert")

  connectivity_contract = {
    oci_primary                    = var.oci_is_primary
    mode                           = var.connectivity_mode
    fastconnect_virtual_circuit_id = var.fastconnect_virtual_circuit_id
    direct_connect_connection_id   = var.direct_connect_connection_id
    site_to_site_vpn_enabled       = var.enable_site_to_site_vpn
    validation                     = var.connectivity_mode == "interconnect" ? "partner-interconnect-required" : "interconnect-not-required"
  }

  routing_contract = {
    oci_primary = {
      drg_id               = oci_core_drg.primary.id
      backbone_vcn_cidr    = var.oci_backbone_vcn_cidr
      backbone_subnet_cidr = var.oci_backbone_subnet_cidr
    }
    aws_secondary = {
      expected_cidrs = var.aws_backbone_cidrs
    }
  }

  common_freeform_tags = merge(
    {
      Blueprint = local.blueprint_name
      ManagedBy = "terraform"
      Primary   = "oci"
    },
    var.freeform_tags
  )
}
