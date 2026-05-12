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
  value       = merge(module.network.resource_ids, module.bastion.resource_ids)
}

output "hub_vcn_id" {
  description = "Hub VCN OCID."
  value       = module.network.hub_vcn_id
}

output "drg_id" {
  description = "DRG OCID."
  value       = module.network.drg_id
}

output "hub_subnet_ids" {
  description = "Hub subnet OCIDs keyed by role."
  value       = module.network.hub_subnet_ids
}

output "spoke_vcn_ids" {
  description = "Spoke VCN OCIDs keyed by spoke name."
  value       = module.network.spoke_vcn_ids
}

output "bastion_id" {
  description = "OCI Bastion OCID."
  value       = module.bastion.bastion_id
}

output "bastion_private_endpoint_ip_address" {
  description = "OCI Bastion private endpoint IP address."
  value       = module.bastion.private_endpoint_ip_address
}
