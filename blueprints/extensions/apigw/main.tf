# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_apigateway_gateway" "this" {
  count = var.enable_gateway && var.create_gateway ? 1 : 0

  compartment_id             = local.target_compartment_ocid
  endpoint_type              = var.endpoint_type
  subnet_id                  = var.subnet_id
  certificate_id             = var.certificate_id
  display_name               = local.gateway_name
  network_security_group_ids = var.network_security_group_ids
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "oci_apigateway_deployment" "this" {
  count = var.enable_deployment ? 1 : 0

  compartment_id = local.target_compartment_ocid
  gateway_id     = local.gateway_id
  path_prefix    = var.path_prefix
  display_name   = local.deployment_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  specification {
    dynamic "routes" {
      for_each = var.routes

      content {
        path    = routes.value.path
        methods = try(routes.value.methods, null)

        backend {
          type                       = routes.value.backend_type
          url                        = try(routes.value.backend_url, null)
          status                     = try(routes.value.backend_status, null)
          is_ssl_verify_disabled     = try(routes.value.is_ssl_verify_disabled, null)
          connect_timeout_in_seconds = try(routes.value.connect_timeout_in_seconds, null)
          read_timeout_in_seconds    = try(routes.value.read_timeout_in_seconds, null)
          send_timeout_in_seconds    = try(routes.value.send_timeout_in_seconds, null)
        }
      }
    }
  }
}
