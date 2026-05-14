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
  description = "Map of resource identifiers created or referenced by this blueprint."
  value = {
    buckets       = { for key, bucket in oci_objectstorage_bucket.this : key => bucket.id }
    stream_pool   = local.stream_pool_id
    streams       = { for key, stream in oci_streaming_stream.this : key => stream.id }
    event_rule    = try(oci_events_rule.source[0].id, null)
    access_policy = try(oci_identity_policy.access[0].id, null)
  }
}
output "bucket_names" {
  description = "Embedding pipeline bucket names keyed by purpose."
  value       = local.bucket_names
}
output "stream_pool_id" {
  description = "Streaming pool OCID."
  value       = local.stream_pool_id
}
output "stream_ids" {
  description = "Stream OCIDs keyed by logical name."
  value       = { for key, stream in oci_streaming_stream.this : key => stream.id }
}
output "events_rule_id" {
  description = "Events rule OCID for source processing."
  value       = try(oci_events_rule.source[0].id, null)
}
output "embedding_model_id" {
  description = "Embedding model OCID passed into the blueprint."
  value       = var.embedding_model_id
}
output "opensearch_endpoint" {
  description = "OpenSearch endpoint passed into the blueprint."
  value       = var.opensearch_endpoint
}
output "vector_index_name" {
  description = "Target vector index name."
  value       = var.vector_index_name
}
output "access_policy_id" {
  description = "IAM policy OCID for embedding pipeline access."
  value       = try(oci_identity_policy.access[0].id, null)
}
