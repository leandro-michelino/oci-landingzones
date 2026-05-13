# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "operations-os-management"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Module = local.module_name
    }
  )

  managed_instance_groups = var.enable_os_management ? {
    for key, group in var.managed_instance_groups : key => {
      compartment_ocid      = try(group.compartment_ocid, null)
      display_name          = try(group.display_name, null)
      description           = try(group.description, "OS Management Hub managed instance group ${key} managed by Terraform.")
      arch_type             = try(group.arch_type, var.default_arch_type)
      os_family             = try(group.os_family, var.default_os_family)
      vendor_name           = try(group.vendor_name, var.default_vendor_name)
      location              = try(group.location, null)
      managed_instance_ids  = try(group.managed_instance_ids, [])
      notification_topic_id = try(group.notification_topic_id, null)
      software_source_ids   = try(group.software_source_ids, [])
    }
  } : {}

  scheduled_jobs = var.enable_os_management ? {
    for key, job in var.scheduled_jobs : key => {
      compartment_ocid           = try(job.compartment_ocid, null)
      display_name               = try(job.display_name, null)
      description                = try(job.description, "OS Management Hub scheduled job ${key} managed by Terraform.")
      schedule_type              = try(job.schedule_type, "RECURRING")
      time_next_execution        = job.time_next_execution
      recurring_rule             = try(job.recurring_rule, null)
      managed_compartment_ids    = try(job.managed_compartment_ids, [])
      managed_instance_group_ids = try(job.managed_instance_group_ids, [])
      managed_instance_ids       = try(job.managed_instance_ids, [])
      is_subcompartment_included = try(job.is_subcompartment_included, false)
      retry_intervals            = try(job.retry_intervals, [])
      operations                 = job.operations
    }
  } : {}
}
