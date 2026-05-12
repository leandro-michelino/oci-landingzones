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
