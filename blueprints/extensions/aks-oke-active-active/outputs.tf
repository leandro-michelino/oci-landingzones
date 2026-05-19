# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this blueprint."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint."
  value = {
    oci_primary_cluster       = try(oci_containerengine_cluster.oci_primary[0].id, null)
    oci_primary_node_pool     = try(oci_containerengine_node_pool.oci_primary[0].id, null)
    interconnect_contract     = terraform_data.interconnect_contract.id
    gitops_contract           = try(terraform_data.gitops_contract[0].id, null)
    traffic_steering_contract = try(terraform_data.traffic_steering_contract[0].id, null)
  }
}

output "primary_cluster" {
  description = "OCI primary cluster hand-off details."
  value = {
    cloud      = "oci"
    cluster_id = local.effective_oke_cluster_id
    node_pool  = try(oci_containerengine_node_pool.oci_primary[0].id, null)
  }
}

output "secondary_cluster" {
  description = "Azure AKS secondary cluster hand-off details."
  value = {
    cloud               = "azure"
    cluster_id          = var.aks_cluster_id
    cluster_name        = var.aks_cluster_name
    resource_group_name = var.aks_resource_group_name
  }
}

output "interconnect_contract" {
  description = "OCI and Azure interconnect contract details for ExpressRoute + FastConnect partner connectivity."
  value       = local.interconnect_contract
}

output "traffic_steering_contract" {
  description = "Weighted traffic steering contract with OCI primary and Azure secondary weights."
  value = var.enable_traffic_steering_contract ? {
    app_fqdn                 = var.app_fqdn
    oci_primary_endpoint     = var.oci_primary_endpoint
    azure_secondary_endpoint = var.azure_secondary_endpoint
    oci_primary_weight       = local.traffic_weights.oci_primary
    azure_secondary_weight   = local.traffic_weights.azure_secondary
  } : null
}

output "gitops_contract" {
  description = "GitOps contract metadata for multi-cluster deployment orchestration."
  value = var.enable_gitops_contract ? {
    tool      = lower(var.gitops_tool)
    repo_url  = var.gitops_repo_url
    branch    = var.gitops_branch
    primary   = local.effective_oke_cluster_id
    secondary = var.aks_cluster_id
  } : null
}
