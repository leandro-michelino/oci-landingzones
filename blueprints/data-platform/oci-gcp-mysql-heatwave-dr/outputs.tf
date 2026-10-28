output "blueprint_name" {
  description = "Stable blueprint identifier."
  value       = "data-platform-oci-gcp-mysql-heatwave-dr"
}

output "resource_ids" {
  description = "OCI database/network IDs; no replication channel is configured."
  value       = module.mysql.resource_ids
}
