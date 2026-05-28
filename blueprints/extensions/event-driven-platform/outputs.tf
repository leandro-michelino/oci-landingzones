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
    archive_bucket     = try(oci_objectstorage_bucket.archive[0].id, null)
    stream_pool        = local.stream_pool_id
    streams            = local.stream_ids
    notification_topic = local.topic_id
    event_rules        = { for key, rule in oci_events_rule.this : key => rule.id }
    service_connector  = try(oci_sch_service_connector.this[0].id, null)
    access_policy      = try(oci_identity_policy.access[0].id, null)
  }
}
output "archive_bucket_name" {
  description = "Event archive bucket name."
  value       = try(oci_objectstorage_bucket.archive[0].name, null)
}
output "stream_pool_id" {
  description = "Streaming pool OCID."
  value       = local.stream_pool_id
}
output "stream_ids" {
  description = "Stream OCIDs keyed by logical name."
  value       = local.stream_ids
}
output "notification_topic_id" {
  description = "ONS notification topic OCID."
  value       = local.topic_id
}
output "event_rule_ids" {
  description = "Events rule OCIDs keyed by logical name."
  value       = { for key, rule in oci_events_rule.this : key => rule.id }
}
output "service_connector_id" {
  description = "Service Connector OCID."
  value       = try(oci_sch_service_connector.this[0].id, null)
}
output "access_policy_id" {
  description = "IAM policy OCID for event-driven platform access."
  value       = try(oci_identity_policy.access[0].id, null)
}
