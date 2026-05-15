# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "genai-fine-tuning"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  training_bucket_name    = coalesce(var.training_bucket_name, "${local.name_prefix}-bkt-training")
  cluster_display_name    = coalesce(var.cluster_display_name, "${local.name_prefix}-cluster-default")
  model_display_name      = coalesce(var.model_display_name, "${local.name_prefix}-model-default")
  endpoint_display_name   = coalesce(var.endpoint_display_name, "${local.name_prefix}-ep-default")
  cluster_id              = var.create_dedicated_ai_cluster ? try(oci_generative_ai_dedicated_ai_cluster.this[0].id, null) : var.dedicated_ai_cluster_id
  model_id                = var.create_fine_tuned_model ? try(oci_generative_ai_model.this[0].id, null) : var.model_id
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
