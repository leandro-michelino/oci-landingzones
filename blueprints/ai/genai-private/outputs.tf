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
    private_endpoint = try(oci_generative_ai_generative_ai_private_endpoint.this[0].id, null)
    archive_bucket   = try(oci_objectstorage_bucket.archive[0].id, null)
    access_policy    = try(oci_identity_policy.access[0].id, null)
  }
}
output "private_endpoint_id" {
  description = "OCI Generative AI private endpoint OCID."
  value       = try(oci_generative_ai_generative_ai_private_endpoint.this[0].id, null)
}
output "archive_bucket_name" {
  description = "Archive bucket name."
  value       = try(oci_objectstorage_bucket.archive[0].name, null)
}
output "access_policy_id" {
  description = "IAM policy OCID for GenAI access."
  value       = try(oci_identity_policy.access[0].id, null)
}
