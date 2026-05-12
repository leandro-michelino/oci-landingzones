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
  description = "Compartment OCID where API Gateway resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "enable_gateway" {
  description = "Create an API Gateway. Disabled by default to avoid accidental public ingress."
  type        = bool
  default     = false
}

variable "create_gateway" {
  description = "Create a gateway when enable_gateway is true. Disable when deploying to an existing gateway."
  type        = bool
  default     = true
}

variable "gateway_id" {
  description = "Existing API Gateway OCID used when create_gateway is false or for deployments on an existing gateway."
  type        = string
  default     = null
}

variable "gateway_label" {
  description = "Short API Gateway label used in names."
  type        = string
  default     = "platform"
}

variable "endpoint_type" {
  description = "API Gateway endpoint type, usually PUBLIC or PRIVATE."
  type        = string
  default     = "PUBLIC"
}

variable "subnet_id" {
  description = "Subnet OCID for the API Gateway."
  type        = string
  default     = null
}

variable "network_security_group_ids" {
  description = "Optional NSG OCIDs for the API Gateway."
  type        = set(string)
  default     = []
}

variable "certificate_id" {
  description = "Optional certificate OCID for the API Gateway."
  type        = string
  default     = null
}

variable "enable_deployment" {
  description = "Create an API Gateway deployment. Disabled by default until routes and backends are reviewed."
  type        = bool
  default     = false
}

variable "deployment_label" {
  description = "Short API deployment label used in names."
  type        = string
  default     = "api"
}

variable "path_prefix" {
  description = "API deployment path prefix."
  type        = string
  default     = "/"
}

variable "routes" {
  description = "API routes created when enable_deployment is true."
  type = list(object({
    path                       = string
    methods                    = optional(list(string))
    backend_type               = string
    backend_url                = optional(string)
    backend_status             = optional(number)
    is_ssl_verify_disabled     = optional(bool)
    connect_timeout_in_seconds = optional(number)
    read_timeout_in_seconds    = optional(number)
    send_timeout_in_seconds    = optional(number)
  }))
  default = []
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
