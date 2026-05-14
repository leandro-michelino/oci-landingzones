# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  count          = var.create_audit_bucket ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "audit" {
  count = var.create_audit_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = local.audit_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = var.audit_bucket_storage_tier
  versioning            = var.audit_bucket_versioning
  object_events_enabled = true
  kms_key_id            = var.kms_key_id
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_logging_log_group" "gateway" {
  count = var.create_log_group ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.log_group_name
  description    = "GenAI gateway routing and audit logs for ${local.name_prefix}."
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_apigateway_gateway" "this" {
  count = var.create_gateway ? 1 : 0

  compartment_id             = local.target_compartment_ocid
  endpoint_type              = var.gateway_endpoint_type
  subnet_id                  = var.gateway_subnet_id
  certificate_id             = var.gateway_certificate_id
  display_name               = local.gateway_display_name
  network_security_group_ids = var.gateway_network_security_group_ids
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "oci_apigateway_deployment" "this" {
  count = var.create_deployment ? 1 : 0

  compartment_id = local.target_compartment_ocid
  gateway_id     = local.gateway_id
  path_prefix    = var.gateway_path_prefix
  display_name   = local.deployment_display_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  specification {
    dynamic "routes" {
      for_each = var.routes

      content {
        path    = routes.value.path
        methods = routes.value.methods

        backend {
          type                       = "HTTP_BACKEND"
          url                        = routes.value.url
          connect_timeout_in_seconds = routes.value.connect_timeout_in_seconds
          read_timeout_in_seconds    = routes.value.read_timeout_in_seconds
          send_timeout_in_seconds    = routes.value.send_timeout_in_seconds
          is_ssl_verify_disabled     = routes.value.is_ssl_verify_disabled
        }
      }
    }
  }
}

resource "oci_apigateway_usage_plan" "this" {
  for_each = var.create_usage_plans ? var.usage_plans : {}

  compartment_id = local.target_compartment_ocid
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-${each.key}")
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  entitlements {
    name        = each.value.entitlement_name
    description = each.value.description

    targets {
      deployment_id = coalesce(each.value.target_deployment_id, local.deployment_id)
    }

    dynamic "quota" {
      for_each = each.value.quota_value == null ? [] : [each.value]

      content {
        value               = quota.value.quota_value
        unit                = coalesce(quota.value.quota_unit, "DAY")
        reset_policy        = coalesce(quota.value.quota_reset_policy, "CALENDAR")
        operation_on_breach = coalesce(quota.value.quota_breach_action, "REJECT")
      }
    }

    dynamic "rate_limit" {
      for_each = each.value.rate_limit_value == null ? [] : [each.value]

      content {
        value = rate_limit.value.rate_limit_value
        unit  = coalesce(rate_limit.value.rate_limit_unit, "SECOND")
      }
    }
  }
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-access"
  description    = "GenAI gateway access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
