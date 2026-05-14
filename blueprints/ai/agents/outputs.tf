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
    buckets        = { for key, bucket in oci_objectstorage_bucket.this : key => bucket.id }
    knowledge_base = local.knowledge_base_id
    data_source    = local.data_source_id
    ingestion_job  = try(oci_generative_ai_agent_data_ingestion_job.this[0].id, null)
    agent          = local.agent_id
    agent_endpoint = local.agent_endpoint_id
    access_policy  = try(oci_identity_policy.access[0].id, null)
  }
}
output "bucket_names" {
  description = "Source, processed, and audit bucket names keyed by purpose."
  value       = local.bucket_names
}
output "knowledge_base_id" {
  description = "GenAI Agent knowledge base OCID."
  value       = local.knowledge_base_id
}
output "data_source_id" {
  description = "GenAI Agent data source OCID."
  value       = local.data_source_id
}
output "agent_id" {
  description = "GenAI Agent OCID."
  value       = local.agent_id
}
output "agent_endpoint_id" {
  description = "GenAI Agent endpoint OCID."
  value       = local.agent_endpoint_id
}
output "access_policy_id" {
  description = "IAM policy OCID for RAG agent access."
  value       = try(oci_identity_policy.access[0].id, null)
}
