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
  description = "Map of resource identifiers created by this blueprint. Empty until implementation."
  value       = {}
}

