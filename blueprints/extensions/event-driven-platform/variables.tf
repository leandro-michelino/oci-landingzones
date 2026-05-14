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

variable "create_stream_pool" {
  description = "Create a Streaming pool for event-driven workloads."
  type        = bool
  default     = false
}
variable "stream_pool_id" {
  description = "Existing stream pool OCID when create_stream_pool is false."
  type        = string
  default     = null
}
variable "stream_pool_name" {
  description = "Optional stream pool name override."
  type        = string
  default     = null
}
variable "kms_key_id" {
  description = "Optional KMS key OCID for bucket and stream encryption."
  type        = string
  default     = null
}
variable "create_streams" {
  description = "Create platform streams."
  type        = bool
  default     = false
}
variable "streams" {
  description = "Streams keyed by logical name."
  type = map(object({
    partitions         = number
    retention_in_hours = optional(number)
  }))
  default = {
    events = {
      partitions = 1
    }
    deadletter = {
      partitions = 1
    }
  }
}

variable "create_archive_bucket" {
  description = "Create an Object Storage archive bucket for event payloads."
  type        = bool
  default     = false
}
variable "archive_bucket_name" {
  description = "Optional archive bucket name override."
  type        = string
  default     = null
}
variable "archive_bucket_versioning" {
  description = "Archive bucket versioning setting."
  type        = string
  default     = "Enabled"
}

variable "create_topic" {
  description = "Create an ONS notification topic for event alerts."
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
  default     = "Event-driven platform notifications."
}

variable "create_event_rules" {
  description = "Create OCI Events rules."
  type        = bool
  default     = false
}
variable "event_rules" {
  description = "Events rules keyed by logical name."
  type = map(object({
    display_name = optional(string)
    description  = optional(string)
    condition    = string
    is_enabled   = optional(bool)
    actions = list(object({
      action_type = string
      function_id = optional(string)
      stream_key  = optional(string)
      stream_id   = optional(string)
      topic_id    = optional(string)
      description = optional(string)
      is_enabled  = optional(bool)
    }))
  }))
  default = {}
}

variable "create_service_connector" {
  description = "Create a Service Connector from a stream to Object Storage, Function, Stream, or Notification target."
  type        = bool
  default     = false
}
variable "connector_display_name" {
  description = "Optional Service Connector display name override."
  type        = string
  default     = null
}
variable "connector_source_stream_key" {
  description = "Source stream key from streams map."
  type        = string
  default     = "events"
}
variable "connector_source_stream_id" {
  description = "Existing source stream OCID."
  type        = string
  default     = null
}
variable "connector_target_kind" {
  description = "Connector target kind."
  type        = string
  default     = "objectStorage"
}
variable "connector_target_bucket" {
  description = "Connector target bucket name."
  type        = string
  default     = null
}
variable "connector_target_namespace" {
  description = "Connector target Object Storage namespace."
  type        = string
  default     = null
}
variable "connector_target_function_id" {
  description = "Connector target function OCID."
  type        = string
  default     = null
}
variable "connector_target_stream_id" {
  description = "Connector target stream OCID."
  type        = string
  default     = null
}
variable "connector_target_topic_id" {
  description = "Connector target topic OCID."
  type        = string
  default     = null
}
variable "connector_object_prefix" {
  description = "Object prefix for connector archive payloads."
  type        = string
  default     = "events/"
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "IAM policy statements for Events, Functions, Streaming, Notifications, and archive buckets."
  type        = list(string)
  default     = []
}
