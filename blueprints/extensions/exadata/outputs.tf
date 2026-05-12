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
    cloud_exadata_infrastructure = try(oci_database_cloud_exadata_infrastructure.this[0].id, null)
  }
}

output "cloud_exadata_infrastructure_id" {
  description = "Exadata Cloud Infrastructure OCID."
  value       = try(oci_database_cloud_exadata_infrastructure.this[0].id, null)
}
