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
  description = "Compartment OCID where networking resources are deployed. Defaults to tenancy_ocid for simple tests."
  type        = string
  default     = null
}

variable "enable_zpr_configuration" {
  description = "Enable ZPR configuration for this landing zone. Optional and intentionally off by default."
  type        = bool
  default     = false
}

variable "enable_zpr_policies" {
  description = "Create ZPR policy statements for micro-segmentation."
  type        = bool
  default     = false
}

variable "zpr_policies" {
  description = "ZPR policies keyed by logical name."
  type = map(object({
    name        = string
    description = string
    statements  = list(string)
  }))
  default = {
    hub_spoke_microsegmentation = {
      name        = "hub-spoke-microsegmentation"
      description = "Starter ZPR policy definition for hub/spoke east-west controls."
      statements  = []
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
