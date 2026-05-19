# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "extensions-aks-oke-active-active"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)

  oke_cluster_name   = "${local.name_prefix}-cluster-${var.oke_cluster_label}"
  oke_node_pool_name = "${local.name_prefix}-np-${var.oke_node_pool_label}"

  effective_oke_cluster_id = var.oke_cluster_id != null ? var.oke_cluster_id : try(oci_containerengine_cluster.oci_primary[0].id, null)

  traffic_weights = {
    oci_primary     = var.oci_primary_traffic_percent
    azure_secondary = 100 - var.oci_primary_traffic_percent
  }

  interconnect_contract = {
    mode                           = var.interconnect_mode
    fastconnect_virtual_circuit_id = var.fastconnect_virtual_circuit_id
    expressroute_circuit_id        = var.expressroute_circuit_id
    ipsec_backup_enabled           = var.enable_ipsec_backup
  }

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
      ManagedBy = "terraform"
      Primary   = "oci"
    }
  )
}
