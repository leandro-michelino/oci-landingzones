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
    autonomous_database = try(oci_database_autonomous_database.this[0].id, null)
    manual_backup       = try(oci_database_autonomous_database_backup.manual[0].id, null)
  }
}
output "autonomous_database_id" {
  description = "Created Autonomous Database OCID."
  value       = try(oci_database_autonomous_database.this[0].id, null)
}
output "autonomous_database_connection_strings" {
  description = "Connection string profiles returned by Autonomous Database."
  value       = try(oci_database_autonomous_database.this[0].connection_strings, null)
}
output "manual_backup_id" {
  description = "Optional manual backup OCID."
  value       = try(oci_database_autonomous_database_backup.manual[0].id, null)
}
