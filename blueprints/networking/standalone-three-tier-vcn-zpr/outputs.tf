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
