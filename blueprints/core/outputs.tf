output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this blueprint."
  value       = local.name_prefix
}

output "root_compartment_id" {
  description = "OCID of the landing zone root compartment."
  value       = module.compartments.root_compartment_id
}

output "compartment_ids" {
  description = "Map of landing zone compartment keys to OCIDs."
  value       = module.compartments.compartment_ids
}

output "network_compartment_id" {
  description = "OCID of the landing zone network compartment."
  value       = module.compartments.compartment_ids["network"]
}

output "security_compartment_id" {
  description = "OCID of the landing zone security compartment."
  value       = module.compartments.compartment_ids["security"]
}

output "governance_compartment_id" {
  description = "OCID of the landing zone governance compartment."
  value       = module.compartments.compartment_ids["governance"]
}

output "workloads_compartment_id" {
  description = "OCID of the landing zone workloads compartment."
  value       = module.compartments.compartment_ids["workloads"]
}

output "compartment_names" {
  description = "Map of landing zone compartment keys to display names."
  value       = module.compartments.compartment_names
}

output "tag_namespace_id" {
  description = "OCID of the landing zone tag namespace."
  value       = module.tagging.tag_namespace_id
}

output "tag_namespace_name" {
  description = "Name of the landing zone tag namespace."
  value       = module.tagging.tag_namespace_name
}

output "tag_definition_ids" {
  description = "Map of landing zone tag names to tag definition OCIDs."
  value       = module.tagging.tag_definition_ids
}

output "group_ids" {
  description = "Map of IAM group keys to OCIDs."
  value       = module.groups.group_ids
}

output "group_names" {
  description = "Map of IAM group keys to names."
  value       = module.groups.group_names
}

output "dynamic_group_ids" {
  description = "Map of dynamic group keys to OCIDs."
  value       = module.dynamic_groups.dynamic_group_ids
}

output "dynamic_group_names" {
  description = "Map of dynamic group keys to names."
  value       = module.dynamic_groups.dynamic_group_names
}

output "policy_ids" {
  description = "Map of IAM policy keys to OCIDs."
  value       = module.policies.policy_ids
}

output "policy_names" {
  description = "Map of IAM policy keys to names."
  value       = module.policies.policy_names
}

output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint."
  value = {
    compartments   = module.compartments.resource_ids
    dynamic_groups = module.dynamic_groups.resource_ids
    groups         = module.groups.resource_ids
    policies       = module.policies.resource_ids
    tag_namespace  = module.tagging.tag_namespace_id
    tags           = module.tagging.tag_definition_ids
  }
}
