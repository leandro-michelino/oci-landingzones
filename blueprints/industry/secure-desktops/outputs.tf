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
  description = "Map of resource identifiers created or referenced by this blueprint."
  value = {
    desktop_pool  = local.desktop_pool_id
    alarms        = { for key, alarm in oci_monitoring_alarm.this : key => alarm.id }
    access_policy = try(oci_identity_policy.access[0].id, null)
  }
}
output "desktop_pool_id" {
  description = "Secure Desktops pool OCID."
  value       = local.desktop_pool_id
}
output "desktop_pool_state" {
  description = "Desktop pool state when Terraform creates it."
  value       = try(oci_desktops_desktop_pool.this[0].state, null)
}
output "desktop_pool_active_desktops" {
  description = "Active desktop count when Terraform creates the pool."
  value       = try(oci_desktops_desktop_pool.this[0].active_desktops, null)
}
output "alarm_ids" {
  description = "Monitoring alarm OCIDs keyed by logical name."
  value       = { for key, alarm in oci_monitoring_alarm.this : key => alarm.id }
}
output "access_policy_id" {
  description = "IAM policy OCID for Secure Desktops access."
  value       = try(oci_identity_policy.access[0].id, null)
}
