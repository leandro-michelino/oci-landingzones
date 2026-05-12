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
  description = "Map of resource identifiers created by this module."
  value = merge(
    { configuration = try(oci_zpr_configuration.this[0].id, null) },
    { for key, policy in oci_zpr_zpr_policy.this : "policy_${key}" => policy.id }
  )
}

output "zpr_configuration_id" {
  description = "ZPR configuration OCID."
  value       = try(oci_zpr_configuration.this[0].id, null)
}

output "zpr_policy_ids" {
  description = "ZPR policy OCIDs keyed by logical policy name."
  value       = { for key, policy in oci_zpr_zpr_policy.this : key => policy.id }
}
