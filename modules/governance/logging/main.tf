# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_logging_log_group" "this" {
  for_each = local.log_groups

  compartment_id = var.compartment_ocid
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-lg-${each.key}")
  description    = coalesce(each.value.description, "Landing zone ${each.key} log group managed by Terraform.")
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_logging_log" "service" {
  for_each = local.service_logs

  display_name       = coalesce(each.value.display_name, "${local.name_prefix}-log-${each.key}")
  log_group_id       = oci_logging_log_group.this[each.value.log_group_key].id
  log_type           = "SERVICE"
  is_enabled         = each.value.is_enabled
  retention_duration = each.value.retention_duration
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags

  configuration {
    compartment_id = coalesce(each.value.compartment_ocid, var.compartment_ocid)

    source {
      category    = each.value.category
      resource    = each.value.resource_id
      service     = each.value.service
      source_type = each.value.source_type
      parameters  = each.value.parameters
    }
  }
}

resource "oci_logging_log_saved_search" "this" {
  for_each = var.enable_logging ? var.saved_searches : {}

  compartment_id = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  name           = coalesce(each.value.name, "${local.name_prefix}-search-${each.key}")
  query          = each.value.query
  description    = coalesce(each.value.description, "Landing zone logging saved search ${each.key}.")
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_audit_configuration" "this" {
  count = var.enable_audit_retention ? 1 : 0

  compartment_id        = var.tenancy_ocid
  retention_period_days = var.audit_retention_period_days
}
