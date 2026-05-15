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
  description = "Compartment OCID where Functions resources are created. Defaults to tenancy_ocid for validation-only tests."
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

variable "enable_container_repository" {
  description = "Create an Artifact Registry container repository for function images."
  type        = bool
  default     = false
}

variable "repository_name" {
  description = "Container repository leaf name appended after the default OCI naming prefix."
  type        = string
  default     = "hello-python"
}

variable "repository_display_name" {
  description = "Optional Artifact Registry container repository display name."
  type        = string
  default     = null
}

variable "repository_url" {
  description = "Existing repository URL used when enable_container_repository is false."
  type        = string
  default     = null
}

variable "repository_is_immutable" {
  description = "Make container image tags immutable."
  type        = bool
  default     = false
}

variable "repository_is_public" {
  description = "Expose the container repository publicly."
  type        = bool
  default     = false
}

variable "repository_readme" {
  description = "Optional repository README."
  type = object({
    content = string
    format  = string
  })
  default = null
}

variable "enable_application" {
  description = "Create or reference an OCI Functions application."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_application || var.create_application || var.application_id != null
    error_message = "When enable_application is true, set create_application to true or provide application_id."
  }

  validation {
    condition     = !var.enable_application || !var.create_application || length(var.application_subnet_ids) > 0
    error_message = "application_subnet_ids must be supplied when creating a Functions application."
  }
}

variable "create_application" {
  description = "Create the Functions application. Disable when deploying functions into an existing application."
  type        = bool
  default     = true
}

variable "application_id" {
  description = "Existing Functions application OCID used when create_application is false."
  type        = string
  default     = null
}

variable "application_display_name" {
  description = "Optional Functions application display name."
  type        = string
  default     = null
}

variable "application_subnet_ids" {
  description = "Subnet OCIDs used by the Functions application."
  type        = list(string)
  default     = []
}

variable "application_network_security_group_ids" {
  description = "NSG OCIDs attached to the Functions application."
  type        = set(string)
  default     = []
}

variable "application_shape" {
  description = "Functions application shape, when required by the target region and service."
  type        = string
  default     = null
}

variable "application_config" {
  description = "Application-level function configuration."
  type        = map(string)
  default     = {}
}

variable "syslog_url" {
  description = "Optional syslog endpoint URL for function logs."
  type        = string
  default     = null
}

variable "image_policy_enabled" {
  description = "Enable signed image policy for the Functions application."
  type        = bool
  default     = false
}

variable "image_policy_kms_key_ids" {
  description = "KMS key OCIDs trusted for signed function images."
  type        = set(string)
  default     = []
}

variable "application_log_line_format" {
  description = "Optional application log line format."
  type        = string
  default     = null
}

variable "application_trace_enabled" {
  description = "Enable APM tracing for the Functions application."
  type        = bool
  default     = false
}

variable "application_trace_domain_id" {
  description = "APM domain OCID for Functions application tracing."
  type        = string
  default     = null
}

variable "enable_functions" {
  description = "Create OCI Functions in the application."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_functions || var.enable_application || var.application_id != null
    error_message = "Functions require enable_application or an existing application_id."
  }
}

