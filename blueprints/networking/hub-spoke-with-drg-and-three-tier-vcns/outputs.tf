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
  description = "Map of primary resource identifiers created by this blueprint."
  value = {
    hub_vcn        = module.hub_vcn.vcn_id
    drg            = module.drg.drg_id
    hub_attachment = oci_core_drg_attachment.hub.id
  }
}

output "hub_vcn_id" {
  description = "Hub VCN OCID."
  value       = module.hub_vcn.vcn_id
}

output "drg_id" {
  description = "DRG OCID."
  value       = module.drg.drg_id
}

output "hub_subnet_ids" {
  description = "Hub subnet OCIDs keyed by role."
  value       = module.hub_vcn.subnet_ids
}

output "spoke_vcn_ids" {
  description = "Spoke VCN OCIDs keyed by spoke name."
  value       = { for key, spoke in module.spoke_vcns : key => spoke.vcn_id }
}

output "spoke_subnet_ids" {
  description = "Spoke subnet OCIDs keyed by spoke name."
  value       = { for key, spoke in module.spoke_vcns : key => spoke.subnet_ids }
}

output "drg_attachment_ids" {
  description = "DRG attachment OCIDs."
  value = merge(
    { hub = oci_core_drg_attachment.hub.id },
    { for key, attachment in oci_core_drg_attachment.spokes : key => attachment.id }
  )
}
