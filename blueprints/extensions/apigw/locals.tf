# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "extensions-apigw"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  gateway_name            = "${local.name_prefix}-apigw-${var.gateway_label}"
  deployment_name         = "${local.name_prefix}-apidep-${var.deployment_label}"
  gateway_id              = var.gateway_id != null ? var.gateway_id : try(oci_apigateway_gateway.this[0].id, null)
  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
    }
  )
}
