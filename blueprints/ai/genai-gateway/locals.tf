# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "genai-gateway"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "genai-gateway"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  gateway_display_name    = coalesce(var.gateway_display_name, "${local.name_prefix}-gateway")
  deployment_display_name = coalesce(var.deployment_display_name, "${local.name_prefix}-deployment")
  audit_bucket_name       = coalesce(var.audit_bucket_name, "${local.name_prefix}-audit")
  log_group_name          = coalesce(var.log_group_name, "${local.name_prefix}-logs")
  gateway_id              = var.create_gateway ? try(oci_apigateway_gateway.this[0].id, null) : var.gateway_id
  deployment_id           = var.create_deployment ? try(oci_apigateway_deployment.this[0].id, null) : var.deployment_id
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
