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
  value       = module.private_vcn.resource_ids
}

output "vcn_id" {
  description = "Private VCN OCID."
  value       = module.private_vcn.vcn_id
}

output "subnet_ids" {
  description = "Subnet OCIDs keyed by role."
  value       = module.private_vcn.subnet_ids
}

output "route_table_ids" {
  description = "Route table OCIDs keyed by role."
  value       = module.private_vcn.route_table_ids
}

output "gateway_ids" {
  description = "Gateway OCIDs keyed by type."
  value       = module.private_vcn.gateway_ids
}
