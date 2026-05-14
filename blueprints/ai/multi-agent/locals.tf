# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "multi-agent"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "multi-agent"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  bucket_names = {
    audit = coalesce(var.audit_bucket_name, "${local.name_prefix}-audit")
    tools = coalesce(var.tool_registry_bucket_name, "${local.name_prefix}-tools")
  }
  stream_pool_name         = coalesce(var.stream_pool_name, "${local.name_prefix}-pool")
  stream_pool_id           = var.create_stream_pool ? try(oci_streaming_stream_pool.this[0].id, null) : var.stream_pool_id
  knowledge_base_id        = var.create_knowledge_base ? try(oci_generative_ai_agent_knowledge_base.this[0].id, null) : var.knowledge_base_id
  orchestrator_agent_id    = var.create_orchestrator_agent ? try(oci_generative_ai_agent_agent.orchestrator[0].id, null) : var.orchestrator_agent_id
  orchestrator_endpoint_id = var.create_orchestrator_endpoint ? try(oci_generative_ai_agent_agent_endpoint.orchestrator[0].id, null) : var.orchestrator_endpoint_id
  orchestrator_kb_ids      = compact(concat(var.orchestrator_knowledge_base_ids, [local.knowledge_base_id]))
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
