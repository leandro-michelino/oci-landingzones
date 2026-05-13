# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "genai-private"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "genai-private"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
  endpoint_display_name   = coalesce(var.endpoint_display_name, "${local.name_prefix}-genai-pe")
  archive_bucket_name     = coalesce(var.archive_bucket_name, "${local.name_prefix}-genai-archive")
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
}
