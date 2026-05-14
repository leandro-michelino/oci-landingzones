# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "extensions-functions"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "functions"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)

  application_display_name = coalesce(var.application_display_name, "${local.name_prefix}-app")
  application_id           = var.create_application ? try(oci_functions_application.this[0].id, null) : var.application_id

  repository_display_name = coalesce(var.repository_display_name, "${local.name_prefix}/${var.repository_name}")
  repository_url = var.enable_container_repository ? try(
    "${var.region}.ocir.io/${oci_artifacts_container_repository.this[0].namespace}/${oci_artifacts_container_repository.this[0].display_name}",
    null
  ) : var.repository_url

  gateway_display_name    = coalesce(var.gateway_display_name, "${local.name_prefix}-gateway")
  gateway_id              = var.create_gateway ? try(oci_apigateway_gateway.this[0].id, null) : var.gateway_id
  deployment_display_name = coalesce(var.deployment_display_name, "${local.name_prefix}-deployment")

  default_api_routes = var.enable_api_gateway_deployment && var.default_api_function_key != null ? {
    default = {
      path                       = var.default_api_route_path
      methods                    = var.default_api_route_methods
      function_key               = var.default_api_function_key
      function_id                = null
      connect_timeout_in_seconds = null
      read_timeout_in_seconds    = null
      send_timeout_in_seconds    = null
    }
  } : {}

  api_routes = merge(local.default_api_routes, var.api_routes)

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
