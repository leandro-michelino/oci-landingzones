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
  description = "Create input and output buckets for AI service jobs."
  type        = bool
  default     = false
}
variable "input_bucket_name" {
  description = "Optional input bucket name override."
  type        = string
  default     = null
}
variable "output_bucket_name" {
  description = "Optional output bucket name override."
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

variable "enable_document_project" {
  description = "Create an OCI Document Understanding project."
  type        = bool
  default     = false
}
variable "enable_language_project" {
  description = "Create an OCI Language project."
  type        = bool
  default     = false
}
variable "enable_vision_project" {
  description = "Create an OCI Vision project."
  type        = bool
  default     = false
}
variable "project_description" {
  description = "Default description used by AI service projects."
  type        = string
  default     = "AI Services project managed by Terraform."
}

variable "create_vision_private_endpoint" {
  description = "Create an OCI Vision private endpoint."
  type        = bool
  default     = false
}
variable "vision_private_endpoint_subnet_id" {
  description = "Subnet OCID for the Vision private endpoint."
  type        = string
  default     = null
}
variable "vision_private_endpoint_display_name" {
  description = "Optional Vision private endpoint display name override."
  type        = string
  default     = null
}

variable "policy_compartment_ocid" {
  description = "Compartment OCID where the IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "IAM policy statements for AI service callers, service accounts, and bucket access."
  type        = list(string)
  default     = []
}
