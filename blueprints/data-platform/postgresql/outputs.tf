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
    db_system     = try(oci_psql_db_system.this[0].id, null)
    access_policy = try(oci_identity_policy.access[0].id, null)
  }
}
output "postgresql_db_system_id" {
  description = "PostgreSQL DB system OCID."
  value       = try(oci_psql_db_system.this[0].id, null)
}
output "postgresql_db_system_state" {
  description = "PostgreSQL DB system lifecycle state."
  value       = try(oci_psql_db_system.this[0].state, null)
}
output "postgresql_instances" {
  description = "PostgreSQL DB system instance details returned by OCI."
  value       = try(oci_psql_db_system.this[0].instances, [])
}
output "postgresql_admin_username" {
  description = "PostgreSQL admin username."
  value       = try(oci_psql_db_system.this[0].admin_username, null)
}
output "access_policy_id" {
  description = "Optional IAM policy OCID."
  value       = try(oci_identity_policy.access[0].id, null)
}
