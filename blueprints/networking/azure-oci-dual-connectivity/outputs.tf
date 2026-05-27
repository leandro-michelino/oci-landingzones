output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
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
    connectivity_contract_id      = terraform_data.connectivity_contract.id
    ipsec_fallback_contract_id    = terraform_data.ipsec_fallback_contract.id
    routing_contract_id           = terraform_data.routing_contract.id
    dns_contract_id               = var.enable_dns_contract ? try(terraform_data.dns_contract[0].id, null) : null
    runbook_contract_id           = terraform_data.runbook_contract.id
    oci_primary_vcn_id            = local.effective_primary_vcn_id
    oci_primary_subnet_id         = try(oci_core_subnet.primary_hub[0].id, null)
    oci_primary_route_table_id    = try(oci_core_route_table.primary[0].id, null)
    oci_primary_security_list_id  = try(oci_core_security_list.primary_hub[0].id, null)
    oci_primary_drg_id            = local.effective_primary_drg_id
    oci_primary_drg_attachment_id = try(oci_core_drg_attachment.primary[0].id, null)
    oci_azure_cpe_id              = try(oci_core_cpe.azure[0].id, null)
    oci_azure_ipsec_id            = try(oci_core_ipsec.azure[0].id, null)
    connectivity_alert_topic_id   = try(oci_ons_notification_topic.connectivity_alert[0].id, null)
  }
}

output "connectivity_contract" {
  description = "Connectivity-mode contract with selected topology (`interconnect` or `without-interconnect`) and explicit primary/fallback path intent."
  value       = terraform_data.connectivity_contract.input
}

output "ipsec_fallback_contract" {
  description = "Fallback tunnel and BGP hardening contract used in operations runbooks and troubleshooting drills."
  value       = terraform_data.ipsec_fallback_contract.input
}

output "routing_contract" {
  description = "Cross-cloud routing contract that captures OCI-primary DRG intent, Azure CIDR exchange boundaries, and path preference policy."
  value       = terraform_data.routing_contract.input
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
    drg   = local.effective_primary_drg_id
  }
}

output "azure_secondary_target" {
  description = "Declared secondary path target metadata for Azure-side connectivity operations and route governance."
  value = {
    cloud             = "azure"
    expressroute_id   = var.expressroute_circuit_id
    expected_cidrs    = var.azure_network_cidrs
    ipsec_enabled     = var.enable_ipsec_fallback
    health_probe_fqdn = var.health_probe_fqdn
  }
}

output "connectivity_alert_topic_name" {
  description = "Operations notification topic name for dual-connectivity alarms and lifecycle events; `null` when topic creation is disabled."
  value       = try(oci_ons_notification_topic.connectivity_alert[0].name, null)
}
