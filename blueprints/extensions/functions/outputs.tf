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
  value = merge(
    {
      container_repository = try(oci_artifacts_container_repository.this[0].id, null)
      application          = local.application_id
      api_gateway          = local.gateway_id
      api_deployment       = try(oci_apigateway_deployment.this[0].id, null)
      access_policy        = try(oci_identity_policy.access[0].id, null)
    },
    {
      for key, function in oci_functions_function.this : "function.${key}" => function.id
    },
    {
      for key, rule in oci_events_rule.this : "event_rule.${key}" => rule.id
    }
  )
}

output "container_repository_id" {
  description = "Artifact Registry container repository OCID."
  value       = try(oci_artifacts_container_repository.this[0].id, null)
}

output "container_repository_url" {
  description = "OCIR-compatible repository URL for function image push commands."
  value       = local.repository_url
}

output "functions_app_id" {
  description = "Created or referenced Functions application OCID."
  value       = local.application_id
}

output "functions_app_state" {
  description = "Functions application lifecycle state."
  value       = try(oci_functions_application.this[0].state, null)
}

output "function_ids" {
  description = "Function OCIDs keyed by logical name."
  value = {
    for key, function in oci_functions_function.this : key => function.id
  }
}

output "function_invoke_endpoints" {
  description = "Function invoke endpoints keyed by logical name."
  value = {
    for key, function in oci_functions_function.this : key => function.invoke_endpoint
  }
}

output "api_gateway_id" {
  description = "Created or referenced API Gateway OCID."
  value       = local.gateway_id
}

output "api_gateway_deployment_id" {
  description = "API Gateway deployment OCID."
  value       = try(oci_apigateway_deployment.this[0].id, null)
}

output "api_gateway_route_url" {
  description = "API Gateway deployment endpoint for function routes."
  value       = try(oci_apigateway_deployment.this[0].endpoint, null)
}

output "event_rule_ids" {
  description = "Event rule OCIDs keyed by logical name."
  value = {
    for key, rule in oci_events_rule.this : key => rule.id
  }
}

output "access_policy_id" {
  description = "Optional IAM policy OCID."
  value       = try(oci_identity_policy.access[0].id, null)
}
