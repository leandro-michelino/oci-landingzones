# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "extensions-oke"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  cluster_name            = "${local.name_prefix}-oke-${var.cluster_label}"
  node_pool_name          = "${local.name_prefix}-np-${var.node_pool_label}"
  cluster_id              = var.cluster_id != null ? var.cluster_id : try(oci_containerengine_cluster.this[0].id, null)
  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
    }
  )
}
