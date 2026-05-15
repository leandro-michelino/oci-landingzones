# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "genai-private"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
  endpoint_display_name   = coalesce(var.endpoint_display_name, "${local.name_prefix}-pe-genai")
  archive_bucket_name     = coalesce(var.archive_bucket_name, "${local.name_prefix}-bkt-genai-archive")
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
}
