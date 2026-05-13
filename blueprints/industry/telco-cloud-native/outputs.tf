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
    { for key, id in module.network.resource_ids : "network.${key}" => id },
    { for key, id in module.vault.resource_ids : "vault.${key}" => id },
    { for key, id in module.oke.resource_ids : "oke.${key}" => id },
    { for key, id in module.monitoring.resource_ids : "monitoring.${key}" => id },
    { for key, id in module.os_management.resource_ids : "os_management.${key}" => id }
  )
}

output "hub_vcn_id" {
  description = "Telco hub VCN OCID."
  value       = module.network.hub_vcn_id
}

output "drg_id" {
  description = "Telco DRG OCID."
  value       = module.network.drg_id
}

output "hub_subnet_ids" {
  description = "Hub subnet OCIDs keyed by role."
  value       = module.network.hub_subnet_ids
}

output "oke_cluster_id" {
  description = "OKE cluster OCID."
  value       = module.oke.cluster_id
}

output "oke_node_pool_id" {
  description = "OKE node pool OCID."
  value       = module.oke.node_pool_id
}

output "vault_ids" {
  description = "Vault OCIDs keyed by logical name."
  value       = module.vault.vault_ids
}

output "monitoring_alarm_ids" {
  description = "Monitoring alarm OCIDs keyed by logical name."
  value       = module.monitoring.alarm_ids
}

output "os_management_resource_ids" {
  description = "OS Management Hub resource identifiers."
  value       = module.os_management.resource_ids
}
