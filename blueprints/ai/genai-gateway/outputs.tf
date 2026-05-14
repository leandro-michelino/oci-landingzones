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
    gateway       = local.gateway_id
    deployment    = local.deployment_id
    audit_bucket  = try(oci_objectstorage_bucket.audit[0].id, null)
    log_group     = try(oci_logging_log_group.gateway[0].id, null)
    access_policy = try(oci_identity_policy.access[0].id, null)
    usage_plans   = { for key, plan in oci_apigateway_usage_plan.this : key => plan.id }
  }
}
output "gateway_id" {
  description = "API Gateway OCID."
  value       = local.gateway_id
}
output "deployment_id" {
  description = "API Gateway deployment OCID."
  value       = local.deployment_id
}
output "usage_plan_ids" {
  description = "API Gateway usage plan OCIDs keyed by logical name."
  value       = { for key, plan in oci_apigateway_usage_plan.this : key => plan.id }
}
output "audit_bucket_name" {
  description = "Prompt and response audit bucket name."
  value       = try(oci_objectstorage_bucket.audit[0].name, null)
}
output "log_group_id" {
  description = "Gateway log group OCID."
  value       = try(oci_logging_log_group.gateway[0].id, null)
}
output "access_policy_id" {
  description = "IAM policy OCID for gateway access."
  value       = try(oci_identity_policy.access[0].id, null)
}
