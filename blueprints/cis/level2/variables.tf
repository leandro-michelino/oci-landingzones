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

variable "parent_compartment_ocid" {
  description = "Parent compartment OCID for the CIS landing zone root compartment. Defaults to tenancy_ocid when omitted."
  type        = string
  default     = null
}

variable "enable_delete" {
  description = "Allow Terraform to delete CIS landing zone compartments during destroy. Review carefully for production."
  type        = bool
  default     = true
}

variable "enable_tagging" {
  description = "Create the CIS landing zone tag namespace, tag definitions, and tag defaults."
  type        = bool
  default     = true
}

variable "enable_tag_defaults" {
  description = "Create tag defaults for CIS landing zone compartments."
  type        = bool
  default     = true
}

variable "enable_audit_retention" {
  description = "Configure tenancy audit retention for the CIS landing zone."
  type        = bool
  default     = true
}

variable "audit_retention_period_days" {
  description = "Tenancy audit retention in days."
  type        = number
  default     = 365
}

variable "cloud_guard_enabled" {
  description = "Enable Cloud Guard configuration and a default CIS landing zone target."
  type        = bool
  default     = true
}

variable "cloud_guard_detector_recipe_ids" {
  description = "Detector recipe OCIDs attached to the default Cloud Guard target."
  type        = set(string)
  default     = []
}

variable "cloud_guard_responder_recipe_ids" {
  description = "Responder recipe OCIDs attached to the default Cloud Guard target."
  type        = set(string)
  default     = []
}

variable "vault_enabled" {
  description = "Create OCI Vault and KMS keys for the CIS landing zone."
  type        = bool
  default     = false
}

variable "enable_default_vault_key" {
  description = "Create the default landing zone master encryption key when the default vault is created."
  type        = bool
  default     = true
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

variable "vault_keys" {
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

variable "security_zones_enabled" {
  description = "Create OCI Security Zones for protected CIS landing zone compartments."
  type        = bool
  default     = false
}

variable "default_security_zone_recipe_id" {
  description = "Security recipe OCID used by the default CIS landing zone Security Zone."
  type        = string
  default     = null
}

variable "default_security_zone_recipe_display_name" {
  description = "Optional security recipe display name to look up for the default CIS landing zone Security Zone when recipe OCID is not supplied."
  type        = string
  default     = null
}

variable "security_zones" {
  description = "Additional Security Zones keyed by logical name."
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

variable "budget_amount" {
  description = "Optional amount for the default CIS landing zone budget. Leave null to skip budget creation."
  type        = number
  default     = null

  validation {
    condition     = var.budget_amount == null ? true : var.budget_amount > 0
    error_message = "budget_amount must be greater than zero when set."
  }
}

variable "budget_alert_recipients" {
  description = "Email recipients for the default CIS budget alert rule."
  type        = set(string)
  default     = []
}

variable "budgets" {
  description = "Additional OCI Budgets keyed by logical name."
  type = map(object({
    display_name                          = optional(string)
    description                           = optional(string)
    compartment_ocid                      = optional(string)
    amount                                = number
    reset_period                          = optional(string, "MONTHLY")
    target_type                           = optional(string, "COMPARTMENT")
    targets                               = optional(set(string), [])
    processing_period_type                = optional(string)
    start_date                            = optional(string)
    end_date                              = optional(string)
    budget_processing_period_start_offset = optional(number)
    alert_rules = optional(map(object({
      display_name   = optional(string)
      description    = optional(string)
      message        = optional(string)
      recipients     = optional(string)
      threshold      = number
      threshold_type = optional(string, "PERCENTAGE")
      type           = optional(string, "ACTUAL")
    })), {})
  }))
  default = {}
}

variable "enable_events" {
  description = "Create OCI Events and Notifications resources for CIS governance notifications."
  type        = bool
  default     = true
}

variable "event_subscriptions" {
  description = "ONS subscriptions keyed by logical name. Endpoints should be supplied from local ignored tfvars."
  type = map(object({
    topic_key        = optional(string, "default")
    topic_id         = optional(string)
    compartment_ocid = optional(string)
    protocol         = string
    endpoint         = string
    delivery_policy  = optional(string)
  }))
  default = {}
}

variable "event_rules" {
  description = "Additional or overriding OCI Events rules keyed by logical name."
  type = map(object({
    display_name     = optional(string)
    description      = optional(string)
    compartment_ocid = optional(string)
    condition        = string
    is_enabled       = optional(bool, true)
    actions = list(object({
      action_type = optional(string, "ONS")
      description = optional(string)
      function_id = optional(string)
      is_enabled  = optional(bool, true)
      stream_id   = optional(string)
      topic_key   = optional(string, "default")
      topic_id    = optional(string)
    }))
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
