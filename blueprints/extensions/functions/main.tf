# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_artifacts_container_repository" "this" {
  count = var.enable_container_repository ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.repository_display_name
  is_immutable   = var.repository_is_immutable
  is_public      = var.repository_is_public
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  dynamic "readme" {
    for_each = var.repository_readme == null ? [] : [var.repository_readme]

    content {
      content = readme.value.content
      format  = readme.value.format
    }
  }
}

resource "oci_functions_application" "this" {
  count = var.enable_application && var.create_application ? 1 : 0

  compartment_id             = local.target_compartment_ocid
  display_name               = local.application_display_name
  subnet_ids                 = var.application_subnet_ids
  network_security_group_ids = var.application_network_security_group_ids
  shape                      = var.application_shape
  config                     = var.application_config
  syslog_url                 = var.syslog_url
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags

  dynamic "image_policy_config" {
    for_each = var.image_policy_enabled ? [1] : []

    content {
      is_policy_enabled = true

      dynamic "key_details" {
        for_each = var.image_policy_kms_key_ids

        content {
          kms_key_id = key_details.value
        }
      }
    }
  }

  dynamic "logging" {
    for_each = var.application_log_line_format == null ? [] : [var.application_log_line_format]

    content {
      line_format = logging.value
    }
  }

  dynamic "trace_config" {
    for_each = var.application_trace_enabled || var.application_trace_domain_id != null ? [1] : []

    content {
      is_enabled = var.application_trace_enabled
      domain_id  = var.application_trace_domain_id
    }
  }
}

resource "oci_functions_function" "this" {
  for_each = var.enable_functions ? var.functions : {}

  application_id                   = local.application_id
  display_name                     = coalesce(each.value.display_name, "${local.name_prefix}-fn-${each.key}")
  image                            = each.value.image
  image_digest                     = each.value.image_digest
  memory_in_mbs                    = tostring(each.value.memory_in_mbs)
  timeout_in_seconds               = each.value.timeout_in_seconds
  detached_mode_timeout_in_seconds = each.value.detached_mode_timeout_in_seconds
  config                           = each.value.config
  defined_tags                     = var.defined_tags
  freeform_tags                    = local.common_freeform_tags

  dynamic "trace_config" {
    for_each = each.value.trace_enabled == null ? [] : [each.value.trace_enabled]

    content {
      is_enabled = trace_config.value
    }
  }

  dynamic "provisioned_concurrency_config" {
    for_each = each.value.provisioned_concurrency == null ? [] : [each.value.provisioned_concurrency]

    content {
      strategy = provisioned_concurrency_config.value.strategy
      count    = provisioned_concurrency_config.value.count
    }
  }

  dynamic "success_destination" {
    for_each = each.value.success_destination == null ? [] : [each.value.success_destination]

    content {
      kind       = success_destination.value.kind
      channel_id = success_destination.value.channel_id
      queue_id   = success_destination.value.queue_id
      stream_id  = success_destination.value.stream_id
      topic_id   = success_destination.value.topic_id
    }
  }

  dynamic "failure_destination" {
    for_each = each.value.failure_destination == null ? [] : [each.value.failure_destination]

    content {
      kind       = failure_destination.value.kind
      channel_id = failure_destination.value.channel_id
      queue_id   = failure_destination.value.queue_id
      stream_id  = failure_destination.value.stream_id
      topic_id   = failure_destination.value.topic_id
    }
  }
}

resource "oci_apigateway_gateway" "this" {
  count = var.enable_api_gateway && var.create_gateway ? 1 : 0

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
  count = var.enable_api_gateway_deployment ? 1 : 0

  compartment_id = local.target_compartment_ocid
  gateway_id     = local.gateway_id
  path_prefix    = var.gateway_path_prefix
  display_name   = local.deployment_display_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  specification {
    dynamic "routes" {
      for_each = local.api_routes

      content {
        path    = routes.value.path
        methods = routes.value.methods

        backend {
          type                       = "ORACLE_FUNCTIONS_BACKEND"
          function_id                = routes.value.function_id != null ? routes.value.function_id : try(oci_functions_function.this[routes.value.function_key].id, null)
          connect_timeout_in_seconds = routes.value.connect_timeout_in_seconds
          read_timeout_in_seconds    = routes.value.read_timeout_in_seconds
          send_timeout_in_seconds    = routes.value.send_timeout_in_seconds
        }
      }
    }
  }
}

resource "oci_events_rule" "this" {
  for_each = var.enable_event_rules ? var.event_rules : {}

  compartment_id = coalesce(each.value.compartment_ocid, local.target_compartment_ocid)
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-evt-${each.key}")
  description    = coalesce(each.value.description, "Function event trigger ${each.key} managed by Terraform.")
  condition      = each.value.condition
  is_enabled     = each.value.is_enabled
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  actions {
    dynamic "actions" {
      for_each = each.value.actions

      content {
        action_type = "FAAS"
        function_id = actions.value.function_id != null ? actions.value.function_id : try(oci_functions_function.this[actions.value.function_key].id, null)
        description = actions.value.description
        is_enabled  = actions.value.is_enabled
      }
    }
  }
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-access"
  description    = "Oracle Functions access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
