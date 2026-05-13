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
