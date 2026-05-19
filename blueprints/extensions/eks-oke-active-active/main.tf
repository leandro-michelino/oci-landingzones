# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_core_vcn" "oke" {
  count = var.enable_oke_networking ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cidr_block     = var.oke_vcn_cidr
  display_name   = local.oke_vcn_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_internet_gateway" "oke" {
  count = var.enable_oke_networking ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.oke[0].id
  display_name   = local.oke_igw_name
  enabled        = true
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_route_table" "oke" {
  count = var.enable_oke_networking ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.oke[0].id
  display_name   = local.oke_route_table_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke[0].id
  }
}

resource "oci_core_security_list" "oke_endpoint" {
  count = var.enable_oke_networking ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.oke[0].id
  display_name   = local.oke_endpoint_sl_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.oke_api_allowed_cidr
    tcp_options {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_security_list" "oke_node" {
  count = var.enable_oke_networking ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.oke[0].id
  display_name   = local.oke_node_sl_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.oke_vcn_cidr
  }

  dynamic "ingress_security_rules" {
    for_each = var.oke_node_ssh_allowed_cidr == null ? [] : [var.oke_node_ssh_allowed_cidr]
    content {
      protocol = "6"
      source   = ingress_security_rules.value
      tcp_options {
        min = 22
        max = 22
      }
    }
  }
}

resource "oci_core_subnet" "oke_endpoint" {
  count = var.enable_oke_networking ? 1 : 0

  cidr_block        = var.oke_endpoint_subnet_cidr
  compartment_id    = local.target_compartment_ocid
  vcn_id            = oci_core_vcn.oke[0].id
  display_name      = local.oke_endpoint_subnet_name
  route_table_id    = oci_core_route_table.oke[0].id
  security_list_ids = [oci_core_security_list.oke_endpoint[0].id]

  prohibit_public_ip_on_vnic = !var.oke_endpoint_public_ip_enabled
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "oci_core_subnet" "oke_service_lb" {
  count = var.enable_oke_networking ? 1 : 0

  cidr_block        = var.oke_service_lb_subnet_cidr
  compartment_id    = local.target_compartment_ocid
  vcn_id            = oci_core_vcn.oke[0].id
  display_name      = local.oke_service_lb_subnet_name
  route_table_id    = oci_core_route_table.oke[0].id
  security_list_ids = [oci_core_security_list.oke_node[0].id]

  prohibit_public_ip_on_vnic = false
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "oci_core_subnet" "oke_nodes" {
  count = var.enable_oke_networking ? length(var.oke_node_subnet_cidrs) : 0

  cidr_block        = var.oke_node_subnet_cidrs[count.index]
  compartment_id    = local.target_compartment_ocid
  vcn_id            = oci_core_vcn.oke[0].id
  display_name      = "${local.oke_node_subnet_base_name}-${count.index + 1}"
  route_table_id    = oci_core_route_table.oke[0].id
  security_list_ids = [oci_core_security_list.oke_node[0].id]

  prohibit_public_ip_on_vnic = true
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "terraform_data" "oke_network_contract" {
  input = {
    enable_oke_networking = var.enable_oke_networking
    effective_vcn_id      = local.effective_oke_vcn_id
    effective_endpoint_id = local.effective_oke_endpoint_subnet_id
    node_subnet_count     = length(local.effective_oke_node_subnet_ids)
  }

  lifecycle {
    precondition {
      condition = (
        var.enable_oke_networking ||
        !(var.enable_oke_cluster || var.enable_oke_node_pool) ||
        (var.oke_vcn_id != null &&
          var.oke_endpoint_subnet_id != null &&
        length(var.oke_node_subnet_ids) > 0)
      )
      error_message = "When enable_oke_networking=false, set oke_vcn_id, oke_endpoint_subnet_id, and at least one oke_node_subnet_ids value."
    }
  }
}

resource "oci_containerengine_cluster" "oci_primary" {
  count = var.enable_oke_cluster ? 1 : 0

  compartment_id     = local.target_compartment_ocid
  kubernetes_version = var.oke_kubernetes_version
  name               = local.oke_cluster_name
  vcn_id             = local.effective_oke_vcn_id
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags

  dynamic "cluster_pod_network_options" {
    for_each = var.oke_cni_type == null ? [] : [var.oke_cni_type]

    content {
      cni_type = cluster_pod_network_options.value
    }
  }

  dynamic "endpoint_config" {
    for_each = local.effective_oke_endpoint_subnet_id == null ? [] : [local.effective_oke_endpoint_subnet_id]

    content {
      is_public_ip_enabled = var.oke_endpoint_public_ip_enabled
      nsg_ids              = var.oke_endpoint_nsg_ids
      subnet_id            = endpoint_config.value
    }
  }

  dynamic "options" {
    for_each = length(local.effective_oke_service_lb_subnet_ids) == 0 ? [] : [local.effective_oke_service_lb_subnet_ids]

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
  subnet_ids          = local.effective_oke_node_subnet_ids
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
      cloud        = "aws"
      cluster_id   = var.eks_cluster_id
      stack_name   = var.eks_stack_name
      cluster_name = var.eks_cluster_name
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
        aws_secondary = {
          endpoint = var.aws_secondary_endpoint
          weight   = local.traffic_weights.aws_secondary
        }
      }
    }
  }
}
