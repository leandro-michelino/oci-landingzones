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
    buckets          = { for key, bucket in oci_objectstorage_bucket.this : key => bucket.id }
    document_project = try(oci_ai_document_project.this[0].id, null)
    event_rule       = try(oci_events_rule.intake[0].id, null)
    access_policy    = try(oci_identity_policy.access[0].id, null)
  }
}
output "bucket_names" {
  description = "Document pipeline bucket names keyed by purpose."
  value       = local.bucket_names
}
output "document_project_id" {
  description = "OCI Document Understanding project OCID."
  value       = try(oci_ai_document_project.this[0].id, null)
}
output "events_rule_id" {
  description = "Events rule OCID for intake processing."
  value       = try(oci_events_rule.intake[0].id, null)
}
output "access_policy_id" {
  description = "IAM policy OCID for document intelligence access."
  value       = try(oci_identity_policy.access[0].id, null)
}
