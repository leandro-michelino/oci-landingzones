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
  value       = merge(module.network.resource_ids, module.shared_dns.resource_ids)
}

output "hub_vcn_id" {
  description = "Hub VCN OCID."
  value       = module.network.hub_vcn_id
}

output "spoke_vcn_ids" {
  description = "Spoke VCN OCIDs keyed by tenant or workload name."
  value       = module.network.spoke_vcn_ids
}

output "private_view_id" {
  description = "Shared services private DNS view OCID."
  value       = module.shared_dns.private_view_id
}

output "private_zone_ids" {
  description = "Shared services private DNS zone OCIDs."
  value       = module.shared_dns.private_zone_ids
}
