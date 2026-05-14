# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}
output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this blueprint."
  value       = local.name_prefix
}
output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint."
  value = {
    audit_bucket      = try(oci_objectstorage_bucket.audit[0].id, null)
    log_group         = try(oci_logging_log_group.guardrails[0].id, null)
    service_connector = try(oci_sch_service_connector.audit[0].id, null)
    detector_recipe   = try(oci_cloud_guard_detector_recipe.genai[0].id, null)
    alarms            = { for key, alarm in oci_monitoring_alarm.this : key => alarm.id }
    access_policy     = try(oci_identity_policy.access[0].id, null)
  }
}
output "audit_bucket_name" {
  description = "Guardrail audit bucket name."
  value       = try(oci_objectstorage_bucket.audit[0].name, null)
}
output "log_group_id" {
  description = "Guardrail log group OCID."
  value       = try(oci_logging_log_group.guardrails[0].id, null)
}
output "service_connector_id" {
  description = "Service Connector OCID."
  value       = try(oci_sch_service_connector.audit[0].id, null)
}
output "detector_recipe_id" {
  description = "Cloud Guard detector recipe OCID."
  value       = try(oci_cloud_guard_detector_recipe.genai[0].id, null)
}
output "alarm_ids" {
  description = "Monitoring alarm OCIDs keyed by logical name."
  value       = { for key, alarm in oci_monitoring_alarm.this : key => alarm.id }
}
output "access_policy_id" {
  description = "IAM policy OCID for guardrail access."
  value       = try(oci_identity_policy.access[0].id, null)
}
