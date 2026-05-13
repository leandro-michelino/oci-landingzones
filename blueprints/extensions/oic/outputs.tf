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
    integration_instance = try(oci_integration_integration_instance.this[0].id, null)
    outbound_connection  = try(oci_integration_private_endpoint_outbound_connection.this[0].id, null)
  }
}
output "integration_instance_id" {
  description = "OIC instance OCID."
  value       = local.integration_instance_id
}
output "outbound_connection_id" {
  description = "OIC private outbound connection OCID."
  value       = try(oci_integration_private_endpoint_outbound_connection.this[0].id, null)
}
