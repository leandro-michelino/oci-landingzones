# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_os_management_hub_managed_instance_group" "this" {
  for_each = local.managed_instance_groups

  arch_type             = upper(each.value.arch_type)
  compartment_id        = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  display_name          = coalesce(each.value.display_name, "${local.name_prefix}-osmh-mig-${each.key}")
  os_family             = upper(each.value.os_family)
  vendor_name           = each.value.vendor_name
  description           = each.value.description
  location              = each.value.location
  managed_instance_ids  = tolist(each.value.managed_instance_ids)
  notification_topic_id = each.value.notification_topic_id
  software_source_ids   = tolist(each.value.software_source_ids)
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_os_management_hub_scheduled_job" "this" {
  for_each = local.scheduled_jobs

  compartment_id             = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  display_name               = coalesce(each.value.display_name, "${local.name_prefix}-osmh-job-${each.key}")
  description                = each.value.description
  schedule_type              = upper(each.value.schedule_type)
  time_next_execution        = each.value.time_next_execution
  recurring_rule             = each.value.recurring_rule
  managed_compartment_ids    = tolist(each.value.managed_compartment_ids)
  managed_instance_group_ids = tolist(each.value.managed_instance_group_ids)
  managed_instance_ids       = tolist(each.value.managed_instance_ids)
  is_subcompartment_included = each.value.is_subcompartment_included
  retry_intervals            = tolist(each.value.retry_intervals)
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags

  dynamic "operations" {
    for_each = each.value.operations

    content {
      operation_type         = upper(operations.value.operation_type)
      package_names          = tolist(operations.value.package_names)
      reboot_timeout_in_mins = operations.value.reboot_timeout_in_mins
      software_source_ids    = tolist(operations.value.software_source_ids)
      windows_update_names   = tolist(operations.value.windows_update_names)
    }
  }
}
