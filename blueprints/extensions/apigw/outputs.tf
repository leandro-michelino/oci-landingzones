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
    gateway    = try(oci_apigateway_gateway.this[0].id, null)
    deployment = try(oci_apigateway_deployment.this[0].id, null)
  }
}

output "gateway_id" {
  description = "Created or referenced API Gateway OCID."
  value       = local.gateway_id
}

output "deployment_id" {
  description = "API Gateway deployment OCID."
  value       = try(oci_apigateway_deployment.this[0].id, null)
}

output "deployment_endpoint" {
  description = "API Gateway deployment endpoint."
  value       = try(oci_apigateway_deployment.this[0].endpoint, null)
}
