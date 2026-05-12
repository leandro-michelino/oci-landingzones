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
  description = "Compartment OCID where Streaming resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "enable_streaming" {
  description = "Create OCI Streaming resources. Disabled by default to avoid cost in smoke tests."
  type        = bool
  default     = false
}

variable "create_stream_pool" {
  description = "Create a stream pool when enable_streaming is true. Disable when using an existing stream pool."
  type        = bool
  default     = true
}

variable "stream_pool_id" {
  description = "Existing stream pool OCID used when create_stream_pool is false."
  type        = string
  default     = null
}

variable "stream_pool_name" {
  description = "Optional stream pool name override."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "Optional Vault key OCID for stream pool encryption."
  type        = string
  default     = null
}

variable "private_endpoint_subnet_id" {
  description = "Optional subnet OCID for private stream pool access."
  type        = string
  default     = null
}

variable "private_endpoint_nsg_ids" {
  description = "Optional NSG OCIDs for the stream pool private endpoint."
  type        = set(string)
  default     = []
}

variable "kafka_settings" {
  description = "Optional Kafka-compatible stream pool settings."
  type = object({
    auto_create_topics_enable = optional(bool)
    log_retention_hours       = optional(number)
    num_partitions            = optional(number)
  })
  default = null
}

variable "streams" {
  description = "Streams to create when enable_streaming is true."
  type = map(object({
    partitions         = number
    retention_in_hours = optional(number)
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
