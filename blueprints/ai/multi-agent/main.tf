# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  count          = var.create_buckets ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "this" {
  for_each = var.create_buckets ? local.bucket_names : {}

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = each.value
  access_type           = "NoPublicAccess"
  storage_tier          = var.bucket_storage_tier
  versioning            = var.bucket_versioning
  object_events_enabled = true
  kms_key_id            = var.kms_key_id
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_streaming_stream_pool" "this" {
  count = var.create_stream_pool ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.stream_pool_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  dynamic "custom_encryption_key" {
    for_each = var.kms_key_id == null ? [] : [var.kms_key_id]

    content {
      kms_key_id = custom_encryption_key.value
    }
  }
}

resource "oci_streaming_stream" "tasks" {
  count = var.create_task_stream ? 1 : 0

  compartment_id     = local.target_compartment_ocid
  name               = "${local.name_prefix}-stream-tasks"
  partitions         = var.task_stream_partitions
  retention_in_hours = var.task_stream_retention_in_hours
  stream_pool_id     = local.stream_pool_id
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags
}

resource "oci_generative_ai_agent_knowledge_base" "this" {
  count = var.create_knowledge_base ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = coalesce(var.knowledge_base_display_name, "${local.name_prefix}-kb")
  description    = var.knowledge_base_description
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  index_config {
    index_config_type = var.knowledge_base_index_config_type
    cluster_id        = var.opensearch_cluster_id
  }
}

resource "oci_generative_ai_agent_agent" "orchestrator" {
  count = var.create_orchestrator_agent ? 1 : 0

  compartment_id     = local.target_compartment_ocid
  display_name       = coalesce(var.orchestrator_display_name, "${local.name_prefix}-agent-orchestrator")
  description        = var.orchestrator_description
  welcome_message    = var.orchestrator_welcome_message
  knowledge_base_ids = local.orchestrator_kb_ids
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags

  dynamic "llm_config" {
    for_each = var.orchestrator_model_id == null && var.orchestrator_endpoint_model_id == null && var.routing_instruction == null ? [] : [1]

    content {
      routing_llm_customization {
        instruction = var.routing_instruction

        llm_selection {
          llm_selection_type = var.orchestrator_endpoint_model_id == null ? "MODEL" : "ENDPOINT"
          model_id           = var.orchestrator_model_id
          endpoint_id        = var.orchestrator_endpoint_model_id
        }
      }
    }
  }
}

resource "oci_generative_ai_agent_agent" "specialist" {
  for_each = var.specialist_agents

  compartment_id     = local.target_compartment_ocid
  display_name       = coalesce(each.value.display_name, "${local.name_prefix}-agent-${each.key}")
  description        = coalesce(each.value.description, "Specialist agent ${each.key}.")
  welcome_message    = coalesce(each.value.welcome_message, "Ready for ${each.key} tasks.")
  knowledge_base_ids = coalesce(each.value.knowledge_base_ids, [])
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags

  dynamic "llm_config" {
    for_each = each.value.model_id == null && each.value.endpoint_model_id == null && each.value.instruction == null ? [] : [1]

    content {
      routing_llm_customization {
        instruction = each.value.instruction

        llm_selection {
          llm_selection_type = each.value.endpoint_model_id == null ? "MODEL" : "ENDPOINT"
          model_id           = each.value.model_id
          endpoint_id        = each.value.endpoint_model_id
        }
      }
    }
  }
}

resource "oci_generative_ai_agent_agent_endpoint" "orchestrator" {
  count = var.create_orchestrator_endpoint ? 1 : 0

  compartment_id         = local.target_compartment_ocid
  agent_id               = local.orchestrator_agent_id
  display_name           = coalesce(var.endpoint_display_name, "${local.name_prefix}-ep-default")
  description            = "Endpoint for ${local.name_prefix} orchestrator."
  should_enable_session  = var.enable_endpoint_session
  should_enable_trace    = var.enable_endpoint_trace
  should_enable_citation = true
  defined_tags           = var.defined_tags
  freeform_tags          = local.common_freeform_tags
}

resource "oci_generative_ai_agent_tool" "this" {
  for_each = var.agent_tools

  compartment_id = local.target_compartment_ocid
  agent_id       = coalesce(each.value.agent_id, try(oci_generative_ai_agent_agent.specialist[each.value.agent_key].id, local.orchestrator_agent_id))
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-tool-${each.key}")
  description    = coalesce(each.value.description, "Tool ${each.key} for multi-agent orchestration.")
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  tool_config {
    tool_config_type = each.value.tool_config_type

    dynamic "function" {
      for_each = each.value.function_name == null ? [] : [each.value]

      content {
        name        = function.value.function_name
        description = function.value.function_description
        parameters  = function.value.function_parameters
      }
    }
  }
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-access"
  description    = "Multi-agent orchestration access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
