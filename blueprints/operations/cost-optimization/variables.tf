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
  description = "OCI tenancy home region for Identity and tagging operations."
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
  description = "Compartment OCID where cost-governance resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
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

variable "default_cost_center" {
  description = "Default cost-center value used for tag defaults and common freeform tags."
  type        = string
  default     = "shared-services"
}

variable "default_owner" {
  description = "Default owner value used for tag defaults and common freeform tags."
  type        = string
  default     = "platform"
}

variable "enable_tagging" {
  description = "Create the FinOps tag namespace and tag definitions."
  type        = bool
  default     = true
}

variable "enable_tag_defaults" {
  description = "Create tag defaults for supplied compartments."
  type        = bool
  default     = false
}

variable "tag_namespace_name" {
  description = "OCI tag namespace name. Defaults to the governance tagging module convention."
  type        = string
  default     = null
}

variable "tag_namespace_description" {
  description = "Description for the FinOps tag namespace."
  type        = string
  default     = "FinOps tag namespace managed by Terraform."
}

variable "tag_definitions" {
  description = "Defined tags to create for cost attribution and ownership."
  type = map(object({
    description      = string
    is_cost_tracking = optional(bool)
  }))
  default = {
    Environment = {
      description = "Deployment environment such as dev, uat, prod, or dr."
    }
    CostCenter = {
      description      = "Finance or chargeback cost center."
      is_cost_tracking = true
    }
    Owner = {
      description = "Owning team, business unit, or operating entity."
    }
    Project = {
      description = "Project, product, or workload identifier."
    }
    ManagedBy = {
      description = "Management source such as terraform or manual."
    }
    Blueprint = {
      description = "Landing zone blueprint that created or manages the resource."
    }
  }
}

variable "tag_default_compartment_ids" {
  description = "Map of compartment keys to OCIDs where tag defaults should be applied."
  type        = map(string)
  default     = {}
}

variable "tag_default_values" {
  description = "Tag default value overrides keyed by tag name."
  type        = map(string)
  default     = {}
}

variable "required_tag_defaults" {
  description = "Tag names whose tag defaults should be marked required."
  type        = set(string)
  default     = []
}

variable "enable_budgets" {
  description = "Create OCI Budgets resources."
  type        = bool
  default     = false
}

variable "enable_default_budget" {
  description = "Create the default landing-zone budget when default_budget_amount is set."
  type        = bool
  default     = true
}

variable "default_budget_amount" {
  description = "Amount for the default budget. Leave null to skip the default budget."
  type        = number
  default     = null

  validation {
    condition     = var.default_budget_amount == null ? true : var.default_budget_amount > 0
    error_message = "default_budget_amount must be greater than zero when set."
  }
}

variable "default_budget_target_ocid" {
  description = "Default compartment OCID tracked by the landing-zone budget. Defaults to compartment_ocid when omitted."
  type        = string
  default     = null
}

variable "default_budget_target_ocids" {
  description = "Optional set of compartment OCIDs tracked by the default budget."
  type        = set(string)
  default     = []
}

variable "default_budget_reset_period" {
  description = "Reset period for the default budget."
  type        = string
  default     = "MONTHLY"
}

variable "default_budget_alert_recipients" {
  description = "Email recipients for the default budget alert rule."
  type        = set(string)
  default     = []
}

variable "default_budget_alert_threshold" {
  description = "Threshold for the default budget alert rule."
  type        = number
  default     = 80
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

variable "enable_notifications" {
  description = "Create FinOps ONS notification topics, subscriptions, and optional Events rules."
  type        = bool
  default     = false
}

variable "notification_compartment_ocid" {
  description = "Compartment OCID where FinOps notification resources are created. Defaults to compartment_ocid."
  type        = string
  default     = null
}

variable "notification_topics" {
  description = "Additional ONS notification topics keyed by logical name."
  type = map(object({
    name             = optional(string)
    description      = optional(string)
    compartment_ocid = optional(string)
  }))
  default = {}
}

variable "notification_subscriptions" {
  description = "ONS subscriptions keyed by logical name. Endpoints should be supplied from local ignored tfvars."
  type = map(object({
    topic_key        = optional(string, "finops")
    topic_id         = optional(string)
    compartment_ocid = optional(string)
    protocol         = string
    endpoint         = string
    delivery_policy  = optional(string)
  }))
  default = {}
}

variable "notification_event_rules" {
  description = "Optional OCI Events rules for cost-governance signals keyed by logical name."
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
      topic_key   = optional(string, "finops")
      topic_id    = optional(string)
    }))
  }))
  default = {}
}

