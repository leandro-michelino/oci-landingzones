# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this blueprint."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint."
  value = {
    dr_evidence_bucket  = try(oci_objectstorage_bucket.dr_evidence[0].id, null)
    dr_alert_topic      = try(oci_ons_notification_topic.dr_alert[0].id, null)
    connectivity_data   = terraform_data.connectivity_contract.id
    dns_failover_data   = try(terraform_data.dns_failover_contract[0].id, null)
    runbook_contract_id = try(terraform_data.runbook_contract[0].id, null)
  }
}

output "primary_target" {
  description = "Primary workload target in this DR variant."
  value = {
    cloud    = "oci"
    endpoint = var.oci_primary_endpoint
  }
}

output "standby_target" {
  description = "Standby workload target in this DR variant."
  value = {
    cloud    = "azure"
    endpoint = var.azure_standby_endpoint
  }
}

output "connectivity_contract" {
  description = "Connectivity mode contract for interconnect or no-interconnect operation."
  value       = local.effective_interconnect
}

output "dns_failover_contract" {
  description = "DNS failover contract metadata for primary/standby cutover."
  value       = var.enable_dns_failover_contract ? local.dns_failover_contract : null
}

output "runbook_contract" {
  description = "Failover and failback runbook contract metadata."
  value       = var.enable_runbook_contract ? local.runbook_contract : null
}

output "dr_evidence_bucket_name" {
  description = "DR evidence bucket name."
  value       = try(oci_objectstorage_bucket.dr_evidence[0].name, null)
}

output "dr_alert_topic_id" {
  description = "DR alert Notifications topic OCID."
  value       = try(oci_ons_notification_topic.dr_alert[0].id, null)
}
