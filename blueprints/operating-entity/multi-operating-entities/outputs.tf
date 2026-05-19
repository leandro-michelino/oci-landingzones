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
    compartments = { for key, entity in module.entity_compartments : key => entity.resource_ids }
    groups       = module.groups.resource_ids
    policies     = module.policies.resource_ids
  }
}

output "entity_compartment_ids" {
  description = "Operating entity compartment IDs keyed by entity and compartment key."
  value       = { for key, entity in module.entity_compartments : key => entity.compartment_ids }
}

output "entity_compartment_names" {
  description = "Operating entity compartment names keyed by entity and compartment key."
  value       = { for key, entity in module.entity_compartments : key => entity.compartment_names }
}

output "entity_group_ids" {
  description = "Delegated IAM group IDs keyed by entity role."
  value       = module.groups.group_ids
}

output "entity_group_names" {
  description = "Delegated IAM group names keyed by entity role."
  value       = module.groups.group_names
}

output "entity_policy_ids" {
  description = "Delegated IAM policy IDs keyed by entity role."
  value       = module.policies.policy_ids
}

output "entity_policy_statements" {
  description = "Delegated IAM policy statements keyed by entity role."
  value       = module.policies.policy_statements
}
