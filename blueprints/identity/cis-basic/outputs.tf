# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}

output "cis_level" {
  description = "CIS baseline level implemented by this identity blueprint."
  value       = local.cis_level
}

output "resource_ids" {
  description = "Consolidated map of resource and contract identifiers produced by this blueprint; use it as the primary machine-readable hand-off for integration and runbook steps."
  value = merge(
    { for key, id in module.groups.group_ids : "group.${key}" => id },
    { for key, id in module.dynamic_groups.dynamic_group_ids : "dynamic_group.${key}" => id },
    { for key, id in module.policies.policy_ids : "policy.${key}" => id }
  )
}

output "group_ids" {
  description = "IAM group OCIDs keyed by logical role."
  value       = module.groups.group_ids
}

output "group_names" {
  description = "IAM group names keyed by logical role."
  value       = module.groups.group_names
}

output "dynamic_group_ids" {
  description = "Dynamic group OCIDs keyed by logical role."
  value       = module.dynamic_groups.dynamic_group_ids
}

output "policy_ids" {
  description = "IAM policy OCIDs keyed by logical role."
  value       = module.policies.policy_ids
}
