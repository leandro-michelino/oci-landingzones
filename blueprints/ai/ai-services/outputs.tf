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
    buckets                 = { for key, bucket in oci_objectstorage_bucket.this : key => bucket.id }
    document_project        = try(oci_ai_document_project.document[0].id, null)
    language_project        = try(oci_ai_language_project.language[0].id, null)
    vision_project          = try(oci_ai_vision_project.vision[0].id, null)
    vision_private_endpoint = try(oci_ai_vision_vision_private_endpoint.this[0].id, null)
    access_policy           = try(oci_identity_policy.access[0].id, null)
  }
}
output "bucket_names" {
  description = "AI service bucket names keyed by purpose."
  value       = local.bucket_names
}
output "document_project_id" {
  description = "OCI Document Understanding project OCID."
  value       = try(oci_ai_document_project.document[0].id, null)
}
output "language_project_id" {
  description = "OCI Language project OCID."
  value       = try(oci_ai_language_project.language[0].id, null)
}
output "vision_project_id" {
  description = "OCI Vision project OCID."
  value       = try(oci_ai_vision_project.vision[0].id, null)
}
output "vision_private_endpoint_id" {
  description = "OCI Vision private endpoint OCID."
  value       = try(oci_ai_vision_vision_private_endpoint.this[0].id, null)
}
output "access_policy_id" {
  description = "IAM policy OCID for AI Services access."
  value       = try(oci_identity_policy.access[0].id, null)
}
