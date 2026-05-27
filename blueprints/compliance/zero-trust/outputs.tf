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
    { for key, id in module.network.resource_ids : "network.${key}" => id }
  )
}

output "root_compartment_id" {
  description = "OCID of the zero-trust landing zone root compartment."
  value       = module.core.root_compartment_id
}

output "compartment_ids" {
  description = "Map of zero-trust landing zone compartment keys to OCIDs."
  value       = module.core.compartment_ids
}

output "vcn_id" {
  description = "Zero-trust workload VCN OCID."
  value       = module.network.vcn_id
}

output "subnet_ids" {
  description = "Zero-trust workload subnet OCIDs keyed by tier."
  value       = module.network.subnet_ids
}

output "zpr_policy_ids" {
  description = "ZPR policy OCIDs keyed by logical name."
  value       = module.network.zpr_policy_ids
}
