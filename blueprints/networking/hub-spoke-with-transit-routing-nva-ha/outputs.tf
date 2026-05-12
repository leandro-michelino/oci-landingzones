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
  value       = merge(module.network.resource_ids, module.nva_ha.resource_ids)
}

output "hub_vcn_id" {
  description = "Hub VCN OCID."
  value       = module.network.hub_vcn_id
}

output "drg_id" {
  description = "DRG OCID."
  value       = module.network.drg_id
}

output "spoke_vcn_ids" {
  description = "Spoke VCN OCIDs keyed by spoke name."
  value       = module.network.spoke_vcn_ids
}

output "appliance_instance_ids" {
  description = "HA NVA compute instance OCIDs."
  value       = module.nva_ha.appliance_instance_ids
}

output "route_target_private_ip_ids" {
  description = "HA route target private IP OCIDs."
  value       = module.nva_ha.route_target_private_ip_ids
}
