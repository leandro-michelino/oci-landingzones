output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for primary-region resources."
  value       = local.name_prefix
}

output "standby_name_prefix" {
  description = "Standard OCI naming prefix for standby-region resources."
  value       = local.standby_name_prefix
}

output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint. Empty until implementation."
  value       = {}
}
