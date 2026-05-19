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
