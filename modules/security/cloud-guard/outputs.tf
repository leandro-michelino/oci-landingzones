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
    var.enable_cloud_guard ? {
      cloud_guard_configuration = oci_cloud_guard_cloud_guard_configuration.this[0].id
    } : {},
    {
      for key, target in oci_cloud_guard_target.this : "target.${key}" => target.id
    }
  )
}

output "cloud_guard_configuration_id" {
  description = "OCID of the Cloud Guard configuration when managed by this module."
  value       = try(oci_cloud_guard_cloud_guard_configuration.this[0].id, null)
}

output "target_ids" {
  description = "Map of Cloud Guard target keys to OCIDs."
  value = {
    for key, target in oci_cloud_guard_target.this : key => target.id
  }
}

output "target_names" {
  description = "Map of Cloud Guard target keys to display names."
  value = {
    for key, target in oci_cloud_guard_target.this : key => target.display_name
  }
}
