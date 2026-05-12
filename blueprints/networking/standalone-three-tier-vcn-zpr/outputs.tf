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
  value       = merge(module.workload_vcn.resource_ids, module.zpr.resource_ids)
}

output "vcn_id" {
  description = "Workload VCN OCID."
  value       = module.workload_vcn.vcn_id
}

output "subnet_ids" {
  description = "Subnet OCIDs keyed by tier."
  value       = module.workload_vcn.subnet_ids
}

output "zpr_configuration_id" {
  description = "ZPR configuration OCID."
  value       = module.zpr.zpr_configuration_id
}

output "zpr_policy_ids" {
  description = "ZPR policy OCIDs keyed by logical name."
  value       = module.zpr.zpr_policy_ids
}
