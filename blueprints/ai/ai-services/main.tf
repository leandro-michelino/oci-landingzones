# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  count          = var.create_buckets ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "this" {
  for_each = var.create_buckets ? local.bucket_names : {}

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = each.value
  access_type           = "NoPublicAccess"
  storage_tier          = var.bucket_storage_tier
  versioning            = var.bucket_versioning
  object_events_enabled = true
  kms_key_id            = var.kms_key_id
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_ai_document_project" "document" {
  count = var.enable_document_project ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = "${local.name_prefix}-aip-document"
  description    = var.project_description
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_ai_language_project" "language" {
  count = var.enable_language_project ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = "${local.name_prefix}-aip-language"
  description    = var.project_description
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_ai_vision_project" "vision" {
  count = var.enable_vision_project ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = "${local.name_prefix}-aip-vision"
  description    = var.project_description
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_ai_vision_vision_private_endpoint" "this" {
  count = var.create_vision_private_endpoint ? 1 : 0

  compartment_id = local.target_compartment_ocid
  subnet_id      = var.vision_private_endpoint_subnet_id
  display_name   = coalesce(var.vision_private_endpoint_display_name, "${local.name_prefix}-pe-vision")
  description    = "Private endpoint for OCI Vision workloads."
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-access"
  description    = "OCI AI Services access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
