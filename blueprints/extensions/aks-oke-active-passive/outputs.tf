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
    traffic_health_check      = try(oci_health_checks_http_monitor.traffic_failover[0].id, null)
    traffic_steering_policy   = try(oci_dns_steering_policy.traffic_failover[0].id, null)
    traffic_policy_attachment = try(oci_dns_steering_policy_attachment.traffic_failover[0].id, null)
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
  description = "Secondary-cluster hand-off object for Azure AKS, including cluster identity fields required for standby and failover operations."
  value = {
    cloud               = "azure"
    cluster_id          = var.aks_cluster_id
    cluster_name        = var.aks_cluster_name
    resource_group_name = var.aks_resource_group_name
  }
}

output "interconnect_contract" {
  description = "Cross-cloud interconnect contract documenting OCI-to-Azure private-connectivity assumptions, partner identifiers, and operational boundaries."
  value       = local.interconnect_contract
}

output "traffic_steering_contract" {
  description = "Active/passive DNS failover contract used by OCI Traffic Management or external global traffic controls."
  value       = var.enable_traffic_steering_contract ? local.dns_failover_contract : null
}

output "dns_failover_contract" {
  description = "DNS failover metadata for OCI primary to Azure standby cutover, including OCI Traffic Management resource IDs when enabled."
  value       = var.enable_traffic_steering_contract ? local.dns_failover_contract : null
}

output "gitops_contract" {
  description = "GitOps hand-off metadata for multi-cluster delivery pipelines, including tool, repository, branch, and primary/standby cluster references."
  value = var.enable_gitops_contract ? {
    tool      = lower(var.gitops_tool)
    repo_url  = var.gitops_repo_url
    branch    = var.gitops_branch
    primary   = local.effective_oke_cluster_id
    secondary = var.aks_cluster_id
  } : null
}

output "operator_summary" {
  description = "Friendly operator summary with the resource names, IDs, URLs, and next-step hints most useful after plan or apply."
  value = {
    blueprint         = local.blueprint_name
    deployment_prefix = local.name_prefix
    mode              = "active-passive-failover"
    kubernetes = {
      guidance    = "Use the latest common Kubernetes minor version supported by OKE and AKS in the selected regions."
      oke_version = var.oke_kubernetes_version
      aks_version = "Set by the Azure Bicep kubernetesVersion parameter; keep it aligned with OKE."
    }
    resource_names = {
      oke_vcn             = local.oke_vcn_name
      oke_route_table     = local.oke_route_table_name
      oke_endpoint_subnet = local.oke_endpoint_subnet_name
      oke_node_subnets    = [for index, _ in local.effective_oke_node_subnet_ids : "${local.oke_node_subnet_base_name}-${index + 1}"]
      oke_lb_subnet       = local.oke_service_lb_subnet_name
      oke_cluster         = local.oke_cluster_name
      oke_node_pool       = local.oke_node_pool_name
      aks_resource_group  = var.aks_resource_group_name
      aks_cluster         = var.aks_cluster_name
    }
    resource_ids = {
      oke_vcn             = try(oci_core_vcn.oke[0].id, null)
      oke_route_table     = try(oci_core_route_table.oke[0].id, null)
      oke_endpoint_subnet = local.effective_oke_endpoint_subnet_id
      oke_node_subnets    = local.effective_oke_node_subnet_ids
      oke_lb_subnets      = local.effective_oke_service_lb_subnet_ids
      oke_cluster         = local.effective_oke_cluster_id
      oke_node_pool       = try(oci_containerengine_node_pool.oci_primary[0].id, null)
      aks_cluster         = var.aks_cluster_id
    }
    application_endpoints = {
      fqdn            = local.traffic_management_domain_name
      oci_primary     = var.oci_primary_endpoint
      azure_standby   = var.azure_secondary_endpoint
      oke_api_public  = try(oci_containerengine_cluster.oci_primary[0].endpoints[0].public_endpoint, null)
      oke_api_private = try(oci_containerengine_cluster.oci_primary[0].endpoints[0].private_endpoint, null)
    }
    traffic_management = {
      enabled            = var.enable_oci_traffic_management
      provider           = "oci-traffic-management"
      domain_name        = local.traffic_management_domain_name
      record_type        = upper(var.oci_traffic_management_record_type)
      ttl                = var.oci_traffic_management_ttl
      primary_answer     = local.traffic_management_primary_answer
      standby_answer     = local.traffic_management_standby_answer
      policy             = try(oci_dns_steering_policy.traffic_failover[0].id, null)
      policy_attachment  = try(oci_dns_steering_policy_attachment.traffic_failover[0].id, null)
      health_check       = local.traffic_management_health_check_id
      health_check_path  = var.oci_traffic_management_health_check_path
      failover_order     = "OCI primary, Azure standby"
      active_active_note = "Supported when the app and data layer are ready; use weighted OCI Traffic Management or another GSLB layer."
    }
    useful_commands = {
      oke_kubeconfig = local.effective_oke_cluster_id == null ? null : "oci ce cluster create-kubeconfig --cluster-id ${local.effective_oke_cluster_id} --file ./oke.kubeconfig --region ${var.region} --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"
      aks_kubeconfig = var.aks_cluster_name == null || var.aks_resource_group_name == null ? null : "az aks get-credentials --resource-group ${var.aks_resource_group_name} --name ${var.aks_cluster_name}"
      check_oke      = "KUBECONFIG=./oke.kubeconfig kubectl get nodes -o wide"
      check_dns      = local.traffic_management_domain_name == null ? null : "dig ${upper(var.oci_traffic_management_record_type)} ${local.traffic_management_domain_name}"
      check_primary  = local.traffic_management_primary_answer == null ? null : "curl -fsS http://${local.traffic_management_primary_answer}/"
      check_standby  = local.traffic_management_standby_answer == null ? null : "curl -fsS http://${local.traffic_management_standby_answer}/"
    }
  }
}
