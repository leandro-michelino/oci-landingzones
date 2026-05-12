# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "module_name" {
  description = "Module identifier."
  value       = local.module_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this module."
  value       = local.name_prefix
}

output "cis_level" {
  description = "Selected CIS OCI Benchmark profile."
  value       = local.cis_level
}

output "resource_ids" {
  description = "Map of primary resource identifiers created by this module."
  value = merge(
    { drg = oci_core_drg.this.id },
    { for key, attachment in oci_core_drg_attachment.vcn : "attachment_${key}" => attachment.id }
  )
}

output "drg_id" {
  description = "DRG OCID."
  value       = oci_core_drg.this.id
}

output "vcn_attachment_ids" {
  description = "DRG VCN attachment OCIDs keyed by logical attachment name."
  value       = { for key, attachment in oci_core_drg_attachment.vcn : key => attachment.id }
}
