# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  count          = var.create_training_bucket ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "training" {
  count = var.create_training_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = local.training_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = var.training_bucket_storage_tier
  versioning            = var.training_bucket_versioning
  object_events_enabled = true
  kms_key_id            = var.kms_key_id
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_generative_ai_dedicated_ai_cluster" "this" {
  count = var.create_dedicated_ai_cluster ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.cluster_display_name
  description    = "Dedicated AI cluster for ${local.name_prefix}."
  type           = var.cluster_type
  unit_count     = var.cluster_unit_count
  unit_shape     = var.cluster_unit_shape
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_generative_ai_model" "this" {
  count = var.create_fine_tuned_model ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.model_display_name
  description    = var.model_description
  base_model_id  = var.base_model_id
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  fine_tune_details {
    dedicated_ai_cluster_id = local.cluster_id

    training_dataset {
      bucket       = coalesce(var.training_dataset_bucket, local.training_bucket_name)
      namespace    = coalesce(var.training_dataset_namespace, try(data.oci_objectstorage_namespace.this[0].namespace, null))
      object       = var.training_dataset_object
      dataset_type = var.training_dataset_type
    }

    training_config {
      training_config_type  = var.training_config_type
      total_training_epochs = var.total_training_epochs
      training_batch_size   = var.training_batch_size
      learning_rate         = var.learning_rate
    }
  }
}

resource "oci_generative_ai_endpoint" "this" {
  count = var.create_endpoint ? 1 : 0

  compartment_id                    = local.target_compartment_ocid
  display_name                      = local.endpoint_display_name
  description                       = var.endpoint_description
  dedicated_ai_cluster_id           = local.cluster_id
  model_id                          = local.model_id
  generative_ai_private_endpoint_id = var.generative_ai_private_endpoint_id
  defined_tags                      = var.defined_tags
  freeform_tags                     = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-access"
  description    = "GenAI fine-tuning access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
