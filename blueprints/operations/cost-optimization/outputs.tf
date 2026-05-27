output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Consolidated map of resource and contract identifiers produced by this blueprint; use it as the primary machine-readable hand-off for integration and runbook steps."
  value = merge(
    {
      access_policy        = try(oci_identity_policy.finops_access[0].id, null)
      optimizer_enrollment = try(oci_optimizer_enrollment_status.this[0].id, null)
    },
    module.tagging.resource_ids,
    module.budgets.resource_ids,
    module.notifications.resource_ids,
    module.monitoring.resource_ids,
    {
      for key, profile in oci_optimizer_profile.this : "optimizer_profile.${key}" => profile.id
    }
  )
}

output "tag_namespace_id" {
  description = "FinOps tag namespace OCID."
  value       = module.tagging.tag_namespace_id
}

output "tag_namespace_name" {
  description = "FinOps tag namespace name."
  value       = module.tagging.tag_namespace_name
}

output "tag_definition_ids" {
  description = "FinOps tag definition OCIDs keyed by tag name."
  value       = module.tagging.tag_definition_ids
}

output "tag_default_ids" {
  description = "FinOps tag default OCIDs keyed by compartment/tag."
  value       = module.tagging.tag_default_ids
}

output "budget_ids" {
  description = "Budget OCIDs keyed by logical name."
  value       = module.budgets.budget_ids
}

output "budget_alert_rule_ids" {
  description = "Budget alert rule OCIDs keyed by logical name."
  value       = module.budgets.budget_alert_rule_ids
}

output "notification_topic_ids" {
  description = "FinOps notification topic OCIDs keyed by logical name."
  value       = module.notifications.notification_topic_ids
}

output "subscription_ids" {
  description = "FinOps notification subscription OCIDs keyed by logical name."
  value       = module.notifications.subscription_ids
}

output "event_rule_ids" {
  description = "Cost-governance Events rule OCIDs keyed by logical name."
  value       = module.notifications.event_rule_ids
}

output "monitoring_alarm_ids" {
  description = "Monitoring alarm OCIDs keyed by logical name."
  value       = module.monitoring.alarm_ids
}

output "budget_alarm_id" {
  description = "Default budget Monitoring alarm OCID."
  value       = try(module.monitoring.alarm_ids["budget_spend"], null)
}

output "optimizer_enrollment_status_id" {
  description = "Optimizer enrollment status resource ID when managed."
  value       = try(oci_optimizer_enrollment_status.this[0].id, null)
}

output "optimizer_profile_ids" {
  description = "Optimizer profile OCIDs keyed by logical name."
  value = {
    for key, profile in oci_optimizer_profile.this : key => profile.id
  }
}

output "access_policy_id" {
  description = "Optional FinOps IAM access policy OCID."
  value       = try(oci_identity_policy.finops_access[0].id, null)
}
