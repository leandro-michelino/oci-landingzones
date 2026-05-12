# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}

output "cis_level" {
  description = "Fixed CIS OCI Benchmark profile for this blueprint."
  value       = local.cis_level
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this blueprint."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint."
  value       = module.core.resource_ids
}

output "root_compartment_id" {
  description = "OCID of the CIS landing zone root compartment."
  value       = module.core.root_compartment_id
}

output "compartment_ids" {
  description = "Map of CIS landing zone compartment keys to OCIDs."
  value       = module.core.compartment_ids
}

output "group_names" {
  description = "Map of IAM group keys to names."
  value       = module.core.group_names
}

output "policy_names" {
  description = "Map of IAM policy keys to names."
  value       = module.core.policy_names
}
