# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  count          = var.create_audit_bucket ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "audit" {
  count = var.create_audit_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = local.audit_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = var.audit_bucket_storage_tier
  versioning            = var.audit_bucket_versioning
  object_events_enabled = true
  kms_key_id            = var.kms_key_id
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_logging_log_group" "guardrails" {
  count = var.create_log_group ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.log_group_name
  description    = "GenAI guardrail telemetry for ${local.name_prefix}."
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_sch_service_connector" "audit" {
  count = var.create_service_connector ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.connector_display_name
  description    = var.connector_description
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  source {
    kind = var.connector_source_kind

    log_sources {
      compartment_id = local.target_compartment_ocid
      log_group_id   = var.connector_source_log_group_id
      log_id         = var.connector_source_log_id
    }
  }

  target {
    kind               = var.connector_target_kind
    namespace          = coalesce(var.connector_target_namespace, try(data.oci_objectstorage_namespace.this[0].namespace, null))
    bucket             = coalesce(var.connector_target_bucket, local.audit_bucket_name)
    object_name_prefix = var.connector_object_prefix
    stream_id          = var.connector_target_stream_id
  }
}

resource "oci_cloud_guard_detector_recipe" "genai" {
  count = var.create_cloud_guard_recipe ? 1 : 0

  compartment_id            = local.target_compartment_ocid
  display_name              = local.detector_display_name
  description               = "Detector recipe placeholder for unusual GenAI usage in ${local.name_prefix}."
  detector                  = var.detector
  source_detector_recipe_id = var.source_detector_recipe_id
  defined_tags              = var.defined_tags
  freeform_tags             = local.common_freeform_tags
}

resource "oci_monitoring_alarm" "this" {
  for_each = var.alarms

  compartment_id        = local.target_compartment_ocid
  display_name          = coalesce(each.value.display_name, "${local.name_prefix}-alm-${each.key}")
  is_enabled            = coalesce(each.value.is_enabled, true)
  metric_compartment_id = coalesce(each.value.metric_compartment_id, local.target_compartment_ocid)
  namespace             = each.value.namespace
  query                 = each.value.query
  severity              = each.value.severity
  destinations          = coalesce(each.value.destinations, compact([var.notification_topic_id]))
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-access"
  description    = "GenAI guardrails access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
