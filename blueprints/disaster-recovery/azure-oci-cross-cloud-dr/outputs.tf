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
    oci_network_contract = terraform_data.oci_network_contract.id
    oci_primary_vcn      = try(oci_core_vcn.primary[0].id, null)
    oci_primary_rt       = try(oci_core_route_table.primary[0].id, null)
    oci_primary_sl       = try(oci_core_security_list.primary_app[0].id, null)
    oci_primary_subnet   = try(oci_core_subnet.primary_app[0].id, null)
    dr_evidence_bucket   = try(oci_objectstorage_bucket.dr_evidence[0].id, null)
    dr_alert_topic       = try(oci_ons_notification_topic.dr_alert[0].id, null)
    connectivity_data    = terraform_data.connectivity_contract.id
    dns_failover_data    = try(terraform_data.dns_failover_contract[0].id, null)
    runbook_contract_id  = try(terraform_data.runbook_contract[0].id, null)
  }
}

output "primary_target" {
  description = "Declared primary workload target for this DR pattern. In this variant OCI remains primary and is the expected steady-state endpoint."
  value = {
    cloud    = "oci"
    endpoint = var.oci_primary_endpoint
  }
}

output "standby_target" {
  description = "Declared standby workload target for failover. In this variant Azure is the secondary endpoint activated by DR runbooks."
  value = {
    cloud    = "azure"
    endpoint = var.azure_standby_endpoint
  }
}

output "connectivity_contract" {
  description = "Connectivity contract recording whether DR traffic is expected through partner interconnect or through the no-interconnect operating mode."
  value       = local.effective_interconnect
}

output "dns_failover_contract" {
  description = "DNS cutover metadata consumed by failover automation and runbooks, including primary/standby records and health-check intent."
  value       = var.enable_dns_failover_contract ? local.dns_failover_contract : null
}

output "runbook_contract" {
  description = "Operational contract for DR execution steps, ownership, and sequencing used by failover and failback procedures."
  value       = var.enable_runbook_contract ? local.runbook_contract : null
}

output "dr_evidence_bucket_name" {
  description = "Object Storage bucket name for DR evidence artifacts such as drill logs, timing reports, approvals, and reconciliation records."
  value       = try(oci_objectstorage_bucket.dr_evidence[0].name, null)
}

output "dr_alert_topic_id" {
  description = "OCI Notifications topic OCID used by DR alarms and runbook event signaling."
  value       = try(oci_ons_notification_topic.dr_alert[0].id, null)
}
