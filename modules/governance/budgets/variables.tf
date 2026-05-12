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

variable "enable_budgets" {
  description = "Create OCI Budgets resources managed by this module."
  type        = bool
  default     = false
}

variable "enable_default_budget" {
  description = "Create the default landing zone budget when default_budget_amount is set."
  type        = bool
  default     = true
}

variable "default_budget_amount" {
  description = "Amount for the default landing zone budget. Leave null to skip the default budget."
  type        = number
  default     = null

  validation {
    condition     = var.default_budget_amount == null ? true : var.default_budget_amount > 0
    error_message = "default_budget_amount must be greater than zero when set."
  }
}

variable "default_budget_target_ocid" {
  description = "Default compartment OCID tracked by the landing zone budget. Defaults to compartment_ocid when omitted."
  type        = string
  default     = null
}

variable "default_budget_target_ocids" {
  description = "Optional set of compartment OCIDs tracked by the default landing zone budget. Overrides default_budget_target_ocid when not empty."
  type        = set(string)
  default     = []
}

variable "default_budget_reset_period" {
  description = "Reset period for the default landing zone budget."
  type        = string
  default     = "MONTHLY"
}

variable "default_budget_alert_recipients" {
  description = "Email recipients for the default budget alert rule. Leave empty to create no default alert rule."
  type        = set(string)
  default     = []
}

variable "default_budget_alert_threshold" {
  description = "Threshold for the default budget alert rule."
  type        = number
  default     = 80

  validation {
    condition     = var.default_budget_alert_threshold > 0
    error_message = "default_budget_alert_threshold must be greater than zero."
  }
}

variable "default_budget_alert_threshold_type" {
  description = "Threshold type for the default budget alert rule."
  type        = string
  default     = "PERCENTAGE"
}

variable "default_budget_alert_type" {
  description = "Spend type for the default budget alert rule."
  type        = string
  default     = "ACTUAL"
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
