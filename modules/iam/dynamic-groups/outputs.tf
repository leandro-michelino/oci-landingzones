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

output "dynamic_group_ids" {
  description = "Map of dynamic group keys to OCIDs."
  value = {
    for key, dynamic_group in oci_identity_dynamic_group.this : key => dynamic_group.id
  }
}

output "dynamic_group_names" {
  description = "Map of dynamic group keys to names."
  value = {
    for key, dynamic_group in oci_identity_dynamic_group.this : key => dynamic_group.name
  }
}

output "resource_ids" {
  description = "Map of resource identifiers created by this module."
  value = {
    for key, dynamic_group in oci_identity_dynamic_group.this : key => dynamic_group.id
  }
}
