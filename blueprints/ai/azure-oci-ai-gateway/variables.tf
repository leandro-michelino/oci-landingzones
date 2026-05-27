variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "current_user_ocid" {
  description = "OCI user OCID used for local execution or bootstrap."
  type        = string
}

variable "region" {
  description = "OCI region name."
  type        = string
}

variable "home_region" {
  description = "OCI tenancy home region."
  type        = string
  default     = null
}

variable "oci_config_profile" {
  description = "Optional OCI CLI config profile for local execution."
  type        = string
  default     = null
}

variable "org" {
  description = "Short organization prefix used in names."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "region_key" {
  description = "Short OCI region key used in resource names."
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment OCID where OCI AI gateway resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "enable_oci_gateway_network" {
  description = "Create deploy-and-use OCI networking for the AI gateway (VCN, internet gateway, route table, security list, and subnet)."
  type        = bool
  default     = true
}

variable "oci_gateway_vcn_cidr" {
  description = "CIDR block for OCI AI gateway VCN when enable_oci_gateway_network is true."
  type        = string
  default     = "10.82.0.0/16"
}

variable "oci_gateway_subnet_cidr" {
  description = "CIDR block for OCI AI gateway subnet when enable_oci_gateway_network is true."
  type        = string
  default     = "10.82.10.0/24"
}

variable "oci_gateway_ingress_allowed_cidr" {
  description = "Source CIDR allowed for AI gateway ingress on ports 80 and 443."
  type        = string
  default     = "0.0.0.0/0"
}

variable "connectivity_mode" {
  description = "Cross-cloud connectivity mode between OCI and Azure for private traffic lanes and governance context."
  type        = string
  default     = "interconnect"

  validation {
    condition     = contains(["interconnect", "without-interconnect"], var.connectivity_mode)
    error_message = "connectivity_mode must be interconnect or without-interconnect."
  }
}

variable "fastconnect_virtual_circuit_id" {
  description = "OCI FastConnect virtual circuit OCID used when connectivity_mode is interconnect."
  type        = string
  default     = null
}

variable "expressroute_circuit_id" {
  description = "Azure ExpressRoute circuit resource ID used when connectivity_mode is interconnect."
  type        = string
  default     = null
}

variable "create_oci_api_gateway" {
  description = "Create OCI API Gateway as the routing front door."
  type        = bool
  default     = true
}

variable "oci_gateway_id" {
  description = "Existing OCI API Gateway OCID when create_oci_api_gateway is false."
  type        = string
  default     = null
}

variable "oci_gateway_display_name" {
  description = "Optional OCI API Gateway display name override."
  type        = string
  default     = null
}

variable "oci_gateway_endpoint_type" {
  description = "OCI API Gateway endpoint type, PRIVATE or PUBLIC."
  type        = string
  default     = "PUBLIC"
}

variable "oci_gateway_subnet_id" {
  description = "Existing subnet OCID for OCI API Gateway when create_oci_api_gateway is true and enable_oci_gateway_network is false."
  type        = string
  default     = null
}

variable "oci_gateway_network_security_group_ids" {
  description = "NSG OCIDs attached to OCI API Gateway."
  type        = set(string)
  default     = []
}

variable "oci_gateway_certificate_id" {
  description = "Optional certificate OCID for OCI API Gateway."
  type        = string
  default     = null
}

variable "create_oci_gateway_deployment" {
  description = "Create OCI API Gateway deployment and routes for AI provider and policy routing."
  type        = bool
  default     = true
}

variable "oci_gateway_deployment_id" {
  description = "Existing OCI API Gateway deployment OCID when create_oci_gateway_deployment is false."
  type        = string
  default     = null
}

variable "oci_gateway_deployment_display_name" {
  description = "Optional OCI API Gateway deployment display name override."
  type        = string
  default     = null
}

variable "gateway_path_prefix" {
  description = "Path prefix for OCI API Gateway deployment routes."
  type        = string
  default     = "/ai"
}

variable "route_methods" {
  description = "HTTP methods allowed on generated AI gateway routes."
  type        = list(string)
  default     = ["POST"]
}

variable "oci_generative_ai_inference_url" {
  description = "OCI Generative AI inference endpoint URL used by OCI API Gateway backend routes."
  type        = string
  default     = null
}

variable "azure_openai_inference_url" {
  description = "Azure OpenAI inference endpoint URL used by OCI API Gateway backend routes."
  type        = string
  default     = null
}

variable "routing_strategy_region_provider" {
  description = "Provider selected for region-based route strategy."
  type        = string
  default     = "oci"

  validation {
    condition     = contains(["oci", "azure"], var.routing_strategy_region_provider)
    error_message = "routing_strategy_region_provider must be oci or azure."
  }
}

variable "routing_strategy_cost_provider" {
  description = "Provider selected for cost-based route strategy."
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["oci", "azure"], var.routing_strategy_cost_provider)
    error_message = "routing_strategy_cost_provider must be oci or azure."
  }
}

