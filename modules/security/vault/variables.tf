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

variable "enable_vault" {
  description = "Create OCI Vault and KMS keys managed by this module."
  type        = bool
  default     = false
}

variable "enable_default_vault" {
  description = "Create the default landing zone vault."
  type        = bool
  default     = true
}

variable "default_vault_type" {
  description = "Vault type for the default landing zone vault."
  type        = string
  default     = "DEFAULT"
}

variable "enable_default_key" {
  description = "Create the default landing zone master encryption key when the default vault is created."
  type        = bool
  default     = true
}

variable "default_key_algorithm" {
  description = "Key shape algorithm for the default landing zone key."
  type        = string
  default     = "AES"
}

variable "default_key_length" {
  description = "Key shape length for the default landing zone key."
  type        = number
  default     = 32
}

variable "default_key_protection_mode" {
  description = "Protection mode for the default landing zone key."
  type        = string
  default     = "HSM"
}

variable "vaults" {
  description = "Additional OCI Vaults keyed by logical name."
  type = map(object({
    display_name     = optional(string)
    compartment_ocid = optional(string)
    vault_type       = optional(string, "DEFAULT")
  }))
  default = {}
}

variable "keys" {
  description = "KMS keys keyed by logical name. Use vault_key for module-created vaults or vault_management_endpoint for existing vaults."
  type = map(object({
    display_name              = optional(string)
    compartment_ocid          = optional(string)
    vault_key                 = optional(string, "default")
    vault_management_endpoint = optional(string)
    algorithm                 = optional(string, "AES")
    length                    = optional(number, 32)
    curve_id                  = optional(string)
    protection_mode           = optional(string, "HSM")
    desired_state             = optional(string)
    is_auto_rotation_enabled  = optional(bool)
    rotation_interval_in_days = optional(number)
    time_of_schedule_start    = optional(string)
  }))
  default = {}
}
