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
    compartments = module.compartments.resource_ids
    groups       = module.groups.resource_ids
    policies     = module.policies.resource_ids
  }
}

output "root_compartment_id" {
  description = "Operating entity root compartment OCID."
  value       = module.compartments.root_compartment_id
}

output "compartment_ids" {
  description = "Operating entity compartment OCIDs keyed by logical name."
  value       = module.compartments.compartment_ids
}

output "compartment_names" {
  description = "Operating entity compartment names keyed by logical name."
  value       = module.compartments.compartment_names
}

output "group_ids" {
  description = "Operating entity IAM group OCIDs."
  value       = module.groups.group_ids
}

output "group_names" {
  description = "Operating entity IAM group names."
  value       = module.groups.group_names
}

output "policy_ids" {
  description = "Operating entity IAM policy OCIDs."
  value       = module.policies.policy_ids
}

output "policy_statements" {
  description = "Operating entity IAM policy statements."
  value       = module.policies.policy_statements
}
