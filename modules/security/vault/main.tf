# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_kms_vault" "this" {
  for_each = local.vaults

  compartment_id = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-vlt-${each.key}")
  vault_type     = upper(each.value.vault_type)
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_kms_key" "this" {
  for_each = local.keys

  compartment_id           = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  display_name             = coalesce(each.value.display_name, "${local.name_prefix}-key-${each.key}")
  management_endpoint      = each.value.vault_management_endpoint != null ? each.value.vault_management_endpoint : try(oci_kms_vault.this[each.value.vault_key].management_endpoint, null)
  protection_mode          = each.value.protection_mode == null ? null : upper(each.value.protection_mode)
  desired_state            = each.value.desired_state
  is_auto_rotation_enabled = each.value.is_auto_rotation_enabled
  defined_tags             = var.defined_tags
  freeform_tags            = local.common_freeform_tags

  key_shape {
    algorithm = upper(each.value.algorithm)
    length    = each.value.length
    curve_id  = each.value.curve_id
  }

  dynamic "auto_key_rotation_details" {
    for_each = each.value.rotation_interval_in_days != null || each.value.time_of_schedule_start != null ? [each.value] : []

    content {
      rotation_interval_in_days = auto_key_rotation_details.value.rotation_interval_in_days
      time_of_schedule_start    = auto_key_rotation_details.value.time_of_schedule_start
    }
  }
}
