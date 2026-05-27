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
