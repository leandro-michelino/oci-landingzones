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
  description = "Compartment OCID where private data platform resources are created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "enable_vault" {
  description = "Create Vault resources for platform encryption."
  type        = bool
  default     = true
}

variable "enable_default_vault" {
  description = "Create the default platform vault."
  type        = bool
  default     = true
}

variable "enable_default_key" {
  description = "Create the default platform KMS key."
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
  description = "KMS keys keyed by logical name."
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

variable "enable_data_bucket" {
  description = "Create the private data platform Object Storage bucket."
  type        = bool
  default     = true
}

variable "data_bucket_name" {
  description = "Optional Object Storage bucket name."
  type        = string
  default     = null
}

variable "bucket_kms_key_id" {
  description = "Optional KMS key OCID for Object Storage bucket encryption."
  type        = string
  default     = null
}

variable "bucket_auto_tiering" {
  description = "Object Storage auto-tiering setting."
  type        = string
  default     = "Disabled"
}

variable "bucket_storage_tier" {
  description = "Object Storage tier for the data bucket."
  type        = string
  default     = "Standard"
}

variable "enable_bucket_events" {
  description = "Enable Object Storage events on the data bucket."
  type        = bool
  default     = true
}

variable "enable_bucket_versioning" {
  description = "Enable Object Storage bucket versioning."
  type        = bool
  default     = true
}

variable "enable_object_storage_private_endpoint" {
  description = "Create an Object Storage private endpoint."
  type        = bool
  default     = true
}

variable "private_endpoint_name" {
  description = "Optional Object Storage private endpoint name."
  type        = string
  default     = null
}

variable "private_endpoint_prefix" {
  description = "Object Storage private endpoint prefix."
  type        = string
  default     = "data"
}

variable "private_endpoint_subnet_id" {
  description = "Optional subnet OCID for the Object Storage private endpoint."
  type        = string
  default     = null
}

variable "private_endpoint_subnet_key" {
  description = "Subnet key from the private network module used when private_endpoint_subnet_id is omitted."
  type        = string
  default     = "endpoints"
}

variable "private_endpoint_nsg_ids" {
  description = "Optional NSG OCIDs for the Object Storage private endpoint."
  type        = set(string)
  default     = []
}

variable "enable_streaming" {
  description = "Create OCI Streaming resources for private data pipelines."
  type        = bool
  default     = true
}

variable "create_stream_pool" {
  description = "Create a stream pool when enable_streaming is true."
  type        = bool
  default     = true
}

variable "stream_pool_id" {
  description = "Existing stream pool OCID used when create_stream_pool is false."
  type        = string
  default     = null
}

variable "stream_pool_name" {
  description = "Optional stream pool name."
  type        = string
  default     = null
}

variable "streaming_kms_key_id" {
  description = "Optional KMS key OCID for stream pool encryption."
  type        = string
  default     = null
}

variable "streaming_private_endpoint_subnet_id" {
  description = "Optional subnet OCID for Streaming private endpoint access."
  type        = string
  default     = null
}

variable "streaming_private_endpoint_nsg_ids" {
  description = "Optional NSG OCIDs for the Streaming private endpoint."
  type        = set(string)
  default     = []
}

variable "streams" {
  description = "Streams to create for private data pipelines."
  type = map(object({
    partitions         = number
    retention_in_hours = optional(number)
  }))
  default = {
    ingest = {
      partitions         = 1
      retention_in_hours = 24
    }
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
