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
