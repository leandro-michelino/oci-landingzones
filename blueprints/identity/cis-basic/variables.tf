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
  description = "Compartment OCID where identity policies are created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "enable_default_groups" {
  description = "Create the default CIS landing zone IAM groups."
  type        = bool
  default     = true
}

variable "enable_default_policies" {
  description = "Create baseline CIS IAM policies."
  type        = bool
  default     = true
}

variable "groups" {
  description = "Additional or overriding IAM groups keyed by logical role."
  type = map(object({
    name        = optional(string)
    description = string
  }))
  default = {}
}

variable "dynamic_groups" {
  description = "Dynamic groups keyed by logical role."
  type = map(object({
    name          = optional(string)
    description   = string
    matching_rule = string
  }))
  default = {}
}

variable "policies" {
  description = "Additional IAM policies keyed by logical role."
  type = map(object({
    name           = optional(string)
    compartment_id = optional(string)
    description    = string
    statements     = list(string)
  }))
  default = {}
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
