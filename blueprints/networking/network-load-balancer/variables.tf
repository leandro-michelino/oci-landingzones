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
  description = "Compartment OCID where resources are created. Defaults to tenancy_ocid for validation-only tests."
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

variable "create_network_load_balancer" {
  description = "Create the Network Load Balancer."
  type        = bool
  default     = false
}
variable "network_load_balancer_id" {
  description = "Existing Network Load Balancer OCID when create_network_load_balancer is false."
  type        = string
  default     = null
}
variable "network_load_balancer_display_name" {
  description = "Optional Network Load Balancer display name override."
  type        = string
  default     = null
}
variable "subnet_id" {
  description = "Subnet OCID for Network Load Balancer placement."
  type        = string
  default     = null
}
variable "is_private" {
  description = "Create a private Network Load Balancer."
  type        = bool
  default     = true
}
variable "is_preserve_source_destination" {
  description = "Preserve source and destination addresses."
  type        = bool
  default     = false
}
variable "is_symmetric_hash_enabled" {
  description = "Enable symmetric hashing."
  type        = bool
  default     = false
}
variable "network_security_group_ids" {
  description = "NSG OCIDs attached to the Network Load Balancer."
  type        = set(string)
  default     = []
}
variable "assigned_private_ipv4" {
  description = "Optional assigned private IPv4 address."
  type        = string
  default     = null
}
variable "assigned_ipv6" {
  description = "Optional assigned IPv6 address."
  type        = string
  default     = null
}
variable "nlb_ip_version" {
  description = "Network Load Balancer IP version."
  type        = string
  default     = "IPV4"
}

variable "backend_sets" {
  description = "Backend sets keyed by logical name."
  type = map(object({
    name               = optional(string)
    policy             = optional(string, "FIVE_TUPLE")
    is_preserve_source = optional(bool)
    is_fail_open       = optional(bool)
    ip_version         = optional(string)
    health_checker = object({
      protocol            = string
      port                = optional(number)
      url_path            = optional(string)
      return_code         = optional(number)
      retries             = optional(number)
      interval_in_millis  = optional(number)
      timeout_in_millis   = optional(number)
      request_data        = optional(string)
      response_data       = optional(string)
      response_body_regex = optional(string)
    })
    backends = optional(map(object({
      name       = optional(string)
      ip_address = optional(string)
      target_id  = optional(string)
      port       = number
      weight     = optional(number)
      is_backup  = optional(bool)
      is_drain   = optional(bool)
      is_offline = optional(bool)
    })), {})
  }))
  default = {}
}
variable "listeners" {
  description = "Listeners keyed by logical name."
  type = map(object({
    name                     = optional(string)
    backend_set_key          = optional(string)
    default_backend_set_name = optional(string)
    port                     = number
    protocol                 = string
    ip_version               = optional(string)
    is_ppv2enabled           = optional(bool)
    tcp_idle_timeout         = optional(number)
    udp_idle_timeout         = optional(number)
    l3ip_idle_timeout        = optional(number)
  }))
  default = {}
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the optional IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "Optional IAM policy statements for NLB operators and network reviewers."
  type        = list(string)
  default     = []
}
