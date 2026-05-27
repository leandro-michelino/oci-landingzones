output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}
output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}
output "resource_ids" {
  description = "Map of resource identifiers created or referenced by this blueprint."
  value = {
    buckets               = { for key, bucket in oci_objectstorage_bucket.this : key => bucket.id }
    stream_pool           = local.stream_pool_id
    task_stream           = try(oci_streaming_stream.tasks[0].id, null)
    knowledge_base        = local.knowledge_base_id
    orchestrator_agent    = local.orchestrator_agent_id
    orchestrator_endpoint = local.orchestrator_endpoint_id
    specialist_agents     = { for key, agent in oci_generative_ai_agent_agent.specialist : key => agent.id }
    tools                 = { for key, tool in oci_generative_ai_agent_tool.this : key => tool.id }
    access_policy         = try(oci_identity_policy.access[0].id, null)
  }
}
output "bucket_names" {
  description = "Audit and tool registry bucket names keyed by purpose."
  value       = local.bucket_names
}
output "streaming_topic_id" {
  description = "Inter-agent task stream OCID."
  value       = try(oci_streaming_stream.tasks[0].id, null)
}
output "knowledge_base_id" {
  description = "Knowledge base OCID."
  value       = local.knowledge_base_id
}
output "orchestrator_agent_id" {
  description = "Orchestrator agent OCID."
  value       = local.orchestrator_agent_id
}
output "orchestrator_endpoint_id" {
  description = "Orchestrator endpoint OCID."
  value       = local.orchestrator_endpoint_id
}
output "specialist_agent_ids" {
  description = "Specialist agent OCIDs keyed by logical name."
  value       = { for key, agent in oci_generative_ai_agent_agent.specialist : key => agent.id }
}
output "tool_ids" {
  description = "Agent tool OCIDs keyed by logical name."
  value       = { for key, tool in oci_generative_ai_agent_tool.this : key => tool.id }
}
output "access_policy_id" {
  description = "IAM policy OCID for multi-agent orchestration."
  value       = try(oci_identity_policy.access[0].id, null)
}
