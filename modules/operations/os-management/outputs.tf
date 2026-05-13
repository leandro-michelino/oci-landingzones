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
      for key, group in oci_os_management_hub_managed_instance_group.this : "managed_instance_group.${key}" => group.id
    },
    {
      for key, job in oci_os_management_hub_scheduled_job.this : "scheduled_job.${key}" => job.id
    }
  )
}

output "managed_instance_group_ids" {
  description = "OS Management Hub managed instance group OCIDs keyed by logical name."
  value = {
    for key, group in oci_os_management_hub_managed_instance_group.this : key => group.id
  }
}

output "scheduled_job_ids" {
  description = "OS Management Hub scheduled job OCIDs keyed by logical name."
  value = {
    for key, job in oci_os_management_hub_scheduled_job.this : key => job.id
  }
}
