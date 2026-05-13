# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "region" {
  description = "Primary OCI region name."
  type        = string
}

variable "standby_region" {
  description = "Standby OCI region name."
  type        = string
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
  description = "Short primary OCI region key used in resource names."
  type        = string
}

variable "standby_region_key" {
  description = "Short standby OCI region key used in resource names."
  type        = string
}

variable "compartment_ocid" {
  description = "Default compartment OCID for FSDR resources. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "primary_compartment_ocid" {
  description = "Primary-region compartment OCID for FSDR resources."
  type        = string
  default     = null
}

variable "standby_compartment_ocid" {
  description = "Standby-region compartment OCID for FSDR resources."
  type        = string
  default     = null
}

variable "enable_dr_log_buckets" {
  description = "Create Object Storage buckets used by DR protection group logs."
  type        = bool
  default     = true
}

variable "primary_log_bucket_name" {
  description = "Optional primary-region DR log bucket name."
  type        = string
  default     = null
}

variable "standby_log_bucket_name" {
  description = "Optional standby-region DR log bucket name."
  type        = string
  default     = null
}

variable "enable_object_events" {
  description = "Enable Object Storage events on DR log buckets."
  type        = bool
  default     = true
}

variable "enable_bucket_versioning" {
  description = "Enable versioning on DR log buckets."
  type        = bool
  default     = true
}

variable "log_bucket_storage_tier" {
  description = "Object Storage tier for DR log buckets."
  type        = string
  default     = "Standard"
}

variable "enable_dr_protection_groups" {
  description = "Create primary and standby FSDR protection groups."
  type        = bool
  default     = true
}

variable "primary_dr_protection_group_name" {
  description = "Optional display name for the primary DR protection group."
  type        = string
  default     = null
}

variable "standby_dr_protection_group_name" {
  description = "Optional display name for the standby DR protection group."
  type        = string
  default     = null
}

variable "primary_members" {
  description = "Primary DR protection group members."
  type = list(object({
    member_id   = string
    member_type = string
    is_movable  = optional(bool)
  }))
  default = []
}

variable "standby_members" {
  description = "Standby DR protection group members."
  type = list(object({
    member_id   = string
    member_type = string
    is_movable  = optional(bool)
  }))
  default = []
}

variable "enable_dr_plan" {
  description = "Create a DR plan for the primary protection group."
  type        = bool
  default     = false
}

variable "dr_plan_display_name" {
  description = "Optional display name for the primary DR plan."
  type        = string
  default     = null
}

variable "dr_plan_type" {
  description = "FSDR plan type, such as SWITCHOVER or FAILOVER."
  type        = string
  default     = "SWITCHOVER"
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
