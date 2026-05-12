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
    { for key, value in module.prod_network.resource_ids : "prod_${key}" => value },
    { for key, value in module.nonprod_network.resource_ids : "nonprod_${key}" => value }
  )
}

output "prod_hub_vcn_id" {
  description = "Production hub VCN OCID."
  value       = module.prod_network.hub_vcn_id
}

output "nonprod_hub_vcn_id" {
  description = "Non-production hub VCN OCID."
  value       = module.nonprod_network.hub_vcn_id
}

output "prod_drg_id" {
  description = "Production DRG OCID."
  value       = module.prod_network.drg_id
}

output "nonprod_drg_id" {
  description = "Non-production DRG OCID."
  value       = module.nonprod_network.drg_id
}
