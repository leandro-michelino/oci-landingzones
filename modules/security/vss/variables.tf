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

variable "enable_vss" {
  description = "Create OCI Vulnerability Scanning Service resources managed by this module."
  type        = bool
  default     = false
}

variable "enable_default_host_scan" {
  description = "Create the default landing zone host scan recipe and target when VSS is enabled."
  type        = bool
  default     = true
}

variable "default_host_scan_target_compartment_ocid" {
  description = "Compartment OCID scanned by the default host scan target. Defaults to compartment_ocid when omitted."
  type        = string
  default     = null
}

variable "default_host_scan_schedule_type" {
  description = "Schedule type for the default host scan recipe."
  type        = string
  default     = "WEEKLY"
}

variable "default_host_scan_day_of_week" {
  description = "Day of week for the default weekly host scan schedule."
  type        = string
  default     = "SUNDAY"
}

variable "default_host_agent_scan_level" {
  description = "Agent scan level for the default host scan recipe."
  type        = string
  default     = "STANDARD"
}

variable "default_host_port_scan_level" {
  description = "Port scan level for the default host scan recipe."
  type        = string
  default     = "STANDARD"
}

variable "host_scan_recipes" {
  description = "Host scan recipes keyed by logical name."
  type = map(object({
    display_name     = optional(string)
    compartment_ocid = optional(string)
    agent_scan_level = optional(string, "STANDARD")
    port_scan_level  = optional(string, "STANDARD")
    schedule_type    = optional(string, "WEEKLY")
    day_of_week      = optional(string, "SUNDAY")
    agent_configuration = optional(object({
      vendor              = string
      vendor_type         = optional(string)
      vault_secret_id     = optional(string)
      should_un_install   = optional(bool)
      cis_scan_level      = optional(string)
      endpoint_scan_level = optional(string)
    }))
    application_settings = optional(object({
      is_enabled                  = bool
      application_scan_recurrence = string
      folders_to_scan = optional(list(object({
        folder          = string
        operatingsystem = string
      })), [])
    }))
  }))
  default = {}
}

variable "host_scan_targets" {
  description = "Host scan targets keyed by logical name."
  type = map(object({
    display_name            = optional(string)
    description             = optional(string)
    compartment_ocid        = optional(string)
    target_compartment_ocid = string
    host_scan_recipe_key    = optional(string)
    host_scan_recipe_id     = optional(string)
    instance_ids            = optional(set(string), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for target in values(var.host_scan_targets) :
      target.host_scan_recipe_key != null || target.host_scan_recipe_id != null
    ])
    error_message = "Each host_scan_targets entry must set host_scan_recipe_key or host_scan_recipe_id."
  }
}

variable "container_scan_recipes" {
  description = "Container image scan recipes keyed by logical name."
  type = map(object({
    display_name     = optional(string)
    compartment_ocid = optional(string)
    scan_level       = optional(string, "STANDARD")
    image_count      = optional(number)
  }))
  default = {}
}

variable "container_scan_targets" {
  description = "Container image scan targets keyed by logical name."
  type = map(object({
    display_name              = optional(string)
    description               = optional(string)
    compartment_ocid          = optional(string)
    container_scan_recipe_key = optional(string)
    container_scan_recipe_id  = optional(string)
    registry_compartment_ocid = string
    registry_type             = optional(string, "OCIR")
    repositories              = optional(set(string), [])
    url                       = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for target in values(var.container_scan_targets) :
      target.container_scan_recipe_key != null || target.container_scan_recipe_id != null
    ])
    error_message = "Each container_scan_targets entry must set container_scan_recipe_key or container_scan_recipe_id."
  }
}
