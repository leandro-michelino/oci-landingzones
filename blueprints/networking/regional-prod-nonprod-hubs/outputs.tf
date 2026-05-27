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
