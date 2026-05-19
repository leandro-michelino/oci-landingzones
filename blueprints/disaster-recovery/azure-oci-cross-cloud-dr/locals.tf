# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "disaster-recovery-azure-oci-cross-cloud-dr"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)

  evidence_bucket_name = coalesce(var.dr_evidence_bucket_name, "${local.name_prefix}-bkt-dr-evidence")
  alert_topic_name     = coalesce(var.dr_alert_topic_name, "${local.name_prefix}-top-dr-alert")
  primary_vcn_name     = "${local.name_prefix}-vcn-dr-primary"
  primary_igw_name     = "${local.name_prefix}-igw-dr-primary"
  primary_rt_name      = "${local.name_prefix}-rt-dr-primary"
  primary_sl_name      = "${local.name_prefix}-sl-dr-primary-app"
  primary_subnet_name  = "${local.name_prefix}-sn-dr-primary-app"

  effective_interconnect = {
    mode                           = var.connectivity_mode
    fastconnect_virtual_circuit_id = var.fastconnect_virtual_circuit_id
    expressroute_circuit_id        = var.expressroute_circuit_id
    validation                     = var.connectivity_mode == "interconnect" ? "partner-path-required" : "interconnect-not-required"
  }

  dns_failover_contract = {
    fqdn         = var.app_fqdn
    routing_mode = "primary-standby"
    primary = {
      cloud       = "oci"
      endpoint    = var.oci_primary_endpoint
      health_path = var.oci_primary_health_path
    }
    secondary = {
      cloud       = "azure"
      endpoint    = var.azure_standby_endpoint
      health_path = var.azure_standby_health_path
    }
    ttl_seconds = var.dns_ttl_seconds
  }

  runbook_contract = {
    drill_frequency = var.dr_drill_frequency
    rto_minutes     = var.target_rto_minutes
    rpo_minutes     = var.target_rpo_minutes
    failover_steps = [
      "validate-primary-health",
      "validate-standby-readiness",
      "switch-dns-to-standby",
      "verify-app-recovery",
      "capture-evidence"
    ]
    failback_steps = [
      "restore-primary",
      "resync-data",
      "switch-dns-to-primary",
      "verify-primary-stability",
      "close-incident"
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
