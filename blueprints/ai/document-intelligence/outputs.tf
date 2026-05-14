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
