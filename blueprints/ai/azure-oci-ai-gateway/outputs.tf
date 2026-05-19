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
    oci_network_contract      = terraform_data.oci_network_contract.id
    oci_gateway_vcn           = try(oci_core_vcn.gateway[0].id, null)
    oci_gateway_route_table   = try(oci_core_route_table.gateway[0].id, null)
    oci_gateway_security_list = try(oci_core_security_list.gateway[0].id, null)
    oci_gateway_subnet        = try(oci_core_subnet.gateway[0].id, null)
    oci_api_gateway           = local.oci_gateway_id_effective
    oci_gateway_deployment    = local.oci_deployment_id_effective
    oci_usage_plans           = { for key, plan in oci_apigateway_usage_plan.this : key => plan.id }
    oci_audit_bucket          = try(oci_objectstorage_bucket.audit[0].id, null)
    oci_routing_log_group     = try(oci_logging_log_group.routing[0].id, null)
    oci_access_policy         = try(oci_identity_policy.access[0].id, null)
    connectivity_contract     = terraform_data.connectivity_contract.id
    routing_contract          = terraform_data.routing_contract.id
    azure_contract            = terraform_data.azure_contract.id
  }
}

output "oci_network_contract" {
  description = "Deploy-and-use OCI gateway network contract."
  value       = terraform_data.oci_network_contract.input
}

output "connectivity_contract" {
  description = "Cross-cloud connectivity mode and interconnect identifiers."
  value       = local.connectivity_contract
}

output "routing_contract" {
  description = "AI gateway routing policy contract for region, cost, and data residency routes."
  value       = local.routing_contract
}

output "provider_endpoints" {
  description = "Configured provider endpoints for OCI and Azure AI backends."
  value = {
    oci_inference_url   = var.oci_generative_ai_inference_url
    azure_inference_url = var.azure_openai_inference_url
  }
}

output "gateway_route_map" {
  description = "OCI API Gateway route map for provider and strategy paths."
  value = {
    path_prefix = var.gateway_path_prefix
    routes = {
      providers = {
        oci   = "${var.gateway_path_prefix}/providers/oci"
        azure = "${var.gateway_path_prefix}/providers/azure"
      }
      strategies = {
        region         = "${var.gateway_path_prefix}/route/region"
        cost           = "${var.gateway_path_prefix}/route/cost"
        data_residency = "${var.gateway_path_prefix}/route/data-residency"
      }
    }
  }
}

output "oci_gateway_id" {
  description = "OCI API Gateway OCID."
  value       = local.oci_gateway_id_effective
}

output "oci_gateway_deployment_id" {
  description = "OCI API Gateway deployment OCID."
  value       = local.oci_deployment_id_effective
}

output "oci_usage_plan_ids" {
  description = "OCI API Gateway usage plan OCIDs keyed by logical name."
  value       = { for key, plan in oci_apigateway_usage_plan.this : key => plan.id }
}

output "oci_audit_bucket_name" {
  description = "OCI audit bucket name for AI gateway evidence."
  value       = try(oci_objectstorage_bucket.audit[0].name, null)
}

output "oci_routing_log_group_id" {
  description = "OCI logging log group OCID for AI gateway routing logs."
  value       = try(oci_logging_log_group.routing[0].id, null)
}

output "oci_access_policy_id" {
  description = "OCI IAM policy OCID for AI gateway operators and callers."
  value       = try(oci_identity_policy.access[0].id, null)
}

output "azure_contract" {
  description = "Azure-side hand-off metadata from Azure deployment session outputs."
  value       = local.azure_contract
}
