# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "compartment_ocid" {
  description = "Parent compartment OCID for resources managed by this module."
  type        = string
}

variable "region" {
  description = "OCI region name."
  type        = string
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

variable "cis_level" {
  description = "CIS OCI Benchmark profile for the landing zone. Use level1 for baseline controls or level2 for stricter controls."
  type        = string
  default     = null

  validation {
    condition     = var.cis_level == null ? true : contains(["level1", "level2"], lower(var.cis_level))
    error_message = "cis_level must be either level1 or level2."
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

variable "enable_security_zones" {
  description = "Create OCI Security Zones managed by this module."
  type        = bool
  default     = false
}

variable "enable_default_security_zone" {
  description = "Create the default landing zone Security Zone when a default recipe is provided."
  type        = bool
  default     = true
}

variable "default_security_zone_target_ocid" {
  description = "Compartment OCID protected by the default Security Zone. Defaults to compartment_ocid when omitted."
  type        = string
  default     = null
}

variable "default_security_zone_recipe_id" {
  description = "Security recipe OCID used by the default Security Zone."
  type        = string
  default     = null
}

variable "default_security_zone_recipe_display_name" {
  description = "Optional security recipe display name to look up for the default Security Zone when recipe OCID is not supplied."
  type        = string
  default     = null
}

variable "default_security_zone_recipe_compartment_ocid" {
  description = "Compartment OCID used when looking up default_security_zone_recipe_display_name. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "security_zones" {
  description = "Security Zones keyed by logical name."
  type = map(object({
    display_name                          = optional(string)
    description                           = optional(string)
    compartment_ocid                      = string
    security_zone_recipe_id               = optional(string)
    security_zone_recipe_display_name     = optional(string)
    security_zone_recipe_compartment_ocid = optional(string)
    is_inheritance_after_delete_enabled   = optional(bool)
  }))
  default = {}

  validation {
    condition = alltrue([
      for zone in values(var.security_zones) :
      zone.security_zone_recipe_id != null || zone.security_zone_recipe_display_name != null
    ])
    error_message = "Each security_zones entry must set security_zone_recipe_id or security_zone_recipe_display_name."
  }
}
