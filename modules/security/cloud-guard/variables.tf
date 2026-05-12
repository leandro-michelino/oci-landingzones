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

variable "enable_cloud_guard" {
  description = "Enable Cloud Guard configuration and targets managed by this module."
  type        = bool
  default     = false
}

variable "cloud_guard_status" {
  description = "Cloud Guard tenancy status when this module manages the configuration."
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], upper(var.cloud_guard_status))
    error_message = "cloud_guard_status must be ENABLED or DISABLED."
  }
}

variable "reporting_region" {
  description = "Cloud Guard reporting region. Defaults to the provider region when omitted."
  type        = string
  default     = null
}

variable "self_manage_resources" {
  description = "Let Cloud Guard manage required service resources."
  type        = bool
  default     = true
}

variable "enable_default_target" {
  description = "Create a default Cloud Guard target for target_resource_ocid."
  type        = bool
  default     = true
}

variable "target_resource_ocid" {
  description = "Default Cloud Guard target resource OCID. Defaults to compartment_ocid."
  type        = string
  default     = null
}

variable "target_resource_type" {
  description = "Default Cloud Guard target resource type."
  type        = string
  default     = "COMPARTMENT"
}

variable "target_detector_recipe_ids" {
  description = "Detector recipe OCIDs attached to the default Cloud Guard target."
  type        = set(string)
  default     = []
}

variable "target_responder_recipe_ids" {
  description = "Responder recipe OCIDs attached to the default Cloud Guard target."
  type        = set(string)
  default     = []
}

variable "targets" {
  description = "Additional Cloud Guard targets keyed by logical name."
  type = map(object({
    display_name         = optional(string)
    description          = optional(string)
    compartment_ocid     = optional(string)
    target_resource_id   = string
    target_resource_type = optional(string, "COMPARTMENT")
    detector_recipe_ids  = optional(set(string), [])
    responder_recipe_ids = optional(set(string), [])
  }))
  default = {}
}
