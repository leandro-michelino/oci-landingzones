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
    {
      for key, recipe in oci_vulnerability_scanning_host_scan_recipe.this : "host_scan_recipe.${key}" => recipe.id
    },
    {
      for key, target in oci_vulnerability_scanning_host_scan_target.this : "host_scan_target.${key}" => target.id
    },
    {
      for key, recipe in oci_vulnerability_scanning_container_scan_recipe.this : "container_scan_recipe.${key}" => recipe.id
    },
    {
      for key, target in oci_vulnerability_scanning_container_scan_target.this : "container_scan_target.${key}" => target.id
    }
  )
}

output "host_scan_recipe_ids" {
  description = "Map of host scan recipe keys to OCIDs."
  value = {
    for key, recipe in oci_vulnerability_scanning_host_scan_recipe.this : key => recipe.id
  }
}

output "host_scan_target_ids" {
  description = "Map of host scan target keys to OCIDs."
  value = {
    for key, target in oci_vulnerability_scanning_host_scan_target.this : key => target.id
  }
}

output "container_scan_recipe_ids" {
  description = "Map of container scan recipe keys to OCIDs."
  value = {
    for key, recipe in oci_vulnerability_scanning_container_scan_recipe.this : key => recipe.id
  }
}

output "container_scan_target_ids" {
  description = "Map of container scan target keys to OCIDs."
  value = {
    for key, target in oci_vulnerability_scanning_container_scan_target.this : key => target.id
  }
}
