# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  count          = var.create_archive_bucket ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_generative_ai_generative_ai_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.endpoint_display_name
  description    = var.description
  dns_prefix     = var.dns_prefix
  subnet_id      = var.subnet_id
  nsg_ids        = var.nsg_ids
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_objectstorage_bucket" "archive" {
  count = var.create_archive_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = local.archive_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = var.archive_storage_tier
  versioning            = var.archive_versioning
  object_events_enabled = var.archive_object_events_enabled
  kms_key_id            = var.kms_key_id
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-genai-policy"
  description    = "Scoped OCI Generative AI access for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
