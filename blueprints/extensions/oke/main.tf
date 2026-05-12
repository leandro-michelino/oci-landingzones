# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_containerengine_cluster" "this" {
  count = var.enable_cluster ? 1 : 0

  compartment_id     = local.target_compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = local.cluster_name
  vcn_id             = var.vcn_id
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags

  dynamic "cluster_pod_network_options" {
    for_each = var.cni_type == null ? [] : [var.cni_type]

    content {
      cni_type = cluster_pod_network_options.value
    }
  }

  dynamic "endpoint_config" {
    for_each = var.endpoint_subnet_id == null ? [] : [var.endpoint_subnet_id]

    content {
      is_public_ip_enabled = var.endpoint_public_ip_enabled
      nsg_ids              = var.endpoint_nsg_ids
      subnet_id            = endpoint_config.value
    }
  }

  dynamic "options" {
    for_each = length(var.service_lb_subnet_ids) == 0 ? [] : [var.service_lb_subnet_ids]

    content {
      service_lb_subnet_ids = options.value
    }
  }
}

resource "oci_containerengine_node_pool" "this" {
  count = var.enable_node_pool ? 1 : 0

  cluster_id          = local.cluster_id
  compartment_id      = local.target_compartment_ocid
  kubernetes_version  = var.kubernetes_version
  name                = local.node_pool_name
  node_shape          = var.node_shape
  quantity_per_subnet = var.node_quantity_per_subnet
  ssh_public_key      = var.ssh_public_key
  subnet_ids          = var.node_subnet_ids
  defined_tags        = var.defined_tags
  freeform_tags       = local.common_freeform_tags

  dynamic "node_shape_config" {
    for_each = var.node_shape_ocpus == null && var.node_shape_memory_in_gbs == null ? [] : [1]

    content {
      ocpus         = var.node_shape_ocpus
      memory_in_gbs = var.node_shape_memory_in_gbs
    }
  }

  dynamic "node_source_details" {
    for_each = var.node_image_id == null ? [] : [var.node_image_id]

    content {
      image_id    = node_source_details.value
      source_type = "IMAGE"
    }
  }
}
