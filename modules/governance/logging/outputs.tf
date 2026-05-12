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
      for key, log_group in oci_logging_log_group.this : "log_group.${key}" => log_group.id
    },
    {
      for key, log in oci_logging_log.service : "service_log.${key}" => log.id
    },
    {
      for key, search in oci_logging_log_saved_search.this : "saved_search.${key}" => search.id
    },
    var.enable_audit_retention ? {
      audit_configuration = oci_audit_configuration.this[0].id
    } : {}
  )
}

output "log_group_ids" {
  description = "Map of log group keys to OCIDs."
  value = {
    for key, log_group in oci_logging_log_group.this : key => log_group.id
  }
}

output "log_group_names" {
  description = "Map of log group keys to display names."
  value = {
    for key, log_group in oci_logging_log_group.this : key => log_group.display_name
  }
}

output "service_log_ids" {
  description = "Map of service log keys to OCIDs."
  value = {
    for key, log in oci_logging_log.service : key => log.id
  }
}

output "saved_search_ids" {
  description = "Map of saved search keys to OCIDs."
  value = {
    for key, search in oci_logging_log_saved_search.this : key => search.id
  }
}

output "audit_configuration_id" {
  description = "OCID of the tenancy audit configuration when managed by this module."
  value       = try(oci_audit_configuration.this[0].id, null)
}
