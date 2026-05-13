# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "primary" {
  compartment_id = var.tenancy_ocid
}

data "oci_objectstorage_namespace" "standby" {
  provider       = oci.standby
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "primary_dr_logs" {
  count = var.enable_dr_log_buckets ? 1 : 0

  compartment_id        = local.primary_compartment_ocid
  name                  = local.primary_log_bucket_name
  namespace             = data.oci_objectstorage_namespace.primary.namespace
  access_type           = "NoPublicAccess"
  object_events_enabled = var.enable_object_events
  storage_tier          = var.log_bucket_storage_tier
  versioning            = var.enable_bucket_versioning ? "Enabled" : "Disabled"
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_objectstorage_bucket" "standby_dr_logs" {
  provider = oci.standby
  count    = var.enable_dr_log_buckets ? 1 : 0

  compartment_id        = local.standby_compartment_ocid
  name                  = local.standby_log_bucket_name
  namespace             = data.oci_objectstorage_namespace.standby.namespace
  access_type           = "NoPublicAccess"
  object_events_enabled = var.enable_object_events
  storage_tier          = var.log_bucket_storage_tier
  versioning            = var.enable_bucket_versioning ? "Enabled" : "Disabled"
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_disaster_recovery_dr_protection_group" "primary" {
  count = var.enable_dr_protection_groups ? 1 : 0

  compartment_id = local.primary_compartment_ocid
  display_name   = coalesce(var.primary_dr_protection_group_name, "${local.name_prefix}-drpg-primary")
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  log_location {
    bucket    = local.primary_log_bucket_name
    namespace = data.oci_objectstorage_namespace.primary.namespace
  }

  dynamic "members" {
    for_each = var.primary_members

    content {
      member_id   = members.value.member_id
      member_type = members.value.member_type
      is_movable  = members.value.is_movable
    }
  }

  depends_on = [oci_objectstorage_bucket.primary_dr_logs]
}

resource "oci_disaster_recovery_dr_protection_group" "standby" {
  provider = oci.standby
  count    = var.enable_dr_protection_groups ? 1 : 0

  compartment_id = local.standby_compartment_ocid
  display_name   = coalesce(var.standby_dr_protection_group_name, "${local.standby_name_prefix}-drpg-standby")
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  log_location {
    bucket    = local.standby_log_bucket_name
    namespace = data.oci_objectstorage_namespace.standby.namespace
  }

  dynamic "members" {
    for_each = var.standby_members

    content {
      member_id   = members.value.member_id
      member_type = members.value.member_type
      is_movable  = members.value.is_movable
    }
  }

  depends_on = [oci_objectstorage_bucket.standby_dr_logs]
}

resource "oci_disaster_recovery_dr_plan" "primary" {
  count = var.enable_dr_plan && var.enable_dr_protection_groups ? 1 : 0

  dr_protection_group_id = oci_disaster_recovery_dr_protection_group.primary[0].id
  display_name           = coalesce(var.dr_plan_display_name, "${local.name_prefix}-dr-plan-${lower(var.dr_plan_type)}")
  type                   = upper(var.dr_plan_type)
  defined_tags           = var.defined_tags
  freeform_tags          = local.common_freeform_tags
}
