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
    stream_pool = try(oci_streaming_stream_pool.this[0].id, null)
    streams     = { for key, stream in oci_streaming_stream.this : key => stream.id }
  }
}

output "stream_pool_id" {
  description = "Created or referenced stream pool OCID."
  value       = local.stream_pool_id
}

output "stream_ids" {
  description = "Stream OCIDs keyed by logical stream name."
  value       = { for key, stream in oci_streaming_stream.this : key => stream.id }
}
