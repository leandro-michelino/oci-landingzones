# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "extensions-eks-oke-active-active"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)

  oke_cluster_name   = "${local.name_prefix}-cluster-${var.oke_cluster_label}"
  oke_node_pool_name = "${local.name_prefix}-np-${var.oke_node_pool_label}"

  oke_vcn_name               = "${local.name_prefix}-vcn-oke"
  oke_igw_name               = "${local.name_prefix}-igw-oke"
  oke_route_table_name       = "${local.name_prefix}-rt-oke"
  oke_endpoint_sl_name       = "${local.name_prefix}-sl-oke-endpoint"
  oke_node_sl_name           = "${local.name_prefix}-sl-oke-node"
  oke_endpoint_subnet_name   = "${local.name_prefix}-sn-oke-endpoint"
  oke_service_lb_subnet_name = "${local.name_prefix}-sn-oke-lb"
  oke_node_subnet_base_name  = "${local.name_prefix}-sn-oke-node"

  effective_oke_vcn_id                = var.enable_oke_networking ? try(oci_core_vcn.oke[0].id, null) : var.oke_vcn_id
  effective_oke_endpoint_subnet_id    = var.enable_oke_networking ? try(oci_core_subnet.oke_endpoint[0].id, null) : var.oke_endpoint_subnet_id
  effective_oke_service_lb_subnet_ids = var.enable_oke_networking ? try([oci_core_subnet.oke_service_lb[0].id], []) : var.oke_service_lb_subnet_ids
  effective_oke_node_subnet_ids       = var.enable_oke_networking ? [for subnet in oci_core_subnet.oke_nodes : subnet.id] : var.oke_node_subnet_ids

  effective_oke_cluster_id = var.oke_cluster_id != null ? var.oke_cluster_id : try(oci_containerengine_cluster.oci_primary[0].id, null)

  traffic_weights = {
    oci_primary   = var.oci_primary_traffic_percent
    aws_secondary = 100 - var.oci_primary_traffic_percent
  }

  interconnect_contract = {
    mode                           = var.interconnect_mode
    fastconnect_virtual_circuit_id = var.fastconnect_virtual_circuit_id
    direct_connect_connection_id   = var.direct_connect_connection_id
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
