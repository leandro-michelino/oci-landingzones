# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
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
  description = "Compartment OCID where gateway resources are created. Defaults to tenancy_ocid for validation-only tests."
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
variable "create_gateway" {
  description = "Create an API Gateway for GenAI routing."
  type        = bool
  default     = false
}
variable "gateway_id" {
  description = "Existing API Gateway OCID when create_gateway is false."
  type        = string
  default     = null
}
variable "gateway_display_name" {
  description = "Optional API Gateway display name override."
  type        = string
  default     = null
}
variable "gateway_endpoint_type" {
  description = "API Gateway endpoint type, PRIVATE or PUBLIC."
  type        = string
  default     = "PRIVATE"
}
variable "gateway_subnet_id" {
  description = "Subnet OCID for API Gateway placement when create_gateway is true."
  type        = string
  default     = null
}
variable "gateway_network_security_group_ids" {
  description = "NSG OCIDs attached to the API Gateway."
  type        = set(string)
  default     = []
}
variable "gateway_certificate_id" {
  description = "Optional certificate OCID for the API Gateway."
  type        = string
  default     = null
}
variable "create_deployment" {
  description = "Create an API Gateway deployment with GenAI model routes."
  type        = bool
  default     = false
}
variable "deployment_id" {
  description = "Existing API Gateway deployment OCID used by usage plans when create_deployment is false."
  type        = string
  default     = null
}
variable "deployment_display_name" {
  description = "Optional API Gateway deployment display name override."
  type        = string
  default     = null
}
variable "gateway_path_prefix" {
  description = "Path prefix for GenAI gateway routes."
  type        = string
  default     = "/genai"
}
variable "routes" {
  description = "HTTP routes keyed by logical name. Each route points to a model, endpoint, or routing function URL."
  type = map(object({
    path                       = string
    methods                    = list(string)
    url                        = string
    connect_timeout_in_seconds = optional(number)
    read_timeout_in_seconds    = optional(number)
    send_timeout_in_seconds    = optional(number)
    is_ssl_verify_disabled     = optional(bool)
  }))
  default = {}
}
variable "create_usage_plans" {
  description = "Create API Gateway usage plans for team quotas."
  type        = bool
  default     = false
}
variable "usage_plans" {
  description = "Usage plans keyed by team or app name."
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
variable "create_audit_bucket" {
  description = "Create a private Object Storage bucket for prompt and response audit logs."
  type        = bool
  default     = false
}
variable "audit_bucket_name" {
  description = "Optional audit bucket name override."
  type        = string
  default     = null
}
variable "audit_bucket_storage_tier" {
  description = "Audit bucket storage tier."
  type        = string
  default     = "Standard"
}
variable "audit_bucket_versioning" {
  description = "Audit bucket versioning setting."
  type        = string
  default     = "Enabled"
}
variable "kms_key_id" {
  description = "Optional KMS key OCID for bucket encryption."
  type        = string
  default     = null
}
variable "create_log_group" {
  description = "Create a Logging log group for gateway audit and routing logs."
  type        = bool
  default     = false
}
variable "log_group_name" {
  description = "Optional log group display name override."
  type        = string
  default     = null
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "IAM policy statements for GenAI gateway operators, callers, and audit readers."
  type        = list(string)
  default     = []
}
