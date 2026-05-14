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

variable "create_audit_bucket" {
  description = "Create a private Object Storage bucket for redacted prompt and response archives."
  type        = bool
  default     = false
}
variable "audit_bucket_name" {
  description = "Optional audit bucket name override."
  type        = string
  default     = null
}
variable "audit_bucket_storage_tier" {
  description = "Audit bucket storage tier."
  type        = string
  default     = "Standard"
}
variable "audit_bucket_versioning" {
  description = "Audit bucket versioning setting."
  type        = string
  default     = "Enabled"
}
variable "kms_key_id" {
  description = "Optional KMS key OCID for bucket encryption."
  type        = string
  default     = null
}

variable "create_log_group" {
  description = "Create a Logging log group for guardrail telemetry."
  type        = bool
  default     = false
}
variable "log_group_name" {
  description = "Optional log group display name override."
  type        = string
  default     = null
}

variable "create_service_connector" {
  description = "Create a Service Connector from a log source to Object Storage or Streaming."
  type        = bool
  default     = false
}
variable "connector_display_name" {
  description = "Optional Service Connector display name override."
  type        = string
  default     = null
}
variable "connector_description" {
  description = "Service Connector description."
  type        = string
  default     = "Routes GenAI guardrail logs to the selected audit target."
}
variable "connector_source_kind" {
  description = "Service Connector source kind."
  type        = string
  default     = "logging"
}
variable "connector_source_log_group_id" {
  description = "Source log group OCID for guardrail logs."
  type        = string
  default     = null
}
variable "connector_source_log_id" {
  description = "Source log OCID for guardrail logs."
  type        = string
  default     = null
}
variable "connector_target_kind" {
  description = "Service Connector target kind."
  type        = string
  default     = "objectStorage"
}
variable "connector_target_bucket" {
  description = "Target bucket name when the connector target is Object Storage."
  type        = string
  default     = null
}
variable "connector_target_namespace" {
  description = "Target Object Storage namespace."
  type        = string
  default     = null
}
variable "connector_target_stream_id" {
  description = "Target stream OCID when the connector target is Streaming."
  type        = string
  default     = null
}
variable "connector_object_prefix" {
  description = "Object prefix for connector archive objects."
  type        = string
  default     = "genai-guardrails/"
}

variable "create_cloud_guard_recipe" {
  description = "Create a Cloud Guard detector recipe placeholder for unusual GenAI usage."
  type        = bool
  default     = false
}
variable "detector_display_name" {
  description = "Optional Cloud Guard detector recipe display name override."
  type        = string
  default     = null
}
variable "detector" {
  description = "Cloud Guard detector type."
  type        = string
  default     = null
}
variable "source_detector_recipe_id" {
  description = "Optional source detector recipe OCID to clone."
  type        = string
  default     = null
}

variable "notification_topic_id" {
  description = "ONS topic OCID used by Monitoring alarms."
  type        = string
  default     = null
}
variable "alarms" {
  description = "Monitoring alarms keyed by logical name."
  type = map(object({
    display_name          = optional(string)
    namespace             = string
    query                 = string
    severity              = string
    metric_compartment_id = optional(string)
    is_enabled            = optional(bool)
    destinations          = optional(list(string))
  }))
  default = {}
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "IAM policy statements for guardrail services, audit readers, and security reviewers."
  type        = list(string)
  default     = []
}
