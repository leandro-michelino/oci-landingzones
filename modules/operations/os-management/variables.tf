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

variable "enable_os_management" {
  description = "Create OS Management Hub resources managed by this module."
  type        = bool
  default     = false
}

variable "default_arch_type" {
  description = "Default OS Management Hub architecture type for managed instance groups."
  type        = string
  default     = "X86_64"
}

variable "default_os_family" {
  description = "Default OS family for OS Management Hub managed instance groups."
  type        = string
  default     = "ORACLE_LINUX_8"
}

variable "default_vendor_name" {
  description = "Default vendor name for OS Management Hub managed instance groups."
  type        = string
  default     = "ORACLE"
}

variable "managed_instance_groups" {
  description = "OS Management Hub managed instance groups keyed by logical name."
  type = map(object({
    compartment_ocid      = optional(string)
    display_name          = optional(string)
    description           = optional(string)
    arch_type             = optional(string)
    os_family             = optional(string)
    vendor_name           = optional(string)
    location              = optional(string)
    managed_instance_ids  = optional(set(string), [])
    notification_topic_id = optional(string)
    software_source_ids   = optional(set(string), [])
  }))
  default = {}
}

variable "scheduled_jobs" {
  description = "OS Management Hub scheduled jobs keyed by logical name."
  type = map(object({
    compartment_ocid           = optional(string)
    display_name               = optional(string)
    description                = optional(string)
    schedule_type              = optional(string, "RECURRING")
    time_next_execution        = string
    recurring_rule             = optional(string)
    managed_compartment_ids    = optional(set(string), [])
    managed_instance_group_ids = optional(set(string), [])
    managed_instance_ids       = optional(set(string), [])
    is_subcompartment_included = optional(bool, false)
    retry_intervals            = optional(set(number), [])
    operations = list(object({
      operation_type         = string
      package_names          = optional(set(string), [])
      reboot_timeout_in_mins = optional(number)
      software_source_ids    = optional(set(string), [])
      windows_update_names   = optional(set(string), [])
    }))
  }))
  default = {}
}
