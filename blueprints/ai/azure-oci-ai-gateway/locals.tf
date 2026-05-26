# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "ai-azure-oci-gateway"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)

  gateway_vcn_name       = "${local.name_prefix}-vcn-ai-gw"
  gateway_igw_name       = "${local.name_prefix}-igw-ai-gw"
  gateway_rt_name        = "${local.name_prefix}-rt-ai-gw"
  gateway_sl_name        = "${local.name_prefix}-sl-ai-gw"
  gateway_subnet_name    = "${local.name_prefix}-sn-ai-gw"
  oci_gateway_name       = coalesce(var.oci_gateway_display_name, "${local.name_prefix}-apigw-ai")
  oci_deployment_name    = coalesce(var.oci_gateway_deployment_display_name, "${local.name_prefix}-apidep-ai")
  audit_bucket_name      = coalesce(var.oci_audit_bucket_name, "${local.name_prefix}-bkt-ai-audit")
  routing_log_group_name = coalesce(var.oci_routing_log_group_name, "${local.name_prefix}-lg-ai-routing")

  oci_gateway_subnet_id_effective = var.enable_oci_gateway_network ? try(oci_core_subnet.gateway[0].id, null) : var.oci_gateway_subnet_id
  oci_gateway_id_effective        = var.create_oci_api_gateway ? try(oci_apigateway_gateway.this[0].id, null) : var.oci_gateway_id
  oci_deployment_id_effective     = var.create_oci_gateway_deployment ? try(oci_apigateway_deployment.this[0].id, null) : var.oci_gateway_deployment_id

  provider_backend_urls = {
    oci   = split("?", coalesce(var.oci_generative_ai_inference_url, "https://example.oci.generative.ai/inference"))[0]
    azure = split("?", coalesce(var.azure_openai_inference_url, "https://example.openai.azure.com/openai/deployments/chat/completions?api-version=2024-10-21"))[0]
  }

  strategy_provider_map = {
    region         = var.routing_strategy_region_provider
    cost           = var.routing_strategy_cost_provider
    data_residency = var.routing_strategy_data_residency_provider
  }

  strategy_backend_urls = {
    for strategy_name, provider_name in local.strategy_provider_map :
    strategy_name => local.provider_backend_urls[provider_name]
  }

  gateway_routes = {
    provider_oci = {
      path    = "/providers/oci"
      methods = var.route_methods
      url     = local.provider_backend_urls.oci
    }
    provider_azure = {
      path    = "/providers/azure"
      methods = var.route_methods
      url     = local.provider_backend_urls.azure
    }
    strategy_region = {
      path    = "/route/region"
      methods = var.route_methods
      url     = local.strategy_backend_urls.region
    }
    strategy_cost = {
      path    = "/route/cost"
      methods = var.route_methods
      url     = local.strategy_backend_urls.cost
    }
    strategy_data_residency = {
      path    = "/route/data-residency"
      methods = var.route_methods
      url     = local.strategy_backend_urls.data_residency
    }
  }

  connectivity_contract = {
    mode                           = var.connectivity_mode
    fastconnect_virtual_circuit_id = var.fastconnect_virtual_circuit_id
    expressroute_circuit_id        = var.expressroute_circuit_id
    validation                     = var.connectivity_mode == "interconnect" ? "partner-path-required" : "interconnect-not-required"
  }

  routing_contract = {
    gateway_path_prefix = var.gateway_path_prefix
    provider_targets = {
      oci = {
        backend_url = var.oci_generative_ai_inference_url
        region      = var.oci_region_label
        residency   = var.oci_data_residency_regions
      }
      azure = {
        backend_url = var.azure_openai_inference_url
        region      = var.azure_region_label
        residency   = var.azure_data_residency_regions
      }
    }
    strategies = {
      region = {
        selected_provider = var.routing_strategy_region_provider
        backend_url       = local.strategy_backend_urls.region
      }
      cost = {
        selected_provider = var.routing_strategy_cost_provider
        backend_url       = local.strategy_backend_urls.cost
      }
      data_residency = {
        selected_provider = var.routing_strategy_data_residency_provider
        backend_url       = local.strategy_backend_urls.data_residency
      }
    }
  }

  azure_contract = {
    openai_account_id      = var.azure_openai_account_id
    openai_endpoint        = var.azure_openai_endpoint
    api_management_gateway = var.azure_api_management_gateway_url
    hello_world_endpoint   = var.azure_hello_world_endpoint
  }

  common_freeform_tags = merge(
    {
      Blueprint  = local.blueprint_name
      ManagedBy  = "terraform"
      MultiCloud = "azure-oci"
    },
    var.freeform_tags
  )
}
