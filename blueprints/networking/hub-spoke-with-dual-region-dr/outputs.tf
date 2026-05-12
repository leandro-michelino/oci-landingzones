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
    { for key, value in module.primary_network.resource_ids : "primary_${key}" => value },
    { for key, value in module.secondary_network.resource_ids : "secondary_${key}" => value }
  )
}

output "primary_hub_vcn_id" {
  description = "Primary hub VCN OCID."
  value       = module.primary_network.hub_vcn_id
}

output "secondary_hub_vcn_id" {
  description = "Secondary hub VCN OCID."
  value       = module.secondary_network.hub_vcn_id
}

output "primary_drg_id" {
  description = "Primary DRG OCID."
  value       = module.primary_network.drg_id
}

output "secondary_drg_id" {
  description = "Secondary DRG OCID."
  value       = module.secondary_network.drg_id
}

output "primary_spoke_vcn_ids" {
  description = "Primary spoke VCN OCIDs."
  value       = module.primary_network.spoke_vcn_ids
}

output "secondary_spoke_vcn_ids" {
  description = "Secondary spoke VCN OCIDs."
  value       = module.secondary_network.spoke_vcn_ids
}
