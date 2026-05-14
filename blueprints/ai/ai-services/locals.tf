# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "ai-services"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "ai-services"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  bucket_names = {
    input  = coalesce(var.input_bucket_name, "${local.name_prefix}-input")
    output = coalesce(var.output_bucket_name, "${local.name_prefix}-output")
  }
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
