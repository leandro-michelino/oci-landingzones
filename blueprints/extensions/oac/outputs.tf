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
    analytics_instance     = try(oci_analytics_analytics_instance.this[0].id, null)
    private_access_channel = try(oci_analytics_analytics_instance_private_access_channel.this[0].id, null)
  }
}
output "analytics_instance_id" {
  description = "OAC instance OCID."
  value       = local.analytics_instance_id
}
output "private_access_channel_id" {
  description = "OAC private access channel OCID."
  value       = try(oci_analytics_analytics_instance_private_access_channel.this[0].id, null)
}
