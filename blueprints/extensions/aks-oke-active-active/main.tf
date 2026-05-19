# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_containerengine_cluster" "oci_primary" {
  count = var.enable_oke_cluster ? 1 : 0

  compartment_id     = local.target_compartment_ocid
  kubernetes_version = var.oke_kubernetes_version
  name               = local.oke_cluster_name
  vcn_id             = var.oke_vcn_id
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags

  dynamic "cluster_pod_network_options" {
    for_each = var.oke_cni_type == null ? [] : [var.oke_cni_type]

    content {
      cni_type = cluster_pod_network_options.value
    }
  }

  dynamic "endpoint_config" {
    for_each = var.oke_endpoint_subnet_id == null ? [] : [var.oke_endpoint_subnet_id]

    content {
      is_public_ip_enabled = var.oke_endpoint_public_ip_enabled
      nsg_ids              = var.oke_endpoint_nsg_ids
      subnet_id            = endpoint_config.value
    }
  }

  dynamic "options" {
    for_each = length(var.oke_service_lb_subnet_ids) == 0 ? [] : [var.oke_service_lb_subnet_ids]

    content {
      service_lb_subnet_ids = options.value
    }
  }
}

resource "oci_containerengine_node_pool" "oci_primary" {
  count = var.enable_oke_node_pool ? 1 : 0

  cluster_id          = local.effective_oke_cluster_id
  compartment_id      = local.target_compartment_ocid
  kubernetes_version  = var.oke_kubernetes_version
  name                = local.oke_node_pool_name
  node_shape          = var.oke_node_shape
  quantity_per_subnet = var.oke_node_quantity_per_subnet
  ssh_public_key      = var.oke_ssh_public_key
  subnet_ids          = var.oke_node_subnet_ids
  defined_tags        = var.defined_tags
  freeform_tags       = local.common_freeform_tags

  dynamic "node_shape_config" {
    for_each = var.oke_node_shape_ocpus == null && var.oke_node_shape_memory_in_gbs == null ? [] : [1]

    content {
      ocpus         = var.oke_node_shape_ocpus
      memory_in_gbs = var.oke_node_shape_memory_in_gbs
    }
  }

  dynamic "node_source_details" {
    for_each = var.oke_node_image_id == null ? [] : [var.oke_node_image_id]

    content {
      image_id    = node_source_details.value
      source_type = "IMAGE"
    }
  }
}

resource "terraform_data" "interconnect_contract" {
  input = local.interconnect_contract
}

resource "terraform_data" "gitops_contract" {
  count = var.enable_gitops_contract ? 1 : 0

  input = {
    tool           = lower(var.gitops_tool)
    repository_url = var.gitops_repo_url
    branch         = var.gitops_branch
    primary_cluster = {
      cloud      = "oci"
      cluster_id = local.effective_oke_cluster_id
    }
    secondary_cluster = {
      cloud               = "azure"
      cluster_id          = var.aks_cluster_id
      resource_group_name = var.aks_resource_group_name
      cluster_name        = var.aks_cluster_name
    }
  }
}

resource "terraform_data" "traffic_steering_contract" {
  count = var.enable_traffic_steering_contract ? 1 : 0

  input = {
    application_fqdn = var.app_fqdn
    policy = {
      mode = "weighted-active-active"
      routes = {
        oci_primary = {
          endpoint = var.oci_primary_endpoint
          weight   = local.traffic_weights.oci_primary
        }
        azure_secondary = {
          endpoint = var.azure_secondary_endpoint
          weight   = local.traffic_weights.azure_secondary
        }
      }
    }
  }
}
