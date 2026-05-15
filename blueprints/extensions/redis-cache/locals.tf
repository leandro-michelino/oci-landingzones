# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "redis-cache"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  cluster_display_name    = coalesce(var.cluster_display_name, "${local.name_prefix}-cluster-default")
  redis_cluster_id        = var.create_cluster ? try(oci_redis_redis_cluster.this[0].id, null) : var.redis_cluster_id

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
