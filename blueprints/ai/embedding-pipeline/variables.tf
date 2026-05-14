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

variable "create_buckets" {
  description = "Create source, state, and failed-document buckets."
  type        = bool
  default     = false
}
variable "source_bucket_name" {
  description = "Optional source bucket name override."
  type        = string
  default     = null
}
variable "state_bucket_name" {
  description = "Optional state bucket name override."
  type        = string
  default     = null
}
variable "failed_bucket_name" {
  description = "Optional failed-object bucket name override."
  type        = string
  default     = null
}
variable "bucket_storage_tier" {
  description = "Bucket storage tier."
  type        = string
  default     = "Standard"
}
variable "bucket_versioning" {
  description = "Bucket versioning setting."
  type        = string
  default     = "Enabled"
}
variable "kms_key_id" {
  description = "Optional KMS key OCID for bucket and stream encryption."
  type        = string
  default     = null
}

variable "create_stream_pool" {
  description = "Create a Streaming pool for embedding work items."
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
variable "create_streams" {
  description = "Create streams for embedding chunks and indexing events."
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
    chunks = {
      partitions = 1
    }
    vectors = {
      partitions = 1
    }
  }
}

variable "create_event_rule" {
  description = "Create an Events rule that invokes the chunking function for new source objects."
  type        = bool
  default     = false
}
variable "event_rule_display_name" {
  description = "Optional Events rule display name override."
  type        = string
  default     = null
}
variable "event_rule_condition" {
  description = "Events rule condition JSON for source Object Storage events."
  type        = string
  default     = null
}
variable "chunking_function_id" {
  description = "Function OCID that chunks source documents."
  type        = string
  default     = null
}
variable "embedding_model_id" {
  description = "OCI GenAI embedding model OCID used by the embedding function."
  type        = string
  default     = null
}
variable "opensearch_endpoint" {
  description = "OpenSearch endpoint URL used by the indexing function."
  type        = string
  default     = null
}
variable "vector_index_name" {
  description = "Target vector index name."
  type        = string
  default     = "documents"
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "IAM policy statements for embedding functions, GenAI calls, streams, and vector index access."
  type        = list(string)
  default     = []
}
