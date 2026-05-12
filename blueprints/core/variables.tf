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
  description = "Optional OCI CLI config profile for local execution. Leave null to use the provider default profile."
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

variable "cis_level" {
  description = "Optional CIS OCI Benchmark profile selected by dedicated CIS wrapper blueprints."
  type        = string
  default     = null

  validation {
    condition     = var.cis_level == null ? true : contains(["level1", "level2"], lower(var.cis_level))
    error_message = "cis_level must be either level1 or level2."
  }
}

variable "parent_compartment_ocid" {
  description = "Parent compartment OCID for the landing zone root compartment. Defaults to tenancy_ocid when omitted."
  type        = string
  default     = null
}

variable "enable_delete" {
  description = "Allow Terraform to delete compartments during destroy. Keep true for ephemeral tests; review carefully for production."
  type        = bool
  default     = true
}

variable "tag_default_values" {
  description = "Optional overrides for default values in the landing zone tag namespace."
  type        = map(string)
  default     = {}
}

variable "tag_namespace_name" {
  description = "Optional tag namespace name override. Useful for ephemeral tests where tag namespace names must stay unique."
  type        = string
  default     = null
}

variable "enable_tagging" {
  description = "Create the landing zone tag namespace, tag definitions, and tag defaults. Disable for fast ephemeral tests."
  type        = bool
  default     = true
}

variable "enable_tag_defaults" {
  description = "Create tag defaults for the landing zone compartments. Disable for faster tests while keeping tag definitions."
  type        = bool
  default     = true
}

variable "required_tag_defaults" {
  description = "Tag names whose tag defaults should be marked required."
  type        = set(string)
  default     = []
}

variable "enable_logging" {
  description = "Create core governance log groups and optional service logs."
  type        = bool
  default     = true
}

variable "log_groups" {
  description = "Additional or overriding governance log groups keyed by logical name."
  type = map(object({
    display_name = optional(string)
    description  = optional(string)
  }))
  default = {}
}

variable "service_logs" {
  description = "OCI service logs keyed by logical name."
  type = map(object({
    log_group_key      = optional(string, "service")
    display_name       = optional(string)
    service            = string
    category           = string
    resource_id        = string
    source_type        = optional(string, "OCISERVICE")
    compartment_ocid   = optional(string)
    retention_duration = optional(number, 30)
    is_enabled         = optional(bool, true)
    parameters         = optional(map(string), {})
  }))
  default = {}
}

variable "vcn_flow_logs" {
  description = "Convenience VCN flow log definitions keyed by logical name."
  type = map(object({
    log_group_key      = optional(string, "network")
    display_name       = optional(string)
    resource_id        = string
    compartment_ocid   = optional(string)
    category           = optional(string, "all")
    retention_duration = optional(number, 30)
    is_enabled         = optional(bool, true)
    parameters         = optional(map(string), {})
  }))
  default = {}
}

variable "logging_saved_searches" {
  description = "Logging saved searches keyed by logical name."
  type = map(object({
    name             = optional(string)
    description      = optional(string)
    query            = string
    compartment_ocid = optional(string)
  }))
  default = {}
}

variable "enable_audit_retention" {
  description = "Configure tenancy audit retention. This is tenancy-wide and should be enabled deliberately."
  type        = bool
  default     = false
}

variable "audit_retention_period_days" {
  description = "Tenancy audit retention in days when enable_audit_retention is true."
  type        = number
  default     = 365

  validation {
    condition     = var.audit_retention_period_days >= 90 && var.audit_retention_period_days <= 365
    error_message = "audit_retention_period_days must be between 90 and 365."
  }
}

variable "cloud_guard_enabled" {
  description = "Enable Cloud Guard configuration and a default landing zone target."
  type        = bool
  default     = false
}

variable "cloud_guard_status" {
  description = "Cloud Guard tenancy status when managed by the core blueprint."
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], upper(var.cloud_guard_status))
    error_message = "cloud_guard_status must be ENABLED or DISABLED."
  }
}

variable "cloud_guard_reporting_region" {
  description = "Cloud Guard reporting region. Defaults to region when omitted."
  type        = string
  default     = null
}

variable "cloud_guard_self_manage_resources" {
  description = "Let Cloud Guard manage required service resources."
  type        = bool
  default     = true
}

variable "cloud_guard_enable_default_target" {
  description = "Create a default Cloud Guard target for the landing zone root compartment."
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

variable "cloud_guard_targets" {
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

variable "enable_budgets" {
  description = "Create OCI Budgets resources for the landing zone."
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

variable "default_budget_target_ocids" {
  description = "Optional set of compartment OCIDs tracked by the default landing zone budget. Defaults to the landing zone root compartment."
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

variable "enable_events" {
  description = "Create OCI Events and Notifications resources for governance notifications."
  type        = bool
  default     = false
}

variable "enable_default_event_topic" {
  description = "Create the default governance notification topic."
  type        = bool
  default     = true
}

variable "enable_default_event_rules" {
  description = "Create default IAM governance event rules that publish to the default topic."
  type        = bool
  default     = true
}

variable "event_notification_topics" {
  description = "ONS notification topics keyed by logical name."
  type = map(object({
    name             = optional(string)
    description      = optional(string)
    compartment_ocid = optional(string)
  }))
  default = {}
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

variable "iam_groups" {
  description = "Additional or overriding IAM groups keyed by logical role."
  type = map(object({
    name        = optional(string)
    description = string
  }))
  default = {}
}

variable "enable_default_iam_groups" {
  description = "Create default landing zone IAM groups."
  type        = bool
  default     = true
}

variable "enable_default_dynamic_groups" {
  description = "Create default dynamic groups for platform automation and workload instances."
  type        = bool
  default     = true
}

variable "iam_dynamic_groups" {
  description = "Additional or overriding dynamic groups keyed by logical role."
  type = map(object({
    name          = optional(string)
    description   = string
    matching_rule = string
  }))
  default = {}
}

variable "enable_default_iam_policies" {
  description = "Create default least-privilege IAM policies for the core landing zone."
  type        = bool
  default     = true
}

variable "iam_policies" {
  description = "Additional or overriding IAM policies keyed by logical role."
  type = map(object({
    name           = optional(string)
    compartment_id = optional(string)
    description    = string
    statements     = list(string)
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
