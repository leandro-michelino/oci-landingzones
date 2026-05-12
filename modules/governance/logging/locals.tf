# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "governance-logging"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

  default_log_groups = {
    audit = {
      display_name = "${local.name_prefix}-lg-audit"
      description  = "Audit-oriented log group for landing zone evidence and saved searches."
    }
    network = {
      display_name = "${local.name_prefix}-lg-network"
      description  = "Network service logs such as VCN flow logs, load balancer logs, and firewall logs."
    }
    service = {
      display_name = "${local.name_prefix}-lg-service"
      description  = "General OCI service logs for the landing zone."
    }
    security = {
      display_name = "${local.name_prefix}-lg-security"
      description  = "Security operations logs and detections."
    }
  }

  log_groups = var.enable_logging ? merge(local.default_log_groups, var.log_groups) : {}

  vcn_flow_service_logs = {
    for key, log in var.vcn_flow_logs : key => {
      log_group_key      = log.log_group_key
      display_name       = log.display_name
      service            = "flowlogs"
      category           = log.category
      resource_id        = log.resource_id
      source_type        = "OCISERVICE"
      compartment_ocid   = log.compartment_ocid
      retention_duration = log.retention_duration
      is_enabled         = log.is_enabled
      parameters         = log.parameters
    }
  }

  service_logs = var.enable_logging ? merge(local.vcn_flow_service_logs, var.service_logs) : {}

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Module = local.module_name
    }
  )
}
