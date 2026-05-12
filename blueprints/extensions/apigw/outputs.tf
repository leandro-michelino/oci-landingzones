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
