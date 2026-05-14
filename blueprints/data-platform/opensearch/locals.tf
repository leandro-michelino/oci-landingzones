# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "opensearch"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "opensearch"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  cluster_display_name    = coalesce(var.cluster_display_name, "${local.name_prefix}-cluster")
  snapshot_bucket_name    = coalesce(var.snapshot_bucket_name, "${local.name_prefix}-snapshots")
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