variable "functions" {
  description = "Functions keyed by logical name."
  type = map(object({
    display_name                     = optional(string)
    image                            = optional(string)
    image_digest                     = optional(string)
    memory_in_mbs                    = optional(number, 256)
    timeout_in_seconds               = optional(number, 30)
    detached_mode_timeout_in_seconds = optional(number)
    config                           = optional(map(string), {})
    trace_enabled                    = optional(bool)
    provisioned_concurrency = optional(object({
      strategy = string
      count    = optional(number)
    }))
    success_destination = optional(object({
      kind       = string
      channel_id = optional(string)
      queue_id   = optional(string)
      stream_id  = optional(string)
      topic_id   = optional(string)
    }))
    failure_destination = optional(object({
      kind       = string
      channel_id = optional(string)
      queue_id   = optional(string)
      stream_id  = optional(string)
      topic_id   = optional(string)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for function in values(var.functions) : function.image != null
    ])
    error_message = "Each function must set image to an OCIR-compatible function image URL."
  }
}

variable "enable_api_gateway" {
  description = "Create or reference an API Gateway for function routes."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_api_gateway || var.create_gateway || var.gateway_id != null
    error_message = "When enable_api_gateway is true, set create_gateway to true or provide gateway_id."
  }

  validation {
    condition     = !var.enable_api_gateway || !var.create_gateway || var.gateway_subnet_id != null
    error_message = "gateway_subnet_id must be supplied when creating an API Gateway."
  }
}

variable "create_gateway" {
  description = "Create an API Gateway. Disable when using an existing gateway."
  type        = bool
  default     = true
}

variable "gateway_id" {
  description = "Existing API Gateway OCID."
  type        = string
  default     = null
}

variable "gateway_display_name" {
  description = "Optional API Gateway display name."
  type        = string
  default     = null
}

variable "gateway_endpoint_type" {
  description = "API Gateway endpoint type, usually PRIVATE or PUBLIC."
  type        = string
  default     = "PRIVATE"

  validation {
    condition     = contains(["PRIVATE", "PUBLIC"], var.gateway_endpoint_type)
    error_message = "gateway_endpoint_type must be PRIVATE or PUBLIC."
  }
}

variable "gateway_subnet_id" {
  description = "Subnet OCID for API Gateway."
  type        = string
  default     = null
}

variable "gateway_network_security_group_ids" {
  description = "NSG OCIDs for API Gateway."
  type        = set(string)
  default     = []
}

variable "gateway_certificate_id" {
  description = "Optional API Gateway certificate OCID."
  type        = string
  default     = null
}

variable "enable_api_gateway_deployment" {
  description = "Create an API Gateway deployment that routes to functions."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_api_gateway_deployment || var.enable_api_gateway || var.gateway_id != null
    error_message = "API Gateway deployment requires enable_api_gateway or an existing gateway_id."
  }

  validation {
    condition     = !var.enable_api_gateway_deployment || length(var.api_routes) > 0 || var.default_api_function_key != null
    error_message = "API Gateway deployment requires api_routes or default_api_function_key."
  }
}

variable "deployment_display_name" {
  description = "Optional API deployment display name."
  type        = string
  default     = null
}

variable "gateway_path_prefix" {
  description = "API Gateway deployment path prefix."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.gateway_path_prefix, "/")
    error_message = "gateway_path_prefix must start with /."
  }
}

variable "default_api_function_key" {
  description = "Function key used to create a default API route."
  type        = string
  default     = null

  validation {
    condition     = var.default_api_function_key == null || var.enable_functions && contains(keys(var.functions), var.default_api_function_key)
    error_message = "default_api_function_key must match a key in functions when the default API route is enabled."
  }
}

variable "default_api_route_path" {
  description = "Default API route path."
  type        = string
  default     = "/hello"

  validation {
    condition     = startswith(var.default_api_route_path, "/")
    error_message = "default_api_route_path must start with /."
  }
}

variable "default_api_route_methods" {
  description = "Default API route methods."
  type        = list(string)
  default     = ["GET", "POST"]
}

variable "api_routes" {
  description = "API Gateway routes keyed by logical name."
  type = map(object({
    path                       = string
    methods                    = optional(list(string))
    function_key               = optional(string)
    function_id                = optional(string)
    connect_timeout_in_seconds = optional(number)
    read_timeout_in_seconds    = optional(number)
    send_timeout_in_seconds    = optional(number)
  }))
  default = {}

  validation {
    condition = alltrue([
      for route in values(var.api_routes) : (route.function_key != null) != (route.function_id != null)
    ])
    error_message = "Each api_routes entry must set exactly one of function_key or function_id."
  }

  validation {
    condition = alltrue([
      for route in values(var.api_routes) : route.function_key == null || var.enable_functions && contains(keys(var.functions), route.function_key)
    ])
    error_message = "api_routes entries that use function_key must reference a key in functions with enable_functions set to true."
  }

  validation {
    condition = alltrue([
      for route in values(var.api_routes) : startswith(route.path, "/")
    ])
    error_message = "Each api_routes entry path must start with /."
  }
}

variable "enable_event_rules" {
  description = "Create OCI Events rules that invoke functions."
  type        = bool
  default     = false
}

variable "event_rules" {
  description = "OCI Events rules keyed by logical name."
  type = map(object({
    display_name     = optional(string)
    description      = optional(string)
    compartment_ocid = optional(string)
    condition        = string
    is_enabled       = optional(bool, true)
    actions = list(object({
      function_key = optional(string)
      function_id  = optional(string)
      description  = optional(string)
      is_enabled   = optional(bool, true)
    }))
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for rule in values(var.event_rules) : [
        for action in rule.actions : (action.function_key != null) != (action.function_id != null)
      ]
    ]))
    error_message = "Each event rule action must set exactly one of function_key or function_id."
  }

  validation {
    condition = alltrue(flatten([
      for rule in values(var.event_rules) : [
        for action in rule.actions : action.function_key == null || var.enable_functions && contains(keys(var.functions), action.function_key)
      ]
    ]))
    error_message = "Event rule actions that use function_key must reference a key in functions with enable_functions set to true."
  }
}

variable "policy_compartment_ocid" {
  description = "Compartment OCID where optional IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "policy_statements" {
  description = "Optional IAM policy statements for Functions, repository, gateway, and Events access."
  type        = list(string)
  default     = []
}
