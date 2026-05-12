# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "module_name" {
  description = "Module identifier."
  value       = local.module_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this module."
  value       = local.name_prefix
}

output "cis_level" {
  description = "Selected CIS OCI Benchmark profile."
  value       = local.cis_level
}

output "resource_ids" {
  description = "Map of resource identifiers created by this module."
  value = merge(
    {
      for key, budget in oci_budget_budget.this : "budget.${key}" => budget.id
    },
    {
      for key, rule in oci_budget_alert_rule.this : "alert_rule.${key}" => rule.id
    }
  )
}

output "budget_ids" {
  description = "Map of budget keys to OCIDs."
  value = {
    for key, budget in oci_budget_budget.this : key => budget.id
  }
}

output "budget_names" {
  description = "Map of budget keys to display names."
  value = {
    for key, budget in oci_budget_budget.this : key => budget.display_name
  }
}

output "budget_alert_rule_ids" {
  description = "Map of budget alert rule keys to OCIDs."
  value = {
    for key, rule in oci_budget_alert_rule.this : key => rule.id
  }
}
