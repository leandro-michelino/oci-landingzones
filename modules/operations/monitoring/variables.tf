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

variable "enable_monitoring" {
  description = "Create OCI Monitoring alarms and optional notification resources managed by this module."
  type        = bool
  default     = false
}

variable "enable_default_topic" {
  description = "Create the default monitoring notification topic when monitoring is enabled."
  type        = bool
  default     = true
}

variable "notification_topics" {
  description = "ONS notification topics keyed by logical name."
  type = map(object({
    name             = optional(string)
    description      = optional(string)
    compartment_ocid = optional(string)
  }))
  default = {}
}

variable "subscriptions" {
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

variable "alarms" {
  description = "OCI Monitoring alarms keyed by logical name."
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

  validation {
    condition = alltrue([
      for alarm in values(var.alarms) :
      length(alarm.destinations) > 0 || length(alarm.destination_topic_keys) > 0
    ])
    error_message = "Each alarms entry must set destinations or destination_topic_keys."
  }
}