variable "enable_budget_alarm" {
  description = "Create a Monitoring alarm for a supplied budget or cost query."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_budget_alarm || var.budget_alarm_query != null
    error_message = "budget_alarm_query must be set when enable_budget_alarm is true."
  }

  validation {
    condition     = !var.enable_budget_alarm || var.enable_notifications || length(var.budget_alarm_destination_ids) > 0
    error_message = "Enable notifications or set budget_alarm_destination_ids when enable_budget_alarm is true."
  }
}

variable "budget_alarm_namespace" {
  description = "Monitoring namespace for the budget alarm query."
  type        = string
  default     = "oci_billing"
}

variable "budget_alarm_query" {
  description = "Monitoring query for the budget alarm. Required only when enable_budget_alarm is true."
  type        = string
  default     = null
}

variable "budget_alarm_destination_ids" {
  description = "Additional ONS topic OCIDs used by the budget Monitoring alarm."
  type        = set(string)
  default     = []
}

variable "budget_alarm_metric_compartment_ocid" {
  description = "Metric compartment OCID for the budget alarm. Defaults to compartment_ocid."
  type        = string
  default     = null
}

variable "budget_alarm_metric_compartment_id_in_subtree" {
  description = "Evaluate budget alarm metrics across child compartments."
  type        = bool
  default     = true
}

variable "budget_alarm_severity" {
  description = "Monitoring severity for the budget alarm."
  type        = string
  default     = "WARNING"
}

variable "budget_alarm_pending_duration" {
  description = "Monitoring pending duration for the budget alarm."
  type        = string
  default     = "PT5M"
}

variable "budget_alarm_repeat_notification_duration" {
  description = "Repeat notification duration for the budget alarm."
  type        = string
  default     = "PT24H"
}

variable "monitoring_alarms" {
  description = "Additional OCI Monitoring alarms keyed by logical name."
  type = map(object({
    display_name                                  = optional(string)
    body                                          = optional(string)
    compartment_ocid                              = optional(string)
    metric_compartment_ocid                       = optional(string)
    metric_compartment_id_in_subtree              = optional(bool, false)
    namespace                                     = string
    query                                         = string
    severity                                      = optional(string, "WARNING")
    is_enabled                                    = optional(bool, true)
    destinations                                  = optional(set(string), [])
    destination_topic_keys                        = optional(set(string), [])
    pending_duration                              = optional(string)
    resolution                                    = optional(string)
    resource_group                                = optional(string)
    message_format                                = optional(string)
    repeat_notification_duration                  = optional(string)
    evaluation_slack_duration                     = optional(string)
    is_notifications_per_metric_dimension_enabled = optional(bool)
    notification_title                            = optional(string)
  }))
  default = {}
}

variable "enable_optimizer_enrollment" {
  description = "Manage OCI Optimizer enrollment status when optimizer_enrollment_status_id is supplied."
  type        = bool
  default     = false
}

variable "optimizer_enrollment_status_id" {
  description = "Optimizer enrollment status OCID or provider-specific enrollment status identifier."
  type        = string
  default     = null
}

variable "optimizer_enrollment_status" {
  description = "Optimizer enrollment status to set."
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], upper(var.optimizer_enrollment_status))
    error_message = "optimizer_enrollment_status must be ENABLED or DISABLED."
  }
}

variable "enable_optimizer_profiles" {
  description = "Create OCI Optimizer profiles."
  type        = bool
  default     = false
}

variable "enable_default_optimizer_profile" {
  description = "Create a default FinOps Optimizer profile when optimizer profiles are enabled."
  type        = bool
  default     = true
}

variable "optimizer_aggregation_interval_in_days" {
  description = "Aggregation interval in days for the default Optimizer profile."
  type        = number
  default     = 30
}

variable "optimizer_target_compartment_ids" {
  description = "Compartment OCIDs targeted by the default Optimizer profile."
  type        = set(string)
  default     = []
}

variable "optimizer_profiles" {
  description = "Additional OCI Optimizer profiles keyed by logical name."
  type = map(object({
    name                         = optional(string)
    description                  = optional(string)
    compartment_ocid             = optional(string)
    aggregation_interval_in_days = optional(number)
    target_compartment_ids       = optional(set(string), [])
    target_tags = optional(list(object({
      tag_namespace_name  = string
      tag_definition_name = string
      tag_value_type      = string
      tag_values          = optional(list(string), [])
    })), [])
    levels_configuration = optional(list(object({
      recommendation_id = optional(string)
      level             = optional(string)
    })), [])
  }))
  default = {}
}

variable "policy_compartment_ocid" {
  description = "Compartment OCID where the optional FinOps IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "finops_policy_statements" {
  description = "Optional IAM policy statements that grant FinOps teams budget, optimizer, and notification access."
  type        = list(string)
  default     = []
}
