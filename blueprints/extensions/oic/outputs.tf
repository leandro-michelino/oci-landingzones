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
