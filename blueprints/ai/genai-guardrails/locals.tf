# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "genai-guardrails"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "genai-guardrails"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  audit_bucket_name       = coalesce(var.audit_bucket_name, "${local.name_prefix}-audit")
  log_group_name          = coalesce(var.log_group_name, "${local.name_prefix}-logs")
  connector_display_name  = coalesce(var.connector_display_name, "${local.name_prefix}-connector")
  detector_display_name   = coalesce(var.detector_display_name, "${local.name_prefix}-detector")
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
