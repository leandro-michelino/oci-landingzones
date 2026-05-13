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
  description = "Default compartment OCID where identity domains are created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "identity_domains" {
  description = "Identity domains keyed by logical name."
  type = map(object({
    compartment_ocid          = optional(string)
    display_name              = optional(string)
    description               = optional(string)
    home_region               = optional(string)
    license_type              = optional(string, "free")
    admin_email               = optional(string)
    admin_first_name          = optional(string)
    admin_last_name           = optional(string)
    admin_user_name           = optional(string)
    is_hidden_on_login        = optional(bool, false)
    is_notification_bypassed  = optional(bool, false)
    is_primary_email_required = optional(bool, true)
    replica_regions           = optional(set(string), [])
  }))
  default = {
    workforce = {
      description = "Custom workforce identity domain managed by Terraform."
    }
  }
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
