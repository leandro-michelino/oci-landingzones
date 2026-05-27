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
    vcn           = try(oci_core_vcn.postgresql[0].id, null)
    subnet        = try(oci_core_subnet.postgresql[0].id, null)
    nsg           = try(oci_core_network_security_group.postgresql[0].id, null)
    db_system     = try(oci_psql_db_system.this[0].id, null)
    access_policy = try(oci_identity_policy.access[0].id, null)
  }
}
output "private_network" {
  description = "Optional private network resources created by this blueprint."
  value = {
    vcn_id    = try(oci_core_vcn.postgresql[0].id, null)
    subnet_id = try(oci_core_subnet.postgresql[0].id, null)
    nsg_id    = try(oci_core_network_security_group.postgresql[0].id, null)
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
output "postgresql_primary_endpoint" {
  description = "Primary PostgreSQL private endpoint returned by OCI."
  value       = try(data.oci_psql_db_system_connection_detail.this[0].primary_db_endpoint[0], null)
}
output "postgresql_instance_endpoints" {
  description = "PostgreSQL instance private endpoints returned by OCI."
  value       = try(data.oci_psql_db_system_connection_detail.this[0].instance_endpoints, [])
}
output "postgresql_reader_endpoint" {
  description = "Reader PostgreSQL private endpoint returned by OCI when enabled."
  value       = try(data.oci_psql_db_system_connection_detail.this[0].reader_endpoint[0], null)
}
output "postgresql_admin_username" {
  description = "PostgreSQL admin username."
  value       = try(oci_psql_db_system.this[0].admin_username, null)
}
output "access_policy_id" {
  description = "Optional IAM policy OCID."
  value       = try(oci_identity_policy.access[0].id, null)
}
