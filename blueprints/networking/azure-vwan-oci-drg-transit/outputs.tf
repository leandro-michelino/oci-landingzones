# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Stable blueprint identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Consolidated map of resource and contract identifiers produced by this blueprint; use it as the primary machine-readable hand-off for integration and runbook steps."
  value = {
    oci_network_contract_id       = terraform_data.oci_network_contract.id
    interconnect_contract_id      = terraform_data.interconnect_contract.id
    ipsec_fallback_contract_id    = terraform_data.ipsec_fallback_contract.id
    transit_contract_id           = terraform_data.transit_contract.id
    dns_contract_id               = var.enable_dns_contract ? try(terraform_data.dns_contract[0].id, null) : null
    runbook_contract_id           = terraform_data.runbook_contract.id
    oci_primary_vcn_id            = try(oci_core_vcn.primary[0].id, null)
    oci_primary_subnet_id         = try(oci_core_subnet.primary_hub[0].id, null)
    oci_primary_route_table_id    = try(oci_core_route_table.primary[0].id, null)
    oci_primary_security_list_id  = try(oci_core_security_list.primary_hub[0].id, null)
    oci_primary_drg_id            = local.primary_drg_id
    oci_primary_drg_attachment_id = try(oci_core_drg_attachment.primary[0].id, null)
    oci_azure_cpe_id              = try(oci_core_cpe.azure[0].id, null)
    oci_azure_ipsec_id            = try(oci_core_ipsec.azure[0].id, null)
    transit_alert_topic_id        = try(oci_ons_notification_topic.transit_alert[0].id, null)
  }
}

output "interconnect_contract" {
  description = "Interconnect mode contract with selected topology (`interconnect` or `without-interconnect`) and explicit primary/fallback path intent."
  value       = terraform_data.interconnect_contract.input
}

output "ipsec_fallback_contract" {
  description = "Fallback tunnel and BGP hardening contract used in runbooks and troubleshooting drills."
  value       = terraform_data.ipsec_fallback_contract.input
}

output "transit_contract" {
  description = "Cross-cloud transit contract that captures OCI-primary DRG intent, Azure vWAN and vHub metadata, segment boundaries, and path preference policy."
  value       = terraform_data.transit_contract.input
}

output "dns_contract" {
  description = "DNS forwarding and health-probe contract for cross-cloud resolution and failback decisions."
  value       = var.enable_dns_contract ? local.dns_contract : null
}

output "runbook_contract" {
  description = "Operational contract with failover and failback sequence for interconnect-primary and IPSec fallback path control."
  value       = local.runbook_contract
}

output "oci_primary_target" {
  description = "Declared primary routing target for this pattern. OCI remains the primary control and data-path hub."
  value = {
    cloud = "oci"
    drg   = local.primary_drg_id
  }
}

output "azure_secondary_target" {
  description = "Declared Azure transit metadata for route governance and runbook handoff."
  value = {
    cloud              = "azure"
    virtual_wan_id     = var.azure_virtual_wan_id
    virtual_hub_id     = var.azure_virtual_hub_id
    expressroute_id    = var.expressroute_circuit_id
    expected_cidrs     = var.azure_network_cidrs
    ipsec_enabled      = var.enable_ipsec_fallback
    virtual_hub_region = var.azure_virtual_hub_region
    health_probe_fqdn  = var.health_probe_fqdn
    route_table_name   = var.azure_route_table_name
    route_segmentation = var.enable_route_segmentation
  }
}

output "transit_alert_topic_name" {
  description = "Operations notification topic name for transit alarms and lifecycle events; null when topic creation is disabled."
  value       = try(oci_ons_notification_topic.transit_alert[0].name, null)
}
