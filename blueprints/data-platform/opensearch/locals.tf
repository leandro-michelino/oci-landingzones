# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "opensearch"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  cluster_display_name    = coalesce(var.cluster_display_name, "${local.name_prefix}-cluster-default")
  snapshot_bucket_name    = coalesce(var.snapshot_bucket_name, "${local.name_prefix}-bkt-snapshots")
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
