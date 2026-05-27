locals {
  blueprint_name          = "opensearch"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  cluster_display_name    = coalesce(var.cluster_display_name, "${local.name_prefix}-cluster-default")
  snapshot_bucket_name    = coalesce(var.snapshot_bucket_name, "${local.name_prefix}-bkt-snapshots")
  vcn_display_name        = coalesce(var.vcn_display_name, "${local.name_prefix}-vcn-opensearch")
  subnet_display_name     = coalesce(var.subnet_display_name, "${local.name_prefix}-sn-opensearch")
  nsg_display_name        = coalesce(var.nsg_display_name, "${local.name_prefix}-nsg-opensearch")
  effective_vcn_id        = coalesce(var.vcn_id, try(oci_core_vcn.opensearch[0].id, null))
  effective_subnet_id     = coalesce(var.subnet_id, try(oci_core_subnet.opensearch[0].id, null))
  effective_nsg_id        = coalesce(var.nsg_id, try(oci_core_network_security_group.opensearch[0].id, null))
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
