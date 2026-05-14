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
  description = "Map of resource identifiers created or referenced by this blueprint."
  value = {
    report_bucket      = try(oci_objectstorage_bucket.reports[0].id, null)
    topic              = local.topic_id
    cloud_guard_target = local.cloud_guard_target_id
    host_scan_recipe   = local.host_scan_recipe_id
    host_scan_target   = try(oci_vulnerability_scanning_host_scan_target.this[0].id, null)
    event_rules        = { for key, rule in oci_events_rule.this : key => rule.id }
    alarms             = { for key, alarm in oci_monitoring_alarm.this : key => alarm.id }
    access_policy      = try(oci_identity_policy.access[0].id, null)
  }
}
output "cloud_guard_target_id" {
  description = "Cloud Guard target OCID."
  value       = local.cloud_guard_target_id
}
output "host_scan_recipe_id" {
  description = "Vulnerability Scanning host scan recipe OCID."
  value       = local.host_scan_recipe_id
}
output "host_scan_target_id" {
  description = "Vulnerability Scanning host scan target OCID."
  value       = try(oci_vulnerability_scanning_host_scan_target.this[0].id, null)
}
output "report_bucket_name" {
  description = "Security report bucket name."
  value       = try(oci_objectstorage_bucket.reports[0].name, local.report_bucket_name)
}
output "event_rule_ids" {
  description = "OCI Events rule OCIDs keyed by logical name."
  value       = { for key, rule in oci_events_rule.this : key => rule.id }
}
output "alarm_ids" {
  description = "Monitoring alarm OCIDs keyed by logical name."
  value       = { for key, alarm in oci_monitoring_alarm.this : key => alarm.id }
}
output "access_policy_id" {
  description = "IAM policy OCID for security posture automation."
  value       = try(oci_identity_policy.access[0].id, null)
}