variable "routing_strategy_data_residency_provider" {
  description = "Provider selected for data-residency route strategy."
  type        = string
  default     = "oci"

  validation {
    condition     = contains(["oci", "azure"], var.routing_strategy_data_residency_provider)
    error_message = "routing_strategy_data_residency_provider must be oci or azure."
  }
}

variable "oci_region_label" {
  description = "Human-readable OCI region label used in routing contracts."
  type        = string
  default     = "oci-region"
}

variable "azure_region_label" {
  description = "Human-readable Azure region label used in routing contracts."
  type        = string
  default     = "azure-region"
}

variable "oci_data_residency_regions" {
  description = "Jurisdictions and region labels associated with OCI residency policy."
  type        = list(string)
  default     = ["eu-madrid-1", "uk-london-1"]
}

variable "azure_data_residency_regions" {
  description = "Jurisdictions and region labels associated with Azure residency policy."
  type        = list(string)
  default     = ["westeurope", "uksouth"]
}

variable "require_provider_endpoints" {
  description = "Require real OCI and Azure endpoint URLs in Terraform inputs when creating route contracts."
  type        = bool
  default     = true
}

variable "create_oci_usage_plans" {
  description = "Create OCI API Gateway usage plans for team quotas."
  type        = bool
  default     = false
}

variable "usage_plans" {
  description = "OCI API Gateway usage plans keyed by team or application."
  type = map(object({
    display_name         = optional(string)
    entitlement_name     = string
    description          = optional(string)
    quota_value          = optional(number)
    quota_unit           = optional(string)
    quota_reset_policy   = optional(string)
    quota_breach_action  = optional(string)
    rate_limit_value     = optional(number)
    rate_limit_unit      = optional(string)
    target_deployment_id = optional(string)
  }))
  default = {}
}

variable "create_oci_audit_bucket" {
  description = "Create private OCI Object Storage bucket for AI gateway audit artifacts and routing evidence."
  type        = bool
  default     = true
}

variable "oci_audit_bucket_name" {
  description = "Optional OCI audit bucket name override."
  type        = string
  default     = null
}

variable "oci_audit_bucket_storage_tier" {
  description = "OCI audit bucket storage tier."
  type        = string
  default     = "Standard"
}

variable "oci_audit_bucket_versioning" {
  description = "OCI audit bucket versioning setting."
  type        = string
  default     = "Enabled"
}

variable "oci_kms_key_id" {
  description = "Optional OCI KMS key OCID for audit bucket encryption."
  type        = string
  default     = null
}

variable "create_oci_routing_log_group" {
  description = "Create OCI Logging log group for AI routing events."
  type        = bool
  default     = true
}

variable "oci_routing_log_group_name" {
  description = "Optional OCI routing log group name override."
  type        = string
  default     = null
}

variable "policy_compartment_ocid" {
  description = "Compartment OCID where OCI IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "policy_statements" {
  description = "OCI IAM policy statements for gateway operators, callers, and audit readers."
  type        = list(string)
  default     = []
}

variable "azure_openai_account_id" {
  description = "Azure OpenAI account resource ID from the Azure deployment session."
  type        = string
  default     = null
}

variable "azure_openai_endpoint" {
  description = "Azure OpenAI endpoint from the Azure deployment session."
  type        = string
  default     = null
}

variable "azure_api_management_gateway_url" {
  description = "Azure API Management public gateway URL from the Azure deployment session."
  type        = string
  default     = null
}

variable "azure_hello_world_endpoint" {
  description = "Azure hello-world endpoint URL from the Azure deployment session."
  type        = string
  default     = null
}

variable "defined_tags" {
  description = "Defined tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags applied to resources."
  type        = map(string)
  default     = {}
}
