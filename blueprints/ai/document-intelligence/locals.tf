# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "document-intelligence"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  bucket_names = {
    intake = coalesce(var.intake_bucket_name, "${local.name_prefix}-bkt-intake")
    output = coalesce(var.output_bucket_name, "${local.name_prefix}-bkt-output")
    failed = coalesce(var.failed_bucket_name, "${local.name_prefix}-bkt-failed")
  }
  project_display_name = coalesce(var.project_display_name, "${local.name_prefix}-aip-project")
  event_rule_name      = coalesce(var.event_rule_display_name, "${local.name_prefix}-evt-ingest")
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
