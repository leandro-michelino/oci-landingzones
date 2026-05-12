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
  description = "Compartment OCID where WAF resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "enable_waf_policy" {
  description = "Create an OCI WAF policy. Disabled by default until public exposure is reviewed."
  type        = bool
  default     = false
}

variable "waf_policy_id" {
  description = "Existing WAF policy OCID used when attaching a firewall to an existing policy."
  type        = string
  default     = null
}

variable "waf_label" {
  description = "Short WAF label used in names."
  type        = string
  default     = "web"
}

variable "enable_web_app_firewall" {
  description = "Create a Web App Firewall attachment for a load balancer."
  type        = bool
  default     = false
}

variable "load_balancer_id" {
  description = "Load balancer OCID protected by the Web App Firewall."
  type        = string
  default     = null
}

variable "backend_type" {
  description = "Web App Firewall backend type."
  type        = string
  default     = "LOAD_BALANCER"
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
