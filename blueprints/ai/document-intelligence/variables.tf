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
  description = "Create intake, output, and failed-document buckets."
  type        = bool
  default     = false
}
variable "intake_bucket_name" {
  description = "Optional intake bucket name override."
  type        = string
  default     = null
}
variable "output_bucket_name" {
  description = "Optional output bucket name override."
  type        = string
  default     = null
}
variable "failed_bucket_name" {
  description = "Optional failed-document bucket name override."
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
  description = "Optional KMS key OCID for bucket encryption."
  type        = string
  default     = null
}

variable "create_document_project" {
  description = "Create an OCI Document Understanding project."
  type        = bool
  default     = false
}
variable "project_display_name" {
  description = "Optional Document Understanding project display name override."
  type        = string
  default     = null
}
variable "project_description" {
  description = "Document Understanding project description."
  type        = string
  default     = "Document intelligence project managed by Terraform."
}

variable "create_event_rule" {
  description = "Create an Events rule that invokes a document handler function on new intake objects."
  type        = bool
  default     = false
}
variable "event_rule_display_name" {
  description = "Optional Events rule display name override."
  type        = string
  default     = null
}
variable "event_rule_condition" {
  description = "Events rule condition JSON for Object Storage intake events."
  type        = string
  default     = null
}
variable "handler_function_id" {
  description = "Function OCID that orchestrates Document Understanding and GenAI calls."
  type        = string
  default     = null
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "IAM policy statements for document processors, functions, and audit readers."
  type        = list(string)
  default     = []
}
