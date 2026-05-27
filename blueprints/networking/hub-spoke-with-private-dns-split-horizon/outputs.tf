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
  value       = merge(module.network.resource_ids, module.private_dns.resource_ids)
}

output "hub_vcn_id" {
  description = "Hub VCN OCID."
  value       = module.network.hub_vcn_id
}

output "spoke_vcn_ids" {
  description = "Spoke VCN OCIDs keyed by spoke name."
  value       = module.network.spoke_vcn_ids
}

output "private_view_id" {
  description = "Private DNS view OCID."
  value       = module.private_dns.private_view_id
}

output "private_zone_ids" {
  description = "Private DNS zone OCIDs keyed by logical name."
  value       = module.private_dns.private_zone_ids
}

output "vcn_resolver_ids" {
  description = "VCN resolver OCIDs keyed by VCN key."
  value       = module.private_dns.vcn_resolver_ids
}
