# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "genai-guardrails"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  audit_bucket_name       = coalesce(var.audit_bucket_name, "${local.name_prefix}-bkt-audit")
  log_group_name          = coalesce(var.log_group_name, "${local.name_prefix}-lg-logs")
  connector_display_name  = coalesce(var.connector_display_name, "${local.name_prefix}-sch-connector")
  detector_display_name   = coalesce(var.detector_display_name, "${local.name_prefix}-cg-detector")
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
