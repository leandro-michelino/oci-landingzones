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
  value = {
    for key, zone in oci_cloud_guard_security_zone.this : "security_zone.${key}" => zone.id
  }
}

output "security_zone_ids" {
  description = "Map of Security Zone keys to OCIDs."
  value = {
    for key, zone in oci_cloud_guard_security_zone.this : key => zone.id
  }
}

output "security_zone_names" {
  description = "Map of Security Zone keys to display names."
  value = {
    for key, zone in oci_cloud_guard_security_zone.this : key => zone.display_name
  }
}

output "security_zone_target_ids" {
  description = "Map of Security Zone keys to target OCIDs."
  value = {
    for key, zone in oci_cloud_guard_security_zone.this : key => zone.security_zone_target_id
  }
}

output "security_zone_recipe_ids" {
  description = "Map of Security Zone keys to recipe OCIDs."
  value = {
    for key, zone in oci_cloud_guard_security_zone.this : key => zone.security_zone_recipe_id
  }
}
