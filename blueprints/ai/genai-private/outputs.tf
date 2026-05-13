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
