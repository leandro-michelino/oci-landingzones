# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "document-intelligence"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "doc-intel"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  bucket_names = {
    intake = coalesce(var.intake_bucket_name, "${local.name_prefix}-intake")
    output = coalesce(var.output_bucket_name, "${local.name_prefix}-output")
    failed = coalesce(var.failed_bucket_name, "${local.name_prefix}-failed")
  }
  project_display_name = coalesce(var.project_display_name, "${local.name_prefix}-project")
  event_rule_name      = coalesce(var.event_rule_display_name, "${local.name_prefix}-ingest")
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
