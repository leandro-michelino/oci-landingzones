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

resource "oci_generative_ai_agent_knowledge_base" "this" {
  count = var.create_knowledge_base ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = coalesce(var.knowledge_base_display_name, "${local.name_prefix}-kb")
  description    = var.knowledge_base_description
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  index_config {
    index_config_type           = var.knowledge_base_index_config_type
    cluster_id                  = var.opensearch_cluster_id
    should_enable_hybrid_search = var.should_enable_hybrid_search

    dynamic "indexes" {
      for_each = var.knowledge_base_indexes

      content {
        name = indexes.value.name

        dynamic "schema" {
          for_each = indexes.value.schema == null ? [] : [indexes.value.schema]

          content {
            body_key           = schema.value.body_key
            embedding_body_key = schema.value.embedding_body_key
            title_key          = schema.value.title_key
            url_key            = schema.value.url_key
          }
        }
      }
    }
  }
}

resource "oci_generative_ai_agent_data_source" "this" {
  count = var.create_data_source ? 1 : 0

  compartment_id    = local.target_compartment_ocid
  knowledge_base_id = local.knowledge_base_id
  display_name      = coalesce(var.data_source_display_name, "${local.name_prefix}-aip-documents")
  description       = var.data_source_description
  metadata          = var.data_source_metadata
  defined_tags      = var.defined_tags
  freeform_tags     = local.common_freeform_tags

  data_source_config {
    data_source_config_type = var.data_source_config_type

    dynamic "object_storage_prefixes" {
      for_each = local.data_source_prefixes

      content {
        namespace = object_storage_prefixes.value.namespace
        bucket    = object_storage_prefixes.value.bucket
        prefix    = object_storage_prefixes.value.prefix
      }
    }
  }
}

resource "oci_generative_ai_agent_data_ingestion_job" "this" {
  count = var.create_ingestion_job ? 1 : 0

  compartment_id = local.target_compartment_ocid
  data_source_id = local.data_source_id
  display_name   = coalesce(var.ingestion_job_display_name, "${local.name_prefix}-job-ingestion")
  description    = var.ingestion_job_description
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_generative_ai_agent_agent" "this" {
  count = var.create_agent ? 1 : 0

  compartment_id     = local.target_compartment_ocid
  display_name       = coalesce(var.agent_display_name, "${local.name_prefix}-agent-rag")
  description        = var.agent_description
  welcome_message    = var.agent_welcome_message
  knowledge_base_ids = compact(concat(var.agent_knowledge_base_ids, [local.knowledge_base_id]))
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags

  dynamic "llm_config" {
    for_each = var.agent_model_id == null && var.agent_endpoint_model_id == null && var.agent_instruction == null ? [] : [1]

    content {
      routing_llm_customization {
        instruction = var.agent_instruction

        llm_selection {
          llm_selection_type = var.agent_endpoint_model_id == null ? "MODEL" : "ENDPOINT"
          model_id           = var.agent_model_id
          endpoint_id        = var.agent_endpoint_model_id
        }
      }
    }
  }
}

resource "oci_generative_ai_agent_agent_endpoint" "this" {
  count = var.create_agent_endpoint ? 1 : 0

  compartment_id         = local.target_compartment_ocid
  agent_id               = local.agent_id
  display_name           = coalesce(var.agent_endpoint_display_name, "${local.name_prefix}-ep-default")
  description            = var.agent_endpoint_description
  should_enable_session  = var.enable_endpoint_session
  should_enable_trace    = var.enable_endpoint_trace
  should_enable_citation = var.enable_endpoint_citation
  defined_tags           = var.defined_tags
  freeform_tags          = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-access"
  description    = "AI Agents RAG access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
