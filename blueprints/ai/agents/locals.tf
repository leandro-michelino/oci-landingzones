# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "agents"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "agents"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)

  bucket_names = {
    source    = coalesce(var.source_bucket_name, "${local.name_prefix}-source")
    processed = coalesce(var.processed_bucket_name, "${local.name_prefix}-processed")
    audit     = coalesce(var.audit_bucket_name, "${local.name_prefix}-audit")
  }

  created_source_prefix = var.create_buckets && var.create_data_source ? [{
    namespace = try(data.oci_objectstorage_namespace.this[0].namespace, null)
    bucket    = local.bucket_names.source
    prefix    = var.source_bucket_prefix
  }] : []

  data_source_prefixes = concat(local.created_source_prefix, var.data_source_prefixes)
  knowledge_base_id    = var.create_knowledge_base ? try(oci_generative_ai_agent_knowledge_base.this[0].id, null) : var.knowledge_base_id
  data_source_id       = var.create_data_source ? try(oci_generative_ai_agent_data_source.this[0].id, null) : var.data_source_id
  agent_id             = var.create_agent ? try(oci_generative_ai_agent_agent.this[0].id, null) : var.agent_id
  agent_endpoint_id    = var.create_agent_endpoint ? try(oci_generative_ai_agent_agent_endpoint.this[0].id, null) : var.agent_endpoint_id

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
