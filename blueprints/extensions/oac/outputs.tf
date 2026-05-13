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
