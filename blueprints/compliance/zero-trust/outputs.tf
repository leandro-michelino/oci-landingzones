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
