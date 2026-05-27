locals {
  blueprint_name          = "networking-azure-vwan-oci-drg-transit"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  primary_drg_id          = coalesce(var.existing_drg_id, try(oci_core_drg.primary[0].id, null))

  primary_vcn_name    = "${local.name_prefix}-vcn-azure-vwan-transit"
  primary_igw_name    = "${local.name_prefix}-igw-azure-vwan-transit"
  primary_rt_name     = "${local.name_prefix}-rt-azure-vwan-transit"
  primary_sl_name     = "${local.name_prefix}-sl-azure-vwan-transit"
  primary_subnet_name = "${local.name_prefix}-sn-azure-vwan-transit"

  drg_name            = "${local.name_prefix}-drg-azure-transit-primary"
  drg_attachment_name = "${local.name_prefix}-drga-azure-transit-primary"
  cpe_name            = "${local.name_prefix}-cpe-azure-transit-fallback"
  ipsec_name          = "${local.name_prefix}-vpn-azure-transit-fallback"
  transit_topic_name  = coalesce(var.transit_alert_topic_name, "${local.name_prefix}-top-azure-vwan-transit")

  interconnect_contract = {
    mode                           = var.connectivity_mode
    oci_is_primary                 = var.oci_is_primary
    fastconnect_virtual_circuit_id = var.fastconnect_virtual_circuit_id
    expressroute_circuit_id        = var.expressroute_circuit_id
    azure_virtual_wan_id           = var.azure_virtual_wan_id
    azure_virtual_hub_id           = var.azure_virtual_hub_id
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

  transit_contract = {
    primary_cloud = "oci"
    oci = {
      drg_id               = local.primary_drg_id
      vcn_cidr             = var.oci_primary_vcn_cidr
      hub_subnet_cidr      = var.oci_primary_hub_subnet_cidr
      route_exchange_model = "bgp"
    }
    azure = {
      virtual_wan_id          = var.azure_virtual_wan_id
      virtual_hub_id          = var.azure_virtual_hub_id
      virtual_hub_region      = var.azure_virtual_hub_region
      virtual_hub_cidr        = var.azure_virtual_hub_address_prefix
      virtual_hub_route_table = var.azure_route_table_name
      advertised_cidrs        = var.azure_network_cidrs
      asn                     = var.azure_bgp_asn
    }
    segmentation = {
      enabled    = var.enable_route_segmentation
      prod       = var.transit_segments.prod
      nonprod    = var.transit_segments.nonprod
      management = var.transit_segments.management
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
    convergence_target_secs  = var.target_convergence_seconds
    preferred_resolution_hub = "oci"
  }

  runbook_contract = {
    convergence_target_seconds = var.target_convergence_seconds
    failover_steps = [
      "detect-interconnect-degradation",
      "validate-vhub-and-ipsec-health",
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
