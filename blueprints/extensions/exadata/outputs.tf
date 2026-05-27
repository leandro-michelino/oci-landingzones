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
    cloud_exadata_infrastructure = try(oci_database_cloud_exadata_infrastructure.this[0].id, null)
  }
}

output "cloud_exadata_infrastructure_id" {
  description = "Exadata Cloud Infrastructure OCID."
  value       = try(oci_database_cloud_exadata_infrastructure.this[0].id, null)
}
