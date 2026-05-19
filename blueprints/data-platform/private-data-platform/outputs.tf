# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
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
