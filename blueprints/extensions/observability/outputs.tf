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
    log_analytics_namespace = try(oci_log_analytics_namespace.this[0].id, null)
    log_group               = try(oci_log_analytics_log_analytics_log_group.this[0].id, null)
    apm_domain              = try(oci_apm_apm_domain.this[0].id, null)
    opsi_private_endpoint   = try(oci_opsi_operations_insights_private_endpoint.this[0].id, null)
  }
}
output "log_analytics_namespace" {
  description = "Log Analytics namespace used by this deployment."
  value       = local.log_analytics_namespace
}
output "log_group_id" {
  description = "Log Analytics log group OCID."
  value       = try(oci_log_analytics_log_analytics_log_group.this[0].id, null)
}
output "apm_domain_id" {
  description = "APM domain OCID."
  value       = try(oci_apm_apm_domain.this[0].id, null)
}
output "opsi_private_endpoint_id" {
  description = "Operations Insights private endpoint OCID."
  value       = try(oci_opsi_operations_insights_private_endpoint.this[0].id, null)
}
