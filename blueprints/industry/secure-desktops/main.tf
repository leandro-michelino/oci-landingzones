# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_desktops_desktop_pool" "this" {
  count = var.create_desktop_pool ? 1 : 0

  compartment_id           = local.target_compartment_ocid
  display_name             = local.desktop_pool_name
  description              = var.desktop_pool_description
  availability_domain      = var.availability_domain
  contact_details          = var.contact_details
  maximum_size             = var.maximum_size
  standby_size             = var.standby_size
  shape_name               = var.shape_name
  boot_volume_size_in_gbs  = var.boot_volume_size_in_gbs
  nsg_ids                  = var.nsg_ids
  are_privileged_users     = var.are_privileged_users
  are_volumes_preserved    = var.are_volumes_preserved
  is_storage_enabled       = var.is_storage_enabled
  storage_backup_policy_id = var.storage_backup_policy_id
  storage_size_in_gbs      = var.storage_size_in_gbs
  time_start_scheduled     = var.time_start_scheduled
  time_stop_scheduled      = var.time_stop_scheduled
  use_dedicated_vm_host    = var.use_dedicated_vm_host
  defined_tags             = var.defined_tags
  freeform_tags            = local.desktop_pool_freeform_tags

  availability_policy {
    dynamic "start_schedule" {
      for_each = var.start_schedule == null ? [] : [var.start_schedule]

      content {
        cron_expression = start_schedule.value.cron_expression
        timezone        = start_schedule.value.timezone
      }
    }

    dynamic "stop_schedule" {
      for_each = var.stop_schedule == null ? [] : [var.stop_schedule]

      content {
        cron_expression = stop_schedule.value.cron_expression
        timezone        = stop_schedule.value.timezone
      }
    }
  }

  device_policy {
    audio_mode             = var.device_policy.audio_mode
    cdm_mode               = var.device_policy.cdm_mode
    clipboard_mode         = var.device_policy.clipboard_mode
    is_display_enabled     = var.device_policy.is_display_enabled
    is_keyboard_enabled    = var.device_policy.is_keyboard_enabled
    is_pointer_enabled     = var.device_policy.is_pointer_enabled
    is_printing_enabled    = var.device_policy.is_printing_enabled
    is_video_input_enabled = var.device_policy.is_video_input_enabled
  }

  image {
    image_id         = var.image_id
    image_name       = var.image_name
    operating_system = var.image_operating_system
  }

  network_configuration {
    subnet_id = var.subnet_id
    vcn_id    = var.vcn_id
  }

  dynamic "private_access_details" {
    for_each = var.private_access_subnet_id == null ? [] : [1]

    content {
      subnet_id     = var.private_access_subnet_id
      vcn_id        = var.private_access_vcn_id
      nsg_ids       = var.private_access_nsg_ids
      private_ip    = var.private_access_private_ip
      endpoint_fqdn = var.private_access_endpoint_fqdn
    }
  }

  dynamic "session_lifecycle_actions" {
    for_each = var.enable_session_lifecycle_actions ? [1] : []

    content {
      dynamic "disconnect" {
        for_each = var.disconnect_action == null ? [] : [var.disconnect_action]

        content {
          action                  = disconnect.value.action
          grace_period_in_minutes = disconnect.value.grace_period_in_minutes
        }
      }

      dynamic "inactivity" {
        for_each = var.inactivity_action == null ? [] : [var.inactivity_action]

        content {
          action                  = inactivity.value.action
          grace_period_in_minutes = inactivity.value.grace_period_in_minutes
        }
      }
    }
  }

  dynamic "shape_config" {
    for_each = var.shape_config == null ? [] : [var.shape_config]

    content {
      baseline_ocpu_utilization = shape_config.value.baseline_ocpu_utilization
      ocpus                     = shape_config.value.ocpus
      memory_in_gbs             = shape_config.value.memory_in_gbs
    }
  }
}

resource "oci_monitoring_alarm" "this" {
  for_each = var.alarms

  compartment_id        = local.target_compartment_ocid
  display_name          = coalesce(each.value.display_name, "${local.name_prefix}-alm-${each.key}")
  namespace             = each.value.namespace
  query                 = each.value.query
  severity              = each.value.severity
  destinations          = each.value.destinations
  metric_compartment_id = coalesce(each.value.metric_compartment_id, local.target_compartment_ocid)
  body                  = each.value.body
  is_enabled            = each.value.is_enabled
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-access"
  description    = "Secure Desktops access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
