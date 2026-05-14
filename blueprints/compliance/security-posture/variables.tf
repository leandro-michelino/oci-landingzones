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
variable "compartment_ocid" {
  description = "Compartment OCID where resources are created. Defaults to tenancy_ocid for validation-only tests."
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

variable "create_report_bucket" {
  description = "Create a private Object Storage bucket for security reports."
  type        = bool
  default     = false
}
variable "report_bucket_name" {
  description = "Optional report bucket name override."
  type        = string
  default     = null
}
variable "report_bucket_storage_tier" {
  description = "Report bucket storage tier."
  type        = string
  default     = "Standard"
}
variable "report_bucket_versioning" {
  description = "Report bucket versioning setting."
  type        = string
  default     = "Enabled"
}
variable "kms_key_id" {
  description = "Optional KMS key OCID for report bucket encryption."
  type        = string
  default     = null
}

variable "create_topic" {
  description = "Create an ONS topic for security notifications."
  type        = bool
  default     = false
}
variable "topic_id" {
  description = "Existing ONS topic OCID when create_topic is false."
  type        = string
  default     = null
}
variable "topic_name" {
  description = "Optional topic name override."
  type        = string
  default     = null
}
variable "topic_description" {
  description = "Notification topic description."
  type        = string
  default     = "Security posture automation notifications."
}

variable "create_cloud_guard_target" {
  description = "Create a Cloud Guard target for the protected scope."
  type        = bool
  default     = false
}
variable "cloud_guard_target_id" {
  description = "Existing Cloud Guard target OCID when create_cloud_guard_target is false."
  type        = string
  default     = null
}
variable "cloud_guard_target_display_name" {
  description = "Cloud Guard target display name."
  type        = string
  default     = null
}
variable "cloud_guard_target_description" {
  description = "Cloud Guard target description."
  type        = string
  default     = "Security posture automation target managed by Terraform."
}
variable "cloud_guard_target_resource_id" {
  description = "Resource OCID protected by the Cloud Guard target. Defaults to compartment_ocid."
  type        = string
  default     = null
}
variable "cloud_guard_target_resource_type" {
  description = "Cloud Guard target resource type."
  type        = string
  default     = "COMPARTMENT"
}
variable "detector_recipe_ids" {
  description = "Detector recipe OCIDs attached to the Cloud Guard target."
  type        = set(string)
  default     = []
}
variable "responder_recipe_ids" {
  description = "Responder recipe OCIDs attached to the Cloud Guard target."
  type        = set(string)
  default     = []
}

variable "create_host_scan_recipe" {
  description = "Create a Vulnerability Scanning host scan recipe."
  type        = bool
  default     = false
}
variable "host_scan_recipe_id" {
  description = "Existing host scan recipe OCID when create_host_scan_recipe is false."
  type        = string
  default     = null
}
variable "host_scan_recipe_display_name" {
  description = "Host scan recipe display name."
  type        = string
  default     = null
}
variable "host_agent_scan_level" {
  description = "Host agent scan level."
  type        = string
  default     = "STANDARD"
}
variable "host_agent_vendor" {
  description = "Optional host agent vendor."
  type        = string
  default     = null
}
variable "host_agent_vendor_type" {
  description = "Optional host agent vendor type."
  type        = string
  default     = null
}
variable "host_agent_vault_secret_id" {
  description = "Optional Vault secret OCID for host agent configuration."
  type        = string
  default     = null
}
variable "host_port_scan_level" {
  description = "Host port scan level."
  type        = string
  default     = "STANDARD"
}
variable "host_scan_schedule_type" {
  description = "Host scan schedule type."
  type        = string
  default     = "WEEKLY"
}
variable "host_scan_day_of_week" {
  description = "Host scan day of week for weekly schedules."
  type        = string
  default     = "SUNDAY"
}
variable "create_host_scan_target" {
  description = "Create a Vulnerability Scanning host scan target."
  type        = bool
  default     = false
}
variable "host_scan_target_display_name" {
  description = "Host scan target display name."
  type        = string
  default     = null
}
variable "host_scan_target_description" {
  description = "Host scan target description."
  type        = string
  default     = "Host scan target managed by Terraform."
}
variable "host_scan_target_compartment_id" {
  description = "Target compartment scanned by the host scan target. Defaults to compartment_ocid."
  type        = string
  default     = null
}
variable "host_scan_instance_ids" {
  description = "Optional compute instance OCIDs for host scanning."
  type        = list(string)
  default     = []
}

variable "event_rules" {
  description = "OCI Events rules for security findings and auto-remediation hooks."
  type = map(object({
    display_name = optional(string)
    description  = optional(string)
    condition    = string
    is_enabled   = optional(bool, true)
    actions = list(object({
      action_type = string
      is_enabled  = optional(bool, true)
      description = optional(string)
      topic_id    = optional(string)
      function_id = optional(string)
      stream_id   = optional(string)
    }))
  }))
  default = {}
}
variable "alarms" {
  description = "Monitoring alarms keyed by logical name."
  type = map(object({
    display_name          = optional(string)
    namespace             = string
    query                 = string
    severity              = optional(string, "WARNING")
    destinations          = list(string)
    metric_compartment_id = optional(string)
    body                  = optional(string)
    is_enabled            = optional(bool, true)
  }))
  default = {}
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the optional IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "Optional IAM policy statements for security admins, responders, scanners, and auditors."
  type        = list(string)
  default     = []
}
