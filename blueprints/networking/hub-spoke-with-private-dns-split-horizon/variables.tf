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

variable "enable_private_dns" {
  description = "Create private DNS view and zones."
  type        = bool
  default     = true
}

variable "dns_label" {
  description = "Short semantic label for the private DNS view."
  type        = string
  default     = "hub"
}

variable "private_zones" {
  description = "Private DNS zones keyed by logical name."
  type = map(object({
    name        = string
    zone_type   = optional(string, "PRIMARY")
    scope       = optional(string, "PRIVATE")
    description = optional(string)
  }))
  default = {
    shared = {
      name = "shared.internal"
    }
    apps = {
      name = "apps.internal"
    }
  }
}

variable "attach_private_view_to_vcn_resolvers" {
  description = "Attach the created private DNS view to hub and spoke VCN resolvers."
  type        = bool
  default     = true
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
