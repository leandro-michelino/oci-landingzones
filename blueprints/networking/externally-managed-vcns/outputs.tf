output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}
output "resource_ids" {
  description = "Map of externally managed resource identifiers passed into this blueprint."
  value       = local.external_resource_ids
}

output "vcn_ids" {
  description = "Externally managed VCN OCIDs keyed by logical name."
  value       = var.vcn_ids
}

output "subnet_ids" {
  description = "Externally managed subnet OCIDs keyed by logical name."
  value       = var.subnet_ids
}

output "drg_id" {
  description = "Externally managed DRG OCID."
  value       = var.drg_id
}

output "route_target_ids" {
  description = "Externally managed route target OCIDs keyed by logical name."
  value       = var.route_target_ids
}
