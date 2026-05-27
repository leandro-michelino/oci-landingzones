output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Consolidated map of resource identifiers produced by this blueprint."
  value = {
    vcn                 = try(oci_core_vcn.mongodb_api[0].id, null)
    subnet              = try(oci_core_subnet.mongodb_api[0].id, null)
    nsg                 = try(oci_core_network_security_group.mongodb_api[0].id, null)
    autonomous_database = try(oci_database_autonomous_database.this[0].id, null)
    manual_backup       = try(oci_database_autonomous_database_backup.manual[0].id, null)
    access_policy       = try(oci_identity_policy.access[0].id, null)
  }
}

output "private_network" {
  description = "Optional private network resources created by this blueprint."
  value = {
    vcn_id    = try(oci_core_vcn.mongodb_api[0].id, null)
    subnet_id = try(oci_core_subnet.mongodb_api[0].id, null)
    nsg_id    = try(oci_core_network_security_group.mongodb_api[0].id, null)
  }
}

output "autonomous_database_id" {
  description = "Created Autonomous Database OCID."
  value       = try(oci_database_autonomous_database.this[0].id, null)
}

output "autonomous_database_state" {
  description = "Created Autonomous Database lifecycle state."
  value       = try(oci_database_autonomous_database.this[0].state, null)
}

output "mongodb_api_url" {
  description = "MongoDB API URL returned by Autonomous Database."
  value       = try(oci_database_autonomous_database.this[0].connection_urls[0].mongo_db_url, null)
}

output "private_endpoint" {
  description = "Autonomous Database private endpoint FQDN when private endpoint access is configured."
  value       = try(oci_database_autonomous_database.this[0].private_endpoint, null)
}

output "private_endpoint_ip" {
  description = "Autonomous Database private endpoint IP when private endpoint access is configured."
  value       = try(oci_database_autonomous_database.this[0].private_endpoint_ip, null)
}

output "service_console_url" {
  description = "Autonomous Database service console URL."
  value       = try(oci_database_autonomous_database.this[0].service_console_url, null)
}

output "manual_backup_id" {
  description = "Optional manual backup OCID."
  value       = try(oci_database_autonomous_database_backup.manual[0].id, null)
}

output "access_policy_id" {
  description = "Optional IAM access policy OCID."
  value       = try(oci_identity_policy.access[0].id, null)
}
