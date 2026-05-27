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
  description = "OCI gateway network hand-off contract containing effective VCN, subnet, route table, and security-list references for the API front door."
  value       = terraform_data.oci_network_contract.input
}

output "connectivity_contract" {
  description = "Cross-cloud connectivity contract with selected mode and partner interconnect identifiers that operations teams can verify during cutover drills."
  value       = local.connectivity_contract
}

output "routing_contract" {
  description = "Routing-policy contract for provider selection by region, cost, and data-residency intent, used by runbooks and policy review workflows."
  value       = local.routing_contract
}

output "provider_endpoints" {
  description = "Resolved backend inference endpoints for OCI Generative AI and Azure OpenAI that the gateway routes requests toward."
  value = {
    oci_inference_url   = var.oci_generative_ai_inference_url
    azure_inference_url = var.azure_openai_inference_url
  }
}

output "gateway_route_map" {
  description = "Operator-readable route map exposing provider and strategy URI paths provisioned by this gateway deployment."
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
  description = "OCI API Gateway OCID for the primary ingress surface in this multicloud AI pattern."
  value       = local.oci_gateway_id_effective
}

output "oci_gateway_deployment_id" {
  description = "OCI API Gateway deployment OCID for the active route configuration."
  value       = local.oci_deployment_id_effective
}

output "oci_usage_plan_ids" {
  description = "OCI API Gateway usage-plan OCIDs keyed by logical plan name, used for quota and throttling operations."
  value       = { for key, plan in oci_apigateway_usage_plan.this : key => plan.id }
}

output "oci_audit_bucket_name" {
  description = "Object Storage bucket name used for gateway audit and evidence artifacts."
  value       = try(oci_objectstorage_bucket.audit[0].name, null)
}

output "oci_routing_log_group_id" {
  description = "OCI Logging log-group OCID where routing and decision telemetry for this AI gateway is retained."
  value       = try(oci_logging_log_group.routing[0].id, null)
}

output "oci_access_policy_id" {
  description = "OCI IAM policy OCID granting scoped access needed by AI gateway operators and service callers."
  value       = try(oci_identity_policy.access[0].id, null)
}

output "azure_contract" {
  description = "Azure-side hand-off metadata captured from Azure deployment outputs, including endpoint and deployment identifiers."
  value       = local.azure_contract
}
