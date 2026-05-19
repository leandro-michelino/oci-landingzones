# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Consolidated map of resource and contract identifiers produced by this blueprint; use it as the primary machine-readable hand-off for integration and runbook steps."
  value = {
    oci_network_contract      = terraform_data.oke_network_contract.id
    oci_vcn                   = try(oci_core_vcn.oke[0].id, null)
    oci_route_table           = try(oci_core_route_table.oke[0].id, null)
    oci_endpoint_securitylist = try(oci_core_security_list.oke_endpoint[0].id, null)
    oci_node_securitylist     = try(oci_core_security_list.oke_node[0].id, null)
    oci_endpoint_subnet       = local.effective_oke_endpoint_subnet_id
    oci_node_subnets          = local.effective_oke_node_subnet_ids
    oci_lb_subnets            = local.effective_oke_service_lb_subnet_ids
    oci_primary_cluster       = try(oci_containerengine_cluster.oci_primary[0].id, null)
    oci_primary_node_pool     = try(oci_containerengine_node_pool.oci_primary[0].id, null)
    interconnect_contract     = terraform_data.interconnect_contract.id
    gitops_contract           = try(terraform_data.gitops_contract[0].id, null)
    traffic_steering_contract = try(terraform_data.traffic_steering_contract[0].id, null)
  }
}

output "primary_cluster" {
  description = "Primary-cluster hand-off object for OCI OKE, including cluster and node pool identifiers used by platform operations and GitOps onboarding."
  value = {
    cloud      = "oci"
    cluster_id = local.effective_oke_cluster_id
    node_pool  = try(oci_containerengine_node_pool.oci_primary[0].id, null)
  }
}

output "secondary_cluster" {
  description = "Secondary-cluster hand-off object for AWS EKS, including cluster identity fields required for DR and active/active routing operations."
  value = {
    cloud        = "aws"
    cluster_id   = var.eks_cluster_id
    cluster_name = var.eks_cluster_name
    stack_name   = var.eks_stack_name
  }
}

output "interconnect_contract" {
  description = "Cross-cloud interconnect contract documenting OCI-to-AWS private-connectivity assumptions, partner identifiers, and operational boundaries."
  value       = local.interconnect_contract
}

output "traffic_steering_contract" {
  description = "Traffic steering contract with endpoint and weight metadata used by global traffic controls to keep OCI primary and AWS secondary."
  value = var.enable_traffic_steering_contract ? {
    app_fqdn               = var.app_fqdn
    oci_primary_endpoint   = var.oci_primary_endpoint
    aws_secondary_endpoint = var.aws_secondary_endpoint
    oci_primary_weight     = local.traffic_weights.oci_primary
    aws_secondary_weight   = local.traffic_weights.aws_secondary
  } : null
}

output "gitops_contract" {
  description = "GitOps hand-off metadata for multi-cluster delivery pipelines, including tool, repository, branch, and primary/secondary cluster references."
  value = var.enable_gitops_contract ? {
    tool      = lower(var.gitops_tool)
    repo_url  = var.gitops_repo_url
    branch    = var.gitops_branch
    primary   = local.effective_oke_cluster_id
    secondary = var.eks_cluster_id
  } : null
}
