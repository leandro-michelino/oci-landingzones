output "module_name" {
  description = "Module identifier."
  value       = local.module_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this module."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Map of resource identifiers created by this module. Empty until implementation."
  value       = {}
}
