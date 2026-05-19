# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
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
  value = {
    guardrail_policy          = try(oci_identity_policy.guardrails[0].id, null)
    budget                    = try(oci_budget_budget.this[0].id, null)
    budget_alert_rule         = try(oci_budget_alert_rule.this[0].id, null)
    data_safe_target_database = try(oci_data_safe_target_database.this[0].id, null)
  }
}
output "guardrail_policy_id" {
  description = "Regulated guardrail policy OCID."
  value       = try(oci_identity_policy.guardrails[0].id, null)
}
output "budget_id" {
  description = "Regulated budget OCID."
  value       = try(oci_budget_budget.this[0].id, null)
}
output "budget_alert_rule_id" {
  description = "Regulated budget alert rule OCID."
  value       = try(oci_budget_alert_rule.this[0].id, null)
}
output "data_safe_target_database_id" {
  description = "Data Safe target database OCID."
  value       = try(oci_data_safe_target_database.this[0].id, null)
}
