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
  value = merge(
    module.core.resource_ids,
    { for key, id in module.network.resource_ids : "network.${key}" => id },
    { for key, id in module.os_management.resource_ids : "os_management.${key}" => id }
  )
}

output "root_compartment_id" {
  description = "OCID of the SCCA landing zone root compartment."
  value       = module.core.root_compartment_id
}

output "compartment_ids" {
  description = "Map of SCCA landing zone compartment keys to OCIDs."
  value       = module.core.compartment_ids
}

output "network_resource_ids" {
  description = "SCCA inspected network resource identifiers."
  value       = module.network.resource_ids
}

output "os_management_resource_ids" {
  description = "OS Management Hub resource identifiers."
  value       = module.os_management.resource_ids
}
