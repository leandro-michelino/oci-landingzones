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
  description = "Map of resource identifiers created or managed by this blueprint."
  value = {
    training_bucket      = try(oci_objectstorage_bucket.training[0].id, null)
    dedicated_ai_cluster = local.cluster_id
    fine_tuned_model     = local.model_id
    endpoint             = try(oci_generative_ai_endpoint.this[0].id, null)
    access_policy        = try(oci_identity_policy.access[0].id, null)
  }
}
output "training_bucket_name" {
  description = "Training bucket name."
  value       = try(oci_objectstorage_bucket.training[0].name, var.training_dataset_bucket)
}
output "dedicated_ai_cluster_id" {
  description = "Dedicated AI cluster OCID."
  value       = local.cluster_id
}
output "fine_tuned_model_id" {
  description = "Fine-tuned model OCID."
  value       = local.model_id
}
output "endpoint_id" {
  description = "GenAI model endpoint OCID."
  value       = try(oci_generative_ai_endpoint.this[0].id, null)
}
output "access_policy_id" {
  description = "IAM policy OCID for fine-tuning access."
  value       = try(oci_identity_policy.access[0].id, null)
}
