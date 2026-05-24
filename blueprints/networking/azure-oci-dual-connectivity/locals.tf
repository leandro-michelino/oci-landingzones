# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "networking-azure-oci-dual-connectivity"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)

  primary_vcn_name    = "${local.name_prefix}-vcn-azure-connectivity"
  primary_igw_name    = "${local.name_prefix}-igw-azure-connectivity"
  primary_rt_name     = "${local.name_prefix}-rt-azure-connectivity"
  primary_sl_name     = "${local.name_prefix}-sl-azure-connectivity"
  primary_subnet_name = "${local.name_prefix}-sn-azure-connectivity"

  drg_name                = "${local.name_prefix}-drg-azure-primary"
  drg_attachment_name     = "${local.name_prefix}-drga-azure-primary"
  cpe_name                = "${local.name_prefix}-cpe-azure-fallback"
  ipsec_name              = "${local.name_prefix}-vpn-azure-fallback"
  connectivity_topic_name = coalesce(var.connectivity_alert_topic_name, "${local.name_prefix}-top-azure-connectivity")

  effective_interconnect = {
    mode                           = var.connectivity_mode
    oci_is_primary                 = var.oci_is_primary
    fastconnect_virtual_circuit_id = var.fastconnect_virtual_circuit_id
    expressroute_circuit_id        = var.expressroute_circuit_id
    preferred_path                 = var.connectivity_mode == "interconnect" ? "interconnect" : "ipsec-bgp"
    fallback_path                  = var.enable_ipsec_fallback ? "ipsec-bgp" : "none"
  }

  ipsec_fallback_contract = {
    enabled              = var.enable_ipsec_fallback
    azure_cpe_public_ip  = var.azure_cpe_public_ip
    azure_bgp_asn        = var.azure_bgp_asn
    expected_azure_cidrs = var.azure_network_cidrs
    bgp_keepalive_secs   = var.bgp_keepalive_seconds
    bgp_hold_secs        = var.bgp_hold_seconds
  }

  routing_contract = {
    primary_cloud = "oci"
    oci = {
      drg_id               = oci_core_drg.primary.id
      vcn_cidr             = var.oci_primary_vcn_cidr
      hub_subnet_cidr      = var.oci_primary_hub_subnet_cidr
      route_exchange_model = "bgp"
    }
    azure = {
      advertised_cidrs = var.azure_network_cidrs
      asn              = var.azure_bgp_asn
    }
    path_policy = {
      primary_path_weight  = 100
      fallback_path_weight = var.enable_ipsec_fallback ? 20 : 0
      failback_mode        = "operator-controlled"
    }
  }

  dns_contract = {
    enabled                  = var.enable_dns_contract
    private_zone_fqdn        = var.private_dns_zone_fqdn
    health_probe_fqdn        = var.health_probe_fqdn
    oci_dns_resolver         = var.oci_dns_resolver_endpoint
    azure_dns_resolver       = var.azure_dns_resolver_endpoint
    failover_target_seconds  = var.target_failover_seconds
    preferred_resolution_hub = "oci"
  }

  runbook_contract = {
    failover_target_seconds = var.target_failover_seconds
    failover_steps = [
      "detect-interconnect-degradation",
      "validate-ipsec-bgp-health",
      "shift-route-preference-to-fallback",
      "validate-application-probes",
      "record-incident-evidence"
    ]
    failback_steps = [
      "validate-interconnect-recovery",
      "shift-route-preference-to-interconnect",
      "validate-end-to-end-probes",
      "close-fallback-incident"
    ]
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
