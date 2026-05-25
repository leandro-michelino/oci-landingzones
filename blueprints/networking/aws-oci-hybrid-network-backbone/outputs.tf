# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
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
    routing_contract_id           = terraform_data.routing_contract.id
    oci_backbone_vcn_id           = local.effective_backbone_vcn_id
    oci_backbone_subnet_id        = try(oci_core_subnet.backbone[0].id, null)
    oci_backbone_route_table_id   = try(oci_core_route_table.backbone[0].id, null)
    oci_backbone_security_list_id = try(oci_core_security_list.backbone[0].id, null)
    oci_drg_id                    = local.effective_primary_drg_id
    oci_drg_attachment_id         = try(oci_core_drg_attachment.backbone[0].id, null)
    oci_cpe_id                    = try(oci_core_cpe.aws[0].id, null)
    oci_ipsec_id                  = try(oci_core_ipsec.aws[0].id, null)
    oci_backbone_alert_topic_id   = try(oci_ons_notification_topic.backbone_alert[0].id, null)
  }
}

output "oci_network_contract" {
  description = "OCI-side networking hand-off contract containing effective VCN, subnet, route table, and security list references used by the hybrid backbone."
  value       = terraform_data.oci_network_contract.input
}

output "connectivity_contract" {
  description = "Connectivity-mode contract with selected topology (`interconnect` or `without-interconnect`) plus partner and VPN identifiers used in operations runbooks."
  value       = terraform_data.connectivity_contract.input
}

output "routing_contract" {
  description = "Cross-cloud routing contract that documents DRG intent and approved AWS CIDR exchange boundaries for route governance and troubleshooting."
  value       = terraform_data.routing_contract.input
}

output "oci_drg_id" {
  description = "OCI DRG OCID acting as the primary routing hub for this OCI-first hybrid backbone deployment."
  value       = local.effective_primary_drg_id
}

output "oci_ipsec_id" {
  description = "OCI IPSec connection OCID when site-to-site VPN is enabled; `null` when VPN is intentionally disabled."
  value       = var.enable_site_to_site_vpn ? try(oci_core_ipsec.aws[0].id, null) : null
}

output "backbone_alert_topic_name" {
  description = "Operations notification topic name for hybrid backbone alarms and lifecycle events; `null` when alert topic creation is disabled."
  value       = try(oci_ons_notification_topic.backbone_alert[0].name, null)
}
