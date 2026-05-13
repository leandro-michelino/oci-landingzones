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
  value = merge(
    { for key, id in module.network.resource_ids : "network.${key}" => id },
    { for key, id in module.vault.resource_ids : "vault.${key}" => id },
    var.enable_data_bucket ? {
      data_bucket = oci_objectstorage_bucket.data[0].id
    } : {},
    var.enable_object_storage_private_endpoint ? {
      object_storage_private_endpoint = oci_objectstorage_private_endpoint.data[0].id
    } : {},
    { for key, id in module.streaming.resource_ids : "streaming.${key}" => id }
  )
}

output "vcn_id" {
  description = "Private data platform VCN OCID."
  value       = module.network.vcn_id
}

output "subnet_ids" {
  description = "Private data platform subnet OCIDs keyed by role."
  value       = module.network.subnet_ids
}

output "vault_ids" {
  description = "Vault OCIDs keyed by logical name."
  value       = module.vault.vault_ids
}

output "vault_key_ids" {
  description = "KMS key OCIDs keyed by logical name."
  value       = module.vault.key_ids
}

output "data_bucket_name" {
  description = "Private data platform Object Storage bucket name."
  value       = local.data_bucket_name
}

output "object_storage_private_endpoint_id" {
  description = "Object Storage private endpoint OCID."
  value       = try(oci_objectstorage_private_endpoint.data[0].id, null)
}

output "stream_pool_id" {
  description = "Streaming stream pool OCID."
  value       = module.streaming.stream_pool_id
}

output "stream_ids" {
  description = "Stream OCIDs keyed by logical name."
  value       = module.streaming.stream_ids
}
